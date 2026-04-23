// NOTICE in compliance with Apache License 2.0
//Basic Pitch
//Copyright 2022 Spotify AB
//
//This product includes software developed at
//Spotify AB (http://www.spotify.com/).
//
//This product includes software from Librosa (ISC).
//* Copyright (C) 2013--2017, librosa development team.
//
//This product includes software from mir_eval (MIT)
//* Copyright (C) 2014 Colin Raffel
//
//This product includes software from numpy (BSD)
//* Copyright (C) 2005-2022, NumPy Developers.
//
//This product includes software from pretty-midi (MIT)
//* Copyright (C) 2014 Colin Raffel
//
//This product includes software from resampy (ISC)
//* Copyright (C) 2016, Brian McFee
//
//This product includes software from scipy (BSD)
//* Copyright (C) 2001-2002 Enthought, Inc. 2003-2022, SciPy Developers
//
//This product includes software from tensorflow (Apache 2.0)
//* Copyright (C) 2019 Google, LLC <packages@tensorflow.org>
//
//The tests for `basic-pitch` include audio files from the
//Vocadito dataset liscened under Creative Commons
//Attribution 4.0 International. The dataset can be found at:
//https://zenodo.org/record/5578807#.YnRm5vPMKDU

// File contains constants and functionality from the github page
// https://github.com/spotify/basic-pitch/blob/main/README.md
// From files [inference.py, note_creation.py, constants.py]


import CoreML

class BasicPitch {
    private let model: nmp
    
    let overlapFrames = 30
    let framesPerWindow = 172
    let fftHop = 256
    let sampleRate = 22050
    let windowLengthSeconds = 2
    let windowSize = 43844
    
    init() {
        model = try! nmp(configuration: .init())
    }
    
    
    func predict(window: [Float]) -> nmpOutput? {
        guard let mlarr = arrayToMLArray(window) else { return nil }
        let input = nmpInput(input_2: mlarr)
        
        return try? model.prediction(input: input)
    }
    
    
    private func stitchOutput(windows: [MLMultiArray], audioOriginalLength: Int) -> MLMultiArray {
        let halfOverlap = overlapFrames / 2
        let trimmedFramesPerWindow = framesPerWindow - overlapFrames

        // 1. Extract trimmed windows
        var trimmed: [[Float]] = []

        for window in windows {
            let time = framesPerWindow
            let freq = window.count / time

            var windowFrames: [[Float]] = []

            for t in halfOverlap ..< (time - halfOverlap) {
                let start = t * freq
                let end = start + freq
                let frame = (start..<end).map { Float(truncating: window[$0]) }
                windowFrames.append(frame)
            }

            trimmed.append(contentsOf: windowFrames)
        }

        // 2. Compute expected total frames
        let hopSize = (sampleRate * windowLengthSeconds - fftHop) - (overlapFrames * fftHop)
        let nExpectedWindows = Double(audioOriginalLength) / Double(hopSize)
        let expectedFrames = Int(nExpectedWindows * Double(trimmedFramesPerWindow))

        // 3. Trim to expected length
        let finalFrames = Array(trimmed.prefix(expectedFrames))

        // 4. Convert back to MLMultiArray
        let totalFrames = finalFrames.count
        let freqBins = finalFrames.first?.count ?? 0

        let result = try! MLMultiArray(
            shape: [NSNumber(value: totalFrames), NSNumber(value: freqBins)],
            dataType: .float32
        )

       for t in 0..<totalFrames {
           for f in 0..<freqBins {
               result[t * freqBins + f] = NSNumber(value: finalFrames[t][f])
           }
       }

       return result
    }
    
    private func arrayToMLArray(_ window: [Float]) -> MLMultiArray? {
        // Expected shape is [1, 43844, 1]
        let shape: [NSNumber] = [1, NSNumber(value: windowSize), 1]
        
        guard let arr = try? MLMultiArray(shape: shape, dataType: .float32) else {
            return nil
        }
        
        for i in 0..<window.count {
            arr[i] = NSNumber(value: window[i])
        }
        
        return arr
    }
}
