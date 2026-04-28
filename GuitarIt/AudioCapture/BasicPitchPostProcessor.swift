import Foundation

struct NoteEvent {
    let startTime: Double
    let endTime: Double
    let midiPitch: Int
    let amplitude: Float
}


final class BasicPitchPostProcessor {
    
    
    func modelOutputToNotes(
        frames: [[Float]],
        onsets: [[Float]],
        contours: [[Float]] // unused for now, no pitch bends
    ) -> [NoteEvent] {
        
        // decode raw model output into frame based note events
        let rawNotes = outputToNotesPolyphonic(
            frames: frames,
            onsets: onsets,
            onsetThreshold: 0.5,
            frameThreshold: 0.5,
            minNoteLength: BasicPitchConstants.minNoteLengthFrames,
            inferOnsets: true,
            minFreq: nil,
            maxFreq: nil,
            melodiaTrick: true
        )
        
        // Convert frame indices into seconds
        let times = modelFramesToTimes(frames.count)
        
        // Convert to NoteEvents
        let noteEvents: [NoteEvent] = rawNotes.map { note in
            let startSec = times[note.start]
            let endSec = times[note.end]
            
            return NoteEvent(startTime: startSec, endTime: endSec, midiPitch: note.pitch, amplitude: note.amp)
        }
        
        return noteEvents
    }
    
    
    
    private func outputToNotesPolyphonic(
        frames: [[Float]],
        onsets: [[Float]],
        onsetThreshold: Float,
        frameThreshold: Float,
        minNoteLength: Int,
        inferOnsets: Bool,
        minFreq: Double?,
        maxFreq: Double?,
        melodiaTrick: Bool,
        energyTolerance: Int = BasicPitchConstants.energyTolerance
    ) -> [(start: Int, end: Int, pitch: Int, amp: Float)] {
        
        let nFrames = frames.count
        let nFreqs = frames.first?.count ?? 0
        
        // Apply frequency constraints
        var constrainedOnsets = onsets
        var constrainedFrames = frames
        
        constrainFrequency(
            onsets: &constrainedOnsets,
            frames: &constrainedFrames,
            minFreq: minFreq,
            maxFreq: maxFreq
        )
        
        // Use onsets inferred from frames as well as predicted ones
        if inferOnsets {
            constrainedOnsets = getInferredOnsets(onsets: constrainedOnsets, frames: constrainedFrames)
        }
        
        // Peak pick onsets (argrelmax)
        var peakPick = Array(
            repeating: Array(repeating: Float(0), count: nFreqs),
            count: nFrames
        )
        
        for f in 0..<nFreqs {
            for t in 1..<(nFrames - 1) {
                let prev = constrainedFrames[t - 1][f]
                let curr = constrainedFrames[t][f]
                let next = constrainedFrames[t + 1][f]
                
                if curr > prev && curr > next {
                    peakPick[t][f] = curr
                }
            }
        }
        
        // Get onset candidates which are above the threshold (reversed)
        var onsetCandidates: [(t: Int, f: Int)] = []
        
        for t in 0..<nFrames {
            for f in 0..<nFreqs {
                if peakPick[t][f] >= onsetThreshold {
                    onsetCandidates.append((t: t, f: f))
                }
            }
        }
        onsetCandidates.reverse()
        
        // Track energy forward to find note ends
        var remainingEnergy = constrainedFrames
        var noteEvents: [(start: Int, end: Int, pitch: Int, amp: Float)] = []
        
        for (startIdx, freqIdx) in onsetCandidates {
            if startIdx >= nFrames - 1 { continue }
            
            var i = startIdx + 1
            var belowCount = 0
            
            while i < nFrames - 1 && belowCount < energyTolerance {
                if remainingEnergy[i][freqIdx] < frameThreshold {
                    belowCount += 1
                } else {
                    belowCount = 0
                }
                
                i += 1
            }
            
            i -= belowCount
            
            // If note is too short skip
            if i - startIdx <= minNoteLength { continue }
            
            // zero out used energy (freq, freq +/- 1)
            for t in startIdx..<i {
                remainingEnergy[t][freqIdx] = 0
                
                if freqIdx > 0 {
                    remainingEnergy[t][freqIdx - 1] = 0
                }
                
                if freqIdx < nFreqs - 1 {
                    remainingEnergy[t][freqIdx + 1] = 0
                }
            }
            
            // Compute amplitude
            let slice = constrainedFrames[startIdx..<i].map({ $0[freqIdx] })
            let amp = slice.reduce(0, +) / Float(slice.count)
            
            // MIDI pitch = freqIdx + MIDI_OFFSET (21)
            let midiPitch = freqIdx + BasicPitchConstants.midiOffset
            
            noteEvents.append((startIdx, i, midiPitch, amp))
        }
        
        // Melodia Trick (optional)
        if melodiaTrick {
            var energy = remainingEnergy
            
            while let maxVal = energy.flatMap({ $0 }).max(), maxVal > frameThreshold {
                guard let (midT, midF) = findMaxIndex(in: energy) else { break }
                
                // Zero center
                energy[midT][midF] = 0
                
                // Forward Pass
                var t = midT + 1
                var below = 0
                
                while t < nFrames - 1 && below < energyTolerance {
                    if energy[t][midF] < frameThreshold {
                        below += 1
                    } else {
                        below = 0
                    }
                    
                    energy[t][midF] = 0
                    
                    if midF > 0 {
                        energy[t][midF - 1] = 0
                    }
                    
                    if midF < nFreqs - 1 {
                        energy[t][midF + 1] = 0
                    }
                    
                    t += 1
                }
                let endT: Int = t - 1 - below
                
                // Backward pass
                t = midT - 1
                below = 0
                
                while t > 0 && below < energyTolerance {
                    if energy[t][midF] < frameThreshold {
                        below += 1
                    } else {
                        below = 0
                    }
                    
                    energy[t][midF] = 0
                    
                    if midF > 0 {
                        energy[t][midF - 1] = 0
                    }
                    
                    if midF < nFreqs - 1 {
                        energy[t][midF + 1] = 0
                    }
                    
                    t -= 1
                }
                let startT: Int = t + 1 + below
                
                if endT - startT <= minNoteLength {
                    continue
                }
                
                let slice = constrainedFrames[startT..<endT].map({ $0[midF] })
                let amplitude = slice.reduce(0, +) / Float(slice.count)
                let midiPitch = midF + BasicPitchConstants.midiOffset
                
                noteEvents.append((startT, endT, midiPitch, amplitude))
            }
        }
        
        return noteEvents
    }
    
    
    
