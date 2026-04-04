import Foundation

// Extension allows you to inject new features into existing types
extension FileManager {
    var localTabsDirectory: URL {
        // Gets path to Documents from user's home directory
        guard let documentsDirectory = urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Could not locate user's Documents directory.")
        }
        
        // returns (app)/Documents/Tabs
        return documentsDirectory.appendingPathComponent("Tabs", isDirectory: true)
    }
    
    var iCloudTabsDirectory: URL? {
        // returns (icloud)/Documents/Tabs
        return url(forUbiquityContainerIdentifier: nil)?
            .appendingPathComponent("Documents/Tabs", isDirectory: true)
    }
}
