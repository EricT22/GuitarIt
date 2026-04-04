import Foundation
import Combine

// ViewModel for the TabWriter section
class TabWriterViewModel: ObservableObject {
    @Published var tabs: [TabItem] = [] {
        didSet {
            saveTabs()
        }
    }
    // TODO WHY NOT USE FM EXTENTION WHEN DELETING AND NOW LOADING TO PRUNE
    private let tabsKey: String = "tabs"
    
    
    init() {
        ensureDirectoriesExist()
        loadTabs()
        pruneOrphanedFiles()
    }
    
    
    func sortedTabs(sortMode: SortMode) -> [TabItem] {
        switch sortMode {
        case .favoritesFirst:
                return tabs.sorted { // returns true if $0 should come before $1 (aka if left should go before right)
                    if ($0.isFavorite != $1.isFavorite) {
                        return $0.isFavorite && !$1.isFavorite
                    }
                    return $0.lastUsed > $1.lastUsed
                }
        case .lastUsed:
            return tabs.sorted { $0.lastUsed > $1.lastUsed }
        case .byDate:
            return tabs.sorted { $0.createdAt < $1.createdAt }
        }
    }
    
    
    
    
    func markTabAsUsed(_ tab: TabItem) {
        if let index = tabs.firstIndex(where: { $0.id == tab.id }) {
            tabs[index].markUsed()
        }
    }
    
    
    
    
    
    func createNewTab(storage: StorageOption, template: String) {
        let directory = activeDirectory(storageOption: storage)
        
        let id = UUID()
        let fileURL = directory.appendingPathComponent("\(id.uuidString).txt")
        
        let registry = TabTemplateRegistry.shared
        let stringNames: [String]
        let templateName: String
        
        if let names = registry.template(named: template) {
            stringNames = names
            templateName = template
        } else {
            stringNames = registry.standardTemplate()
            templateName = registry.allTemplates.first!.name
        }
        
        let grid = TabEditorModel(stringNames: stringNames)
        let templateContent = grid.toString()
        
        do {
            try templateContent.write(to: fileURL, atomically: true, encoding: .utf8)
            
        } catch {
            print("Failed to create new tab: \(error)")
            return // don't let metadata be created if file creation  failed
        }
        
        let newTab = TabItem(
            id: id,
            name: "",
            templateName: templateName,
            fileURL: fileURL
        )
        
        tabs.append(newTab)
    }
    
    
    
    
    func delete(at offsets: IndexSet) {
        let items = offsets.map{ tabs[$0] }
        
        for tab in items {
            try? FileManager.default.removeItem(at: tab.fileURL)
        }
        
        for index in offsets.sorted(by: >) {
            tabs.remove(at: index)
        }
    }
    
    
    
    
    private func pruneOrphanedFiles() {
        let fm = FileManager.default
        
        let knownFilenames = Set(tabs.map { $0.fileURL.lastPathComponent })
        
        // PRUNING LOCAL
        let localDir = fm.localTabsDirectory
        
        if let localTabs = try? fm.contentsOfDirectory(at: localDir, includingPropertiesForKeys: nil) {
            for url in localTabs {
                let filename = url.lastPathComponent
                
                if !knownFilenames.contains(filename) {
                    print("Pruning orphaned file: \(filename)")
                    // deleting orphaned file (no metadata associated in 'tabs')
                    try? fm.removeItem(at: url)
                }
            }
        }
        
        // PRUNING iCLOUD
        if let iCloudDir = fm.iCloudTabsDirectory,
           let cloudFiles = try? fm.contentsOfDirectory(at: iCloudDir, includingPropertiesForKeys: nil) {
            for url in cloudFiles {
                let filename = url.lastPathComponent
                
                if !knownFilenames.contains(filename) {
                    print("Pruning orphaned file: \(filename)")
                    // deleting orphaned file (no metadata associated in 'tabs')
                    try? fm.removeItem(at: url)
                }
            }
        }
    }
    
    
    
    
    private func saveTabs() {
        do {
            let data = try JSONEncoder().encode(tabs)
            UserDefaults.standard.set(data, forKey: tabsKey)
        } catch {
            print("Error loading tabs: \(error)")
        }
    }
    
    
    
    
    private func loadTabs() {
        guard let data = UserDefaults.standard.data(forKey: tabsKey) else {
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode([TabItem].self, from: data)
            
            let fm = FileManager.default
            let validTabs = decoded.filter { fm.fileExists(atPath: $0.fileURL.path)}
            
            tabs = validTabs // updates userdefaults w json that only has correct metadata (aka drops metadata with no associated path)
        } catch {
            print("Error loading tabs: \(error)")
            
            // Reset data
            UserDefaults.standard.removeObject(forKey: tabsKey)
            tabs = []
        }
    }
    
    
    
    
    private func ensureDirectoriesExist() {
        let fm = FileManager.default
        
        let localDir = fm.localTabsDirectory
        
        if (!fm.fileExists(atPath: localDir.path())) {
            do {
                try fm.createDirectory(at: localDir, withIntermediateDirectories: true)
            } catch {
                print("Failed to create local directory: \(error)")
            }
        }
        
        if let iCloudDir = fm.iCloudTabsDirectory {
            if (!fm.fileExists(atPath: iCloudDir.path())){
                do {
                    try fm.createDirectory(at: iCloudDir, withIntermediateDirectories: true)
                } catch {
                    print("Failed to create iCloud directory: \(error)")
                }
            }
        }
    }
    
    
    
    
    private func activeDirectory(storageOption: StorageOption) -> URL {
        let fm = FileManager.default
        
        switch storageOption {
        case .local:
            return fm.localTabsDirectory
        case .cloud:
            // If iCloud isn't available just use local storage
            if let iCloudDir = fm.iCloudTabsDirectory {
                return iCloudDir
            } else {
                return fm.localTabsDirectory
            }
        }
    }
}
