import SwiftUI
import Charts

struct StatsView: View {
    @EnvironmentObject var globalData: GlobalData
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTimeFrame: String = "day"
    @State private var customStartDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    @State private var customEndDate: Date = Date()
    @State private var usageData: [String: Int] = [:]

    var body: some View {
        VStack {
            Text("Stats")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Picker("Select Time Frame", selection: $selectedTimeFrame) {
                Text("Day").tag("day")
                Text("Week").tag("week")
                Text("Month").tag("month")
//                Text("Custom").tag("custom")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .onChange(of: selectedTimeFrame, perform: { _ in fetchUsageData() })

            if selectedTimeFrame == "custom" {
                DatePicker("Start Date", selection: $customStartDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .padding()
                    .onChange(of: customStartDate, perform: { _ in fetchUsageData() })

                DatePicker("End Date", selection: $customEndDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .padding()
                    .onChange(of: customEndDate, perform: { _ in fetchUsageData() })
            }

            generateChart(usageData: usageData)
        }
        .padding()
        .onAppear(perform: fetchUsageData)
    }

    private func fetchUsageData() {
        let startDate: Date
        let endDate = Date()

        if selectedTimeFrame == "custom" {
            startDate = customStartDate
        } else {
            startDate = globalData.getStartDate(for: selectedTimeFrame)
        }

        usageData = globalData.fetchEmojiUsage(context: viewContext, startDate: startDate, endDate: endDate)
    }

    private func generateChart(usageData: [String: Int]) -> some View {
        Chart {
            ForEach(usageData.keys.sorted(), id: \.self) { key in
                BarMark(
                    x: .value("Usage", usageData[key] ?? 0),
                    y: .value("Emoji", globalData.emojis[key] ?? key)
                )
                .foregroundStyle(by: .value("Emoji", key))
                .annotation(position: .top, alignment: .center) {
                    Text("\(usageData[key] ?? 0)")
                        .font(.caption)
                }
            }
        }
        .frame(height: 300)
        .padding()
    }
}

#Preview {
    StatsView()
        .environmentObject(GlobalData())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
