import SwiftUI
import CoreData

class GlobalData: ObservableObject {
    @Published var emojis: [String: String] = [
        "happy": "😊",
        "embarrassed": "😳",
        "scared": "😱",
        "nervous": "😬",
        "goofy": "😜",
        "surprised": "😲",
        "quiet": "🤐",
        "annoyed": "😒",
        "cool": "😎",
        "sad": "😢",
        "tired": "😴",
        "excited": "😆",
        "bored": "😐",
        "sick": "🤒",
        "frustrated": "😤",
        "angry": "😠",
        "funny": "😂",
        "proud": "😌"
    ]
    
    @Published var sleepTime: Double = 8.0  // Default sleep time
    
    func fetchEmojiUsage(context: NSManagedObjectContext, startDate: Date, endDate: Date) -> [String: Int] {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp <= %@", startDate as NSDate, endDate as NSDate)
        
        do {
            let items = try context.fetch(fetchRequest)
            var usageData: [String: Int] = [:]
            for item in items {
                if let mood = item.mood {
                    usageData[mood, default: 0] += 1
                }
            }
            return usageData
        } catch {
            print("Failed to fetch emoji usage: \(error)")
            return [:]
        }
    }
    
    func getStartDate(for timeFrame: String) -> Date {
        let calendar = Calendar.current
        let now = Date()
        
        switch timeFrame {
        case "day":
            return calendar.startOfDay(for: now)
        case "week":
            return calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case "month":
            return calendar.date(byAdding: .month, value: -1, to: now) ?? now
        default:
            return now
        }
    }
    
    //Theme Settings
    enum Theme: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case device = "Device"
    }
    
    @Published var selectedTheme: Theme = .device
    
    // Face ID settings
    @Published var isFaceIDEnabled: Bool = false
}
