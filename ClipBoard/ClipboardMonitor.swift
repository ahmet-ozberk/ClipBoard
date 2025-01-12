import Foundation
import SwiftData
import AppKit

class ClipboardMonitor {
    private var modelContext: ModelContext?
    private var lastCopiedText: String?
    private var monitor: Any?
    
    init() {
        setupModelContext()
        setupPasteboardMonitoring()
    }
    
    private func setupModelContext() {
        let schema = Schema([ClipboardItem.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            modelContext = ModelContext(container)
        } catch {
            print("Failed to create ModelContainer: \(error)")
        }
    }
    
    private func setupPasteboardMonitoring() {
        NSPasteboard.general.clearContents()
        lastCopiedText = NSPasteboard.general.string(forType: .string)
    }
    
    func startMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkPasteboard()
        }
    }
    
    private func checkPasteboard() {
        guard let clipboard = NSPasteboard.general.string(forType: .string),
              clipboard != lastCopiedText,
              !clipboard.isEmpty else { return }
        
        lastCopiedText = clipboard
        saveClipboardContent(clipboard)
    }
    
    private func saveClipboardContent(_ content: String) {
        guard let modelContext = modelContext else { return }
        
        DispatchQueue.main.async {
            let newItem = ClipboardItem(content: content)
            modelContext.insert(newItem)
            
            do {
                try modelContext.save()
                print("Saved clipboard content: \(content)")
            } catch {
                print("Failed to save clipboard content: \(error)")
            }
        }
    }
} 