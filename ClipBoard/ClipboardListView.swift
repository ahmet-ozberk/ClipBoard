import SwiftData
import SwiftUI

struct ClipboardListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ClipboardItem.timestamp, order: .reverse) private var items:
        [ClipboardItem]
    @State private var showAlert = false
    @State private var itemsToShow: [ClipboardItem] = []

    var body: some View {
        VStack(spacing: 0) {
            if items.isEmpty {
                Text("Kopyalanan öğeler burada görünecek")
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(
                        maxWidth: .infinity, maxHeight: .infinity,
                        alignment: .center)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(items) { item in
                            Button(action: {
                                copyToClipboard(item.content)
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.content)
                                        .lineLimit(2)
                                    Text(item.timestamp.formatted())
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding([.top, .trailing], 8)
                                .padding(.bottom, 4)
                                .padding(.leading, 12)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .buttonStyle(.plain)

                            if item.id != items.last?.id {
                                Divider()
                                    .frame(height: 0.6)
                                    .padding(.leading, 12)
                            }
                        }
                        .onDelete(perform: deleteItems)
                        .deleteDisabled(items.isEmpty)
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                }
            }

            Divider()
            if showAlert {
                HStack(alignment: .center) {
                    Text(
                        "Tüm öğeleri silmek istediğinizden emin misiniz?"
                    ).font(.caption)
                    Spacer()
                    HStack {
                        Button(action: {
                            showAlert = false
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.secondary)
                        }.buttonStyle(.plain).foregroundColor(.secondary)
                        Button(action: {
                            deleteAllItems()
                            showAlert = false
                        }) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.red)
                        }.buttonStyle(.plain)
                            .foregroundColor(.red)
                    }
                }.padding(.all, 8)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                HStack(alignment: .center) {
                    Image("clipboard-icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .padding(.leading, 12)
                    Text("by Ahmet OZBERK")
                        .font(.caption)
                    Spacer()
                    Button(action: {
                        NSApplication.shared.terminate(nil)
                    }) {
                        Image(systemName: "power")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 8)
                    if !items.isEmpty {
                        Button(action: {
                            showAlert = true
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, 8)
                    }
                    Spacer().frame(width: 8)
                }
            }
        }
        .frame(width: 300, height: 400)
    }

    private func copyToClipboard(_ content: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(content, forType: .string)
        NSApplication.shared.hide(nil)
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation(.linear) {
            for index in offsets {
                modelContext.delete(items[index])
            }
            try? modelContext.save()
        }
    }

    private func deleteAllItems() {
        withAnimation(.linear) {
            items.forEach { item in
                modelContext.delete(item)
            }
            try? modelContext.save()
        }
    }
}
