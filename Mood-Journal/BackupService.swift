import Foundation
import CoreData

class BackupService {
    static let shared = BackupService()

    private init() {}

    func backupJournalEntries(viewContext: NSManagedObjectContext) -> URL? {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)]

        do {
            let items = try viewContext.fetch(fetchRequest)
            let csvData = generateCSV(from: items)

            // Save CSV file to the temporary directory
            let fileName = "MoodJournalBackup.csv"
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent(fileName)

            try csvData.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL

        } catch {
            print("Failed to fetch items: \(error.localizedDescription)")
            return nil
        }
    }

    private func generateCSV(from items: [Item]) -> String {
        var csvString = "Timestamp,Notes,Mood\n"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        for item in items {
            let timestamp = formatter.string(from: item.timestamp ?? Date())
            let notes = item.notes ?? ""
            let mood = item.mood ?? ""
            csvString += "\(timestamp),\"\(notes)\",\"\(mood)\"\n"
        }

        return csvString
    }
}
