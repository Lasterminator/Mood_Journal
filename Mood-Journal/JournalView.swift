import SwiftUI
import CoreData

struct JournalView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var globalData: GlobalData
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @State private var selectedMood: String? = "happy"  // Default to "happy"
    @State private var notes: String = "None"           // Default to "None"
    @State private var date = Date()
    @State private var showAddItemSheet = false
    @State private var showEditItemSheet = false
    @State private var itemToEdit: Item? = nil
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"  // Include seconds in format
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink(destination: EditEntryView(item: item)) {
                        VStack(alignment: .leading) {
                            Text(item.notes ?? "No Notes")
                            Text(item.mood ?? "No Mood")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: { showAddItemSheet = true }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("Journal")
            .sheet(isPresented: $showAddItemSheet) {
                addItemView()
            }
        }
    }

    private func addItemView() -> some View {
        NavigationView {
            Form {
                Section(header: Text("Notes")) {
                    TextField("Enter your notes", text: $notes)
                }
                
                Section(header: Text("Mood")) {
                    Picker("Select your mood", selection: $selectedMood) {
                        ForEach(globalData.emojis.keys.sorted(), id: \.self) { key in
                            HStack {
                                Text(globalData.emojis[key]!)
                                Text(key.capitalized)
                            }
                            .tag(key as String?)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
                
                Section(header: Text("Date")) {
                    DatePicker("Select date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(WheelDatePickerStyle())
                }
            }
            .navigationTitle("New Journal Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showAddItemSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        addItem()
                        showAddItemSheet = false
                    }
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = date
            newItem.notes = notes.isEmpty ? "No Notes" : notes
            if let selectedMood = selectedMood, let emoji = globalData.emojis[selectedMood] {
                newItem.mood = "\(emoji) \(selectedMood.capitalized)"
            } else {
                newItem.mood = "No Mood"
            }

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

#Preview {
    JournalView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(GlobalData())
}
