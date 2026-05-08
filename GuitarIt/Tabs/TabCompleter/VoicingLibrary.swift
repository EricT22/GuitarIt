enum ChordQuality {
    case major
    case minor
    case major7
    case minor7
    case power
}

struct VoicingTemplate {
    // semitone offsets from root (0 = root)
    let intervals: [Int]
    
    // 0 = high e, 5 = low e
    let strings: [Int]
    
    // relative to root
    let fretOffsets: [Int]
    
    let quality: ChordQuality
    
    // Can you move this shape around?
    let isMovable: Bool
    
    let name: String
    
    
    func matches(intervalsInChord: [Int], minMatchedNotes: Int = 2) -> Bool {
        let templateSet = Set(intervals)
        let chordSet = Set(intervalsInChord)
        
        return chordSet.intersection(templateSet).count >= minMatchedNotes
    }
}


enum VoicingLibrary {

    static let allTemplates: [VoicingTemplate] = [
        // E-shape family
        eShapeMajor,
        eShapeMinor,
        eShapeMajor7,
        eShapeMinor7,

        // A-shape family
        aShapeMajor,
        aShapeMinor,
        aShapeMajor7,
        aShapeMinor7,

        // Power chords
        powerChord6thString,
        superPowerChord,
        
        // Octave
        octaveShape,

        // Triads (major/minor)
        majorTriad_1to3,
        minorTriad_1to3,
        majorTriad_2to4,
        minorTriad_2to4,
        majorTriad_3to5,
        minorTriad_3to5,
        majorTriad_4to6,
        minorTriad_4to6,

        // Essential open shapes (non-duplicating)
        openCmajor,
        openCminor,
        openCmajor7,
        openCminor7,
        openDmajor,
        openDminor,
        openDmajor7,
        openDminor7,
        openGmajor,
        openGminor,
        openGmajor7
    ]

    // MARK: - E-shape family (root on 6th string)

    static let eShapeMajor = VoicingTemplate(
        intervals: [0, 7, 12, 16, 19, 24],
        strings:   [5, 4, 3, 2, 1, 0],
        fretOffsets: [0, 2, 2, 1, 0, 0],
        quality: .major,
        isMovable: true,
        name: "E-shape major"
    )

    static let eShapeMinor = VoicingTemplate(
        intervals: [0, 7, 12, 15, 19, 24],
        strings:   [5, 4, 3, 2, 1, 0],
        fretOffsets: [0, 2, 2, 0, 0, 0],
        quality: .minor,
        isMovable: true,
        name: "E-shape minor"
    )

    static let eShapeMajor7 = VoicingTemplate(
        intervals: [0, 4, 7, 11, 16, 19],
        strings:   [5, 4, 3, 2, 1, 0],
        fretOffsets: [0, 2, 1, 1, 0, 0],
        quality: .major7,
        isMovable: true,
        name: "E-shape major7"
    )

    static let eShapeMinor7 = VoicingTemplate(
        intervals: [0, 3, 7, 10, 15, 19],
        strings:   [5, 4, 3, 2, 1, 0],
        fretOffsets: [0, 2, 0, 0, 0, 0],
        quality: .minor7,
        isMovable: true,
        name: "E-shape minor7"
    )

    // MARK: - A-shape family (root on 5th string)

    static let aShapeMajor = VoicingTemplate(
        intervals: [0, 7, 12, 16, 19],
        strings:   [4, 3, 2, 1, 0],
        fretOffsets: [0, 2, 2, 2, 0],
        quality: .major,
        isMovable: true,
        name: "A-shape major"
    )

    static let aShapeMinor = VoicingTemplate(
        intervals: [0, 7, 12, 15, 19],
        strings:   [4, 3, 2, 1, 0],
        fretOffsets: [0, 2, 2, 1, 0],
        quality: .minor,
        isMovable: true,
        name: "A-shape minor"
    )

    static let aShapeMajor7 = VoicingTemplate(
        intervals: [0, 4, 7, 11, 16],
        strings:   [4, 3, 2, 1, 0],
        fretOffsets: [0, 2, 1, 1, 0],
        quality: .major7,
        isMovable: true,
        name: "A-shape major7"
    )

    static let aShapeMinor7 = VoicingTemplate(
        intervals: [0, 3, 7, 10, 15],
        strings:   [4, 3, 2, 1, 0],
        fretOffsets: [0, 2, 0, 1, 0],
        quality: .minor7,
        isMovable: true,
        name: "A-shape minor7"
    )

    // MARK: - Power chords

    static let powerChord6thString = VoicingTemplate(
        intervals: [0, 7],
        strings:   [5, 4],
        fretOffsets: [0, 2],
        quality: .power,
        isMovable: true,
        name: "Power chord (6th string root)"
    )
    


    static let superPowerChord = VoicingTemplate(
        intervals: [0, 7, 12],        // root + 5th + octave
        strings:   [5, 4, 3],         // E A D
        fretOffsets: [0, 2, 2],
        quality: .power,
        isMovable: true,
        name: "Super power chord (root + 5th + octave)"
    )
    
    static let octaveShape = VoicingTemplate(
        intervals: [0, 12],           // root + octave
        strings:   [5, 3],            // E → D
        fretOffsets: [0, 2],
        quality: .power,
        isMovable: true,
        name: "Octave shape (root + octave)"
    )


    
    
