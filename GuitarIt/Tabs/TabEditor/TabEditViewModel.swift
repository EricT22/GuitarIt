import Foundation
import Combine
internal import CoreGraphics
internal import QuartzCore


class TabEditViewModel: ObservableObject {
    @Published var grids: [TabEditorModel] = []
    
    let fileURL: URL
    var templateName: String
    
    
    @Published var selectionMode: Bool = false
    @Published var selectedGridIDs: Set<UUID> = []
    
    
    // Audio processing
    
    @Published var isProcessing: Bool = false
    
    private var sessionStartTime: TimeInterval = 0
    private var currentTime: TimeInterval {
        CACurrentMediaTime() - sessionStartTime
    }
    
    private let crepeProcessor: CrepeProcessor = CrepeProcessor()
    private let basicPitchProcessor: BasicPitchProcessor = BasicPitchProcessor()
    
    private var crepeListenerID: UUID? = nil
    private var basicPitchListenerID: UUID? = nil
    
    
    private let overlapPrecision: TimeInterval = 0.001
    
    
    private let tabLock = NSLock()
    
    // Minimal history to avoid overlaps b/t CREPE and Basic Pitch
    private var recentEventTimestamps: [TimeInterval] = []
    
    
    init(tab: TabItem) {
        self.fileURL = tab.fileURL
        self.templateName = tab.templateName
    }
    
    
    func parseASCIItoGrids(_ text: String) -> [TabEditorModel] {
        let blocks = text.split(separator: "\n\n").map(String.init)
        
        return blocks.map { TabEditorModel(contentBlock: $0) }
    }
    
    func stringifyGrids(_ grids: [TabEditorModel]) -> String {
        return grids
                .map{ $0.toString() }
                .joined(separator: "\n\n")
    }
    
    
    func appendGridFromTemplate(){
        let template = TabTemplateRegistry.shared.template(named: templateName)!
        
        grids.append(TabEditorModel(stringNames: template))
    }
    
    
    
    func deleteSelectedGrids() {
        grids.removeAll { grid in
            selectedGridIDs.contains(grid.id)
        }
        
        // Selection mode still active but clears selected grids
        selectedGridIDs.removeAll()
    }
    
    
    func duplicateSelectedGrids() {
        let indices = grids.indices.filter { selectedGridIDs.contains(grids[$0].id) }
        
        // Reversed so that inserting doesn't cause shifting errors
        for index in indices.sorted().reversed() {
            let copy = grids[index].duplicate()
            
            grids.insert(copy, at: index + 1)
        }
        
        // Selection mode still active but clears selected grids
        selectedGridIDs.removeAll()
    }
    
    
    func moveGrid(_ id: UUID, movingUpwards: Bool) {
        let index = grids.firstIndex(where: { $0.id == id })!
        let to: Int
        
        if (movingUpwards) {
            to = index - 1
            
            if !(to < 0) {
                let contentCopy = grids[to].grid
                grids[to].modifyContent(grids[index].grid)
                grids[index].modifyContent(contentCopy)
            }
        } else {
            to = index + 1
            
            if !(to >= grids.count) {
                let contentCopy = grids[to].grid
                grids[to].modifyContent(grids[index].grid)
                grids[index].modifyContent(contentCopy)
            }
        }
    }
    
    
    func toggleSelection(for id: UUID) {
        if selectedGridIDs.contains(id) {
            selectedGridIDs.remove(id)
        } else {
            selectedGridIDs.insert(id)
        }
    }
    
    
    func load() {
        do {
            let text = try String(contentsOfFile: fileURL.path(), encoding: .utf8)
            
            grids = parseASCIItoGrids(text)
        } catch {
            print("Failed to load tab contents: \(error)")
            // fallback
            grids = []
        }
    }
    
    func save() {
        let content = stringifyGrids(grids)
        
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to save tab content: \(error)")
        }
    }
    
    
    
    
    // Audio processing
    // NOTE: Timestamps occur when the event callback is received by the viewmodel
    //       For Crepe this is essentially when the note was played
    //       For BasicPitch it equates to the end of the window
    
    func startProcessing() {
        guard !isProcessing else { return }
        isProcessing = true
        sessionStartTime = CACurrentMediaTime()
        
        crepeProcessor.onPitchPredict = { [weak self] pitch, confidence in
            guard let self = self else { return }
            
            let event = CrepePitchEvent(
                pitch: pitch,
                confidence: confidence,
                timestamp: self.currentTime
            )
            
            self.handleCrepeEvent(event)
        }
        
        basicPitchProcessor.onNotes = { [weak self] events in
            guard let self = self else { return }
            
            let windowTimestamp = self.currentTime
            
            self.handleBasicPitchEvents(events, windowTimestamp)
        }
        
        
        crepeListenerID = AudioCaptureService.shared.addListener({ [weak self] samples in
            self?.crepeProcessor.process(samples: samples)
        })
        
        
        basicPitchListenerID = AudioCaptureService.shared.addListener({ [weak self] samples in
            self?.basicPitchProcessor.process(samples: samples)
        })
        
        AudioCaptureService.shared.startIfNeeded()
    }
    
    func stopProcessing() {
        guard isProcessing else { return }
        
        isProcessing = false
        
        if let id = crepeListenerID {
            AudioCaptureService.shared.removeListener(id)
        }
        
        if let id = basicPitchListenerID {
            AudioCaptureService.shared.removeListener(id)
        }
        
        AudioCaptureService.shared.stopIfPossible()
    }
    
    
    private func handleCrepeEvent(_ event: CrepePitchEvent) {
        guard isProcessing else { return }
        
        let mapped = TabStringFretMapper.mapSingleNote(event)
        insertMappedEventIntoTab(mapped)
    }
    
    
    private func handleBasicPitchEvents(_ events: [NoteEvent], _ ts: TimeInterval) {
        guard isProcessing else { return }
        
        // Only crepe deals w/ single note events
        guard events.count > 1 else { return }
        
        let mapped = TabStringFretMapper.mapChord(events, windowTimestamp: ts)
        
        
        for chord in mapped {
            insertMappedEventIntoTab(chord)
        }
    }
    
    
    private func insertMappedEventIntoTab(_ mapped: MappedTabEvent) {
        
        tabLock.lock()
        defer { tabLock.unlock() }
        
        // Get new timestamps
        let newTimestamps: [TimeInterval]
        
        switch mapped {
        case .singleNote(let note):
            newTimestamps = [note.timestamp]
        case .chord(let notes):
            newTimestamps = notes.map { $0.timestamp }
        }
        
        // Check Overlap
        
        let hasOverlap = newTimestamps.contains { ts in
            recentEventTimestamps.contains { old in
                abs(ts - old) < overlapPrecision
            }
        }
        
        // reject event it if it has overlap
        if hasOverlap { return }
        
        // record all new timestamps
        recentEventTimestamps.append(contentsOf: newTimestamps)
        
        
        // prune old timestamps
        let cutoff = (newTimestamps.min() ?? 0) - 2.0
        recentEventTimestamps.removeAll { $0 < cutoff }
        
        
        // updating grids happens here
        
    }
}
