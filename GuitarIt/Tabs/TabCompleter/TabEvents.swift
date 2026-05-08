import Foundation


struct CrepePitchEvent {
    let pitch: Float
    let confidence: Float
    let timestamp: TimeInterval
}


enum MappedTabEvent {
    case singleNote(MappedNote)
    case chord([MappedNote])
}

struct MappedNote {
    let stringIndex: Int // 0 = high E, 5 = low E
    let fret: Int // 0-24
    let timestamp: TimeInterval
    let duration: TimeInterval?
    let midi: Int?
    let confidence: Float?
}
