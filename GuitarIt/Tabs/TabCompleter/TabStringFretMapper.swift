import Foundation

// maps notes to strings/fret numbers
// pure logic

enum TabStringFretMapper {
    
    // MARK: Chord Mapping
    
    
    private static var windowDuration: TimeInterval {
        Double(BasicPitchConstants.audioNSamples) / Double(BasicPitchConstants.sampleRate)
    }
    
    
    static func mapChord(_ events: [NoteEvent], windowTimestamp: TimeInterval) -> [MappedTabEvent] {
        // Compute: Window duration + secondsPerFrame
        // Derive note start times and end times
        // Cluster notes into chords based on times
        // String + fret for each note based on chord dictionary
        // Build [MappedNote] and wrap into MappedTabEvent.chord
        
        
        let windowDuration = self.windowDuration
        
        let globalEvents = convertToGlobalTimes(events, windowTimestamp: windowTimestamp, windowDuration: windowDuration)
        
        let clusteredEvents = clusterNotesIntoChords(globalEvents)
        
        guard !clusteredEvents.isEmpty else { return [] }
        
        let sortedClusters = sortChordsForLookup(from: clusteredEvents)
        
        let chords = mapChordsToLibrary(sortedClusters)
        
        return chords
    }
    
    
    private static func convertToGlobalTimes(_ events: [NoteEvent], windowTimestamp: TimeInterval, windowDuration: TimeInterval) -> [NoteEvent] {
        let windowStartTime = windowTimestamp - windowDuration
        
        return events.map { note in
            let globalStartTime = windowStartTime + note.startTime
            let globalEndTime = windowStartTime + note.endTime
            
            
            return NoteEvent(
                startTime: globalStartTime,
                endTime: globalEndTime,
                midiPitch: note.midiPitch,
                amplitude: note.amplitude)
        }
    }
    
    
    // Default threshold of 50ms
    private static func clusterNotesIntoChords(_ events: [NoteEvent], threshold: TimeInterval = 0.05) -> [[NoteEvent]] {
        guard !events.isEmpty else { return [] }
        
        let sortedEvents = events.sorted { $0.startTime < $1.startTime }
        
        var clusters: [[NoteEvent]] = []
        var currentCluster: [NoteEvent] = [sortedEvents[0]]
        
        for i in 1..<sortedEvents.count {
            let prev = sortedEvents[i - 1]
            let curr = sortedEvents[i]
            
            if curr.startTime - prev.endTime < threshold {
                // same chord
                currentCluster.append(curr)
            } else {
                // new chord
                clusters.append(currentCluster)
                currentCluster = [curr]
            }
        }
        
        // Appending last cluster
        clusters.append(currentCluster)
        
        // Only return clusters w/ more than one note
        return clusters.filter { $0.count > 1 }
    }

    
    private static func sortChordsForLookup(from clusters: [[NoteEvent]]) -> [[NoteEvent]] {
        return clusters.map { cluster in
            cluster.sorted { $0.midiPitch < $1.midiPitch }  // sorting happens to help w/ lookup later
        }
    }
    
    
    private static func mapChordsToLibrary(_ chords: [[NoteEvent]]) -> [MappedTabEvent] {
        // Map to voicing library goes here
        
        return []
    }
    
    
    
    // MARK: Single note mapping
    
    
    static func mapSingleNote(_ event: CrepePitchEvent) -> MappedTabEvent {
        // Pitch -> MIDI if conf high enough
        // best string + fret
        // Wrap into MappedNote + MappedTabEvent.singleNote
        fatalError()
    }
    
    
    private static func midiFromPitch(_ pitch: Float) -> Int {
        // Pitch (Hz) -> midi
        fatalError()
    }
     
    
    // TODO: some heuristic func for choosing string/fret combo
}
