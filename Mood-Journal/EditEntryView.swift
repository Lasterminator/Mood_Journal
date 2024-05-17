import SwiftUI
import CoreData

struct EditEntryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var item: Item
    
    @State private var notes: String
    @State private var selectedMood: String?
    @State private var date: Date
    
    @EnvironmentObject var globalData: GlobalData
    @Environment(\.presentationMode) private var presentationMode

    init(item: Item) {
        self.item = item
        _notes = State(initialValue: item.notes ?? "")
        _selectedMood = State(initialValue: item.mood)
        _date = State(initialValue: item.timestamp ?? Date())
    }

    var body: some View {
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
            
            Button("Save") {
                saveChanges()
                presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationTitle("Edit Entry")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    private func saveChanges() {
        item.notes = notes
        if let selectedMood = selectedMood, let emoji = globalData.emojis[selectedMood] {
            item.mood = "\(emoji) \(selectedMood.capitalized)"
        } else {
            item.mood = "No Mood"
        }
        item.timestamp = date

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let newItem = Item(context: context)
    newItem.notes = "Sample Notes"
    newItem.mood = "😊 Happy"
    newItem.timestamp = Date()

    return EditEntryView(item: newItem)
        .environment(\.managedObjectContext, context)
        .environmentObject(GlobalData())
}