    private func modelFramesToTimes(_ nFrames: Int) -> [Double] {
        
        // equivalent to librosa.frames_to_time
        let hopSeconds = Double(BasicPitchConstants.fftHop) / Double(BasicPitchConstants.sampleRate)
        var originalTimes = [Double](repeating: 0, count: nFrames)
        
        for i in 0..<nFrames {
            originalTimes[i] = Double(i) * hopSeconds
        }
        
        // Compute window number for each frame
        // Each window is ANNOT_N_FRAMES long (framesPerWindow in constants)
        var windowNums = [Double](repeating: 0, count: nFrames)
        
        for i in 0..<nFrames {
            windowNums[i] = floor(Double(i) / Double(BasicPitchConstants.framesPerWindow))
        }
        
        
        // Compute window offset
        let windowOffset =
            (Double(BasicPitchConstants.fftHop) / Double(BasicPitchConstants.sampleRate)) *
            (Double(BasicPitchConstants.framesPerWindow) - (Double(BasicPitchConstants.audioNSamples) / Double(BasicPitchConstants.fftHop)))
            + BasicPitchConstants.magicAlignmentOffset
        
        // Apply corrections
        var times = [Double](repeating: 0, count: nFrames)
        
        for i in 0..<nFrames {
            times[i] = originalTimes[i] + (windowNums[i] * windowOffset)
        }
        
        return times
    }
    
    
    
    private func constrainFrequency(onsets: inout [[Float]], frames: inout [[Float]], minFreq: Double?, maxFreq: Double?) {
        let nFreqs = frames.first?.count ?? 0
        
        // Convert Hz to a frequency bin index
        func freqToBin(_ freq: Double) -> Int {
            // Hz to Midi
            let midi = 69 + 12 * log2(freq / 440.0)
            // Midi to bin index
            return Int(midi.rounded()) - BasicPitchConstants.midiOffset
        }
        
        var minBin = 0
        var maxBin = nFreqs - 1
        
        if let minF = minFreq {
            minBin = max(0, freqToBin(minF))
        }
        
        if let maxF = maxFreq {
            maxBin = min(maxBin, freqToBin(maxF))
        }
        
        // Zero out bins outside [minBin, maxBin]
        for t in 0..<frames.count {
            for f in 0..<nFreqs {
                if f < minBin || f > maxBin {
                    frames[t][f] = 0
                    onsets[t][f] = 0
                }
            }
        }
    }
    
    
    
    private func getInferredOnsets(onsets: [[Float]], frames: [[Float]]) -> [[Float]] {
        // Using n_diff of 1 (simpler)
        
        let nFrames = frames.count
        let nFreqs = frames.first?.count ?? 0
        
        var inferred = onsets
        
        // Each column in frames is a frequency bin that tracks rises/falls in energy for that frequency
        for f in 0..<nFreqs {
            for t in 1..<nFrames {
                let prev = frames[t - 1][f]
                let curr = frames[t][f]
                
                if curr > prev {
                    let diff = curr - prev
                    
                    inferred[t][f] = max(inferred[t][f], diff)
                }
            }
        }
        
        return inferred
    }
    
    
    private func findMaxIndex(in matrix: [[Float]]) -> (t: Int, f: Int)? {
        var maxVal: Float = -Float.infinity
        var maxT: Int = 0
        var maxF: Int = 0
        
        for t in 0..<matrix.count {
            for f in 0..<matrix[t].count {
                if matrix[t][f] > maxVal {
                    maxVal = matrix[t][f]
                    maxT = t
                    maxF = f
                }
            }
        }
        
        return maxVal > -Float.infinity ? (maxT, maxF) : nil
    }
}