    // MARK: - Triads
    
    
    static let majorTriad_1to3 = VoicingTemplate(
        intervals: [0, 4, 7],
        strings:   [2, 1, 0],      // G B e
        fretOffsets: [0, 0, 0],
        quality: .major,
        isMovable: true,
        name: "Major triad (strings 1–3)"
    )

    
    static let minorTriad_1to3 = VoicingTemplate(
        intervals: [0, 3, 7],
        strings:   [2, 1, 0],
        fretOffsets: [0, 0, 0],
        quality: .minor,
        isMovable: true,
        name: "Minor triad (strings 1–3)"
    )


    static let majorTriad_2to4 = VoicingTemplate(
        intervals: [0, 4, 7],
        strings:   [3, 2, 1],
        fretOffsets: [0, 1, 0],
        quality: .major,
        isMovable: true,
        name: "Major triad (strings 2–4)"
    )

    static let minorTriad_2to4 = VoicingTemplate(
        intervals: [0, 3, 7],
        strings:   [3, 2, 1],
        fretOffsets: [0, 0, 0],
        quality: .minor,
        isMovable: true,
        name: "Minor triad (strings 2–4)"
    )

    static let majorTriad_3to5 = VoicingTemplate(
        intervals: [0, 4, 7],
        strings:   [4, 3, 2],
        fretOffsets: [0, 2, 1],
        quality: .major,
        isMovable: true,
        name: "Major triad (strings 3–5)"
    )

    static let minorTriad_3to5 = VoicingTemplate(
        intervals: [0, 3, 7],
        strings:   [4, 3, 2],
        fretOffsets: [0, 2, 0],
        quality: .minor,
        isMovable: true,
        name: "Minor triad (strings 3–5)"
    )
    
    static let majorTriad_4to6 = VoicingTemplate(
        intervals: [0, 4, 7],
        strings:   [5, 4, 3],      // E A D
        fretOffsets: [0, 2, 2],
        quality: .major,
        isMovable: true,
        name: "Major triad (strings 4–6)"
    )
    
    
    static let minorTriad_4to6 = VoicingTemplate(
        intervals: [0, 3, 7],
        strings:   [5, 4, 3],
        fretOffsets: [0, 2, 1],
        quality: .minor,
        isMovable: true,
        name: "Minor triad (strings 4–6)"
    )



    // MARK: - Essential open shapes (non-duplicating)



    static let openCmajor = VoicingTemplate(
        intervals: [0, 4, 7, 12, 16],
        strings:   [4, 3, 2, 1, 0],
        fretOffsets: [3, 2, 0, 1, 0],
        quality: .major,
        isMovable: false,
        name: "Open C major"
    )
    
    static let openCmajor7 = VoicingTemplate(
        intervals: [0, 4, 7, 11, 16],     // C E G B E
        strings:   [4, 3, 2, 1, 0],
        fretOffsets: [3, 2, 0, 0, 0],
        quality: .major7,
        isMovable: false,
        name: "Open C major 7"
    )
    
    static let openCminor = VoicingTemplate(
        intervals: [0, 3, 7, 12, 15],     // C Eb G C D
        strings:   [4, 3, 2, 1, 0],
        fretOffsets: [3, 1, 0, 1, 3],
        quality: .minor,
        isMovable: false,
        name: "Open C minor"
    )

    static let openCminor7 = VoicingTemplate(
        intervals: [0, 3, 7, 10, 15],     // C Eb G Bb D
        strings:   [4, 3, 2, 1, 0],
        fretOffsets: [3, 1, 0, 1, 1],
        quality: .minor7,
        isMovable: false,
        name: "Open C minor 7"
    )



    static let openDmajor = VoicingTemplate(
        intervals: [0, 7, 12, 16],     // D A D F#
        strings:   [3, 2, 1, 0],       // D G B e
        fretOffsets: [0, 2, 3, 2],     // xx0232
        quality: .major,
        isMovable: false,
        name: "Open D major"
    )

    static let openDminor = VoicingTemplate(
        intervals: [0, 7, 12, 15],     // D A D F
        strings:   [3, 2, 1, 0],       // D G B e
        fretOffsets: [0, 2, 3, 1],     // xx0231
        quality: .minor,
        isMovable: false,
        name: "Open D minor"
    )
    
    static let openDmajor7 = VoicingTemplate(
        intervals: [0, 7, 11, 16],     // D A C# F#
        strings:   [3, 2, 1, 0],       // D G B e
        fretOffsets: [0, 2, 2, 2],     // xx0222
        quality: .major7,
        isMovable: false,
        name: "Open D major 7"
    )

    
    static let openDminor7 = VoicingTemplate(
        intervals: [0, 7, 10, 15],     // D A C F
        strings:   [3, 2, 1, 0],       // D G B e
        fretOffsets: [0, 2, 1, 1],     // xx0211
        quality: .minor7,
        isMovable: false,
        name: "Open D minor 7"
    )

    
    static let openGmajor = VoicingTemplate(
        intervals: [0, 4, 7, 12, 19, 24],  // G B D G B G
        strings:   [5, 4, 3, 2, 1, 0],
        fretOffsets: [3, 2, 0, 0, 3, 3],
        quality: .major,
        isMovable: false,
        name: "Open G major"
    )
    
    
    static let openGminor = VoicingTemplate(
        intervals: [0, 3, 7, 12, 15, 24],
        strings:   [5, 4, 3, 2, 1, 0],
        fretOffsets: [3, 1, 0, 0, 3, 3],
        quality: .minor,
        isMovable: false,
        name: "Open G minor"
    )

    
    static let openGmajor7 = VoicingTemplate(
        intervals: [0, 4, 7, 11, 19, 24],
        strings:   [5, 4, 3, 2, 1, 0],
        fretOffsets: [3, 2, 0, 0, 2, 2],
        quality: .major7,
        isMovable: false,
        name: "Open G major 7"
    )


}
