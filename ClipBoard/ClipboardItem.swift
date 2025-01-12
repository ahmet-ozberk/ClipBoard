import Foundation
import SwiftData

@Model
final class ClipboardItem {
    var content: String
    var timestamp: Date
    
    init(content: String, timestamp: Date = Date()) {
        self.content = content
        self.timestamp = timestamp
    }
} 