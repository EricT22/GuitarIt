import Foundation
import Combine
internal import CoreGraphics


class TabEditViewModel: ObservableObject {
    @Published var grids: [TabEditorModel] = []
    
    @Published var gridFrames: [UUID: CGRect] = [:]
    
    let fileURL: URL
    var templateName: String
    
    
    @Published var selectionMode: Bool = false
    @Published var selectedGridIDs: Set<UUID> = []
    
    @Published var isReordering: Bool = false
    @Published var pressedGridID: UUID? = nil
    @Published var activeDraggedIDs: Set<UUID> = []
    @Published var dragRange: Range<Int>? = nil
    
    
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
    
    
    
    func toggleSelection(for id: UUID) {
        if selectedGridIDs.contains(id) {
            selectedGridIDs.remove(id)
        } else {
            selectedGridIDs.insert(id)
        }
    }
    
    
    func contiguousSelectionRanges() -> [Range<Int>] {
        let indices = grids.indices.filter {
            selectedGridIDs.contains(grids[$0].id)
        }.sorted()
        
        guard !indices.isEmpty else { return [] }
        
        var ranges: [Range<Int>] = []
        var start = indices[0]
        var prev = start
        
        for index in indices.dropFirst() {
            if index == prev + 1 { // part of a contiguous block
                prev = index
            } else {
                ranges.append(start..<(prev + 1)) // add contiguous range to ranges
                start = index
                prev = index
            }
        }
        
        ranges.append(start..<(prev + 1))
        
        return ranges
    }
    
    
    func draggedBlock(for pressedID: UUID) -> Range<Int> {
        let ranges = self.contiguousSelectionRanges()
        
        guard let pressedIndex = grids.firstIndex(where: { $0.id == pressedID }) else {
            fatalError("Pressed ID not found in grids")
        }
        
        
        // No selection... drag only the current pressed grid
        if ranges.isEmpty {
            selectedGridIDs = [pressedID]
            return pressedIndex..<(pressedIndex + 1)
        }
        
        // Selection exists but pressed grid isn't selected -> collapse to a single pressed grid
        if !selectedGridIDs.contains(pressedID) {
            selectedGridIDs = [pressedID]
            return pressedIndex..<(pressedIndex + 1)
        }
        
        // Selection is contiguous and pressed is inside this range
        for range in ranges {
            if range.contains(pressedIndex) {
                return range
            }
        }
        
        // Selection is not contiguous -> collapse to a single pressed grid (fallback)
        selectedGridIDs = [pressedID]
        return pressedIndex..<(pressedIndex + 1)
    }
    
    
    
    func updateReorder(with dragOffset: CGFloat) {
        guard let range = dragRange else { return }
        
        let anchorID: UUID
        
        if (dragOffset < 0) {
            anchorID = grids[range].first!.id
        } else {
            anchorID = grids[range].last!.id
        }
        
        guard let originalFrame = gridFrames[anchorID] else { return }
        
        // Current midpoint
        let draggedMidY = originalFrame.midY + dragOffset
        
        let midpoints: [(index: Int, midY: CGFloat)] = grids.enumerated().compactMap { index, grid in
            guard let frame = gridFrames[grid.id] else { return nil }
            return (index, frame.midY)
        }
        
        guard let targetIndex = midpoints.min(by: {
            abs($0.midY - draggedMidY) < abs($1.midY - draggedMidY)
        })?.index else { return }
        
        if range.contains(targetIndex) { return }
        
        moveBlock(from: range, to: targetIndex)
    }
    
    
    func moveBlock(from range: Range<Int>, to targetIndex: Int) {
        let block = Array(grids[range])
        grids.removeSubrange(range)
        
        // if dragging up, block should start at target index, if dragging down, should end at target index.
        let insertionIndex: Int = targetIndex < range.lowerBound ? targetIndex : targetIndex - block.count + 1
        
        grids.insert(contentsOf: block, at: insertionIndex)
        
        dragRange = insertionIndex..<(insertionIndex + block.count)
    }
    

    
    func idsForRange(_ range: Range<Int>) -> [UUID] {
        return Array(grids[range].map { $0.id })
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
}
