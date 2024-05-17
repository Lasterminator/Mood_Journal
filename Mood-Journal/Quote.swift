import Foundation

struct Quote: Codable, Identifiable {
    let id = UUID()
    let content: String
    let author: String?
    
    enum CodingKeys: String, CodingKey {
        case content = "content"
        case author = "author"
    }
}
