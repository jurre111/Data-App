import SwiftUI
import Charts
import SwiftData


@Model
final class ChartModel {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var xAxis: String
    var yAxis: String
    var added: Date = Date()
    @Relationship(deleteRule: .cascade) var data: [ChartDataModel]

    init(name: String, xAxis: String, yAxis: String, data: [ChartDataModel]) {
        self.name = name
        self.xAxis = xAxis
        self.yAxis = yAxis
        self.data = data
    }
}


@Model
final class ChartDataModel {
    @Attribute(.unique) var id: UUID = UUID()
    var year: Date
    var value: Double
    
    init(year: Date, value: Double) {
        self.year = year
        self.value = value
    }
}

class AddChartData: ObservableObject, Identifiable {
    @Published var year: Date
    @Published var value: Double
    var id = UUID()
    init(year: Date, value: Double) {
        self.year = year
        self.value = value
    }
}


struct ContentView: View {
    @Query var charts: [ChartModel]
    @State private var showingAddChartView = false
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            if charts.isEmpty {
                VStack {
                    Spacer()
                    Text("No charts available. Please add a chart.")
                    Spacer()
                }
            } else {
                ScrollView {
                    ForEach(charts) { chart in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(chart.name)
                                    .frame(width: 200)
                                    .font(.headline)
                                Spacer()
                                Text(chart.added, format: .dateTime.year().month().day())
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            ChartView(data: chart.data, xName: chart.xAxis, yName: chart.yAxis)
                                .frame(height: 300)
                                .padding()
                        }
                        .padding(.bottom)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color(UIColor.secondarySystemBackground))
                        )
                        .contextMenu {
                            Button(action: {
                                modelContext.delete(chart)
                            }) {
                                Label("Delete", systemImage: "trash")
                                    .foregroundColor(.red)
                            }
                            Button(action: {

                            }) {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddChartView.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddChartView) {
            AddChartView(showingAddChartView: $showingAddChartView)
        }
    }
}

struct ChartView: View {
    var data: [ChartDataModel] = []
    var xName: String = "X-axis"
    var yName: String = "Y-axis"

    var body: some View {
        Chart {
            ForEach(data) {  point in
                LineMark(
                    x: .value(xName, point.year),
                    y: .value(yName, point.value)
                )
            }
        }
    }
}

struct AddChartView: View {
    @State private var chartName: String = ""
    @State private var xAxisName: String = ""
    @State private var yAxisName: String = ""
    @State private var data: [AddChartData] = []
    @Binding var showingAddChartView: Bool
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            Form {
                Section("Chart Details") {
                    TextField("Chart Name", text: $chartName)
                    TextField("X-Axis Name", text: $xAxisName)
                    TextField("Y-Axis Name", text: $yAxisName)
                }
                ForEach($data) { $point in
                    Section(header: Text("Data Point")) {
                        DatePicker("Date", selection: $point.year, displayedComponents: .date)
                        TextField("Value", value: $point.value, format: .number)
                            .keyboardType(.decimalPad)
                    }
                }
                Button(action: {
                    var date = Date()
                    for dataPoinit in data {
                        if dataPoinit.year > date {
                            date = dataPoinit.year
                        }
                    }
                    data.append(AddChartData(year: date.addingTimeInterval(24*60*60), value: 0))
                }) {
                    Label("Add Data Point", systemImage: "plus.circle.fill")
                }
            }
//            ChartView(data: data, xName: xAxisName, yName: yAxisName)
//                .frame(height: 300)
//                .padding()
//                .background(
//                    RoundedRectangle(cornerRadius: 20, style: .continuous)
//                        .fill(Color(UIColor.secondarySystemBackground))
//                )
//                .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingAddChartView.toggle()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let formattedDate = data.map { ChartDataModel(year: $0.year, value: $0.value) }
                        let newChart = ChartModel(name: chartName, xAxis: xAxisName, yAxis: yAxisName, data: formattedDate)
                        modelContext.insert(newChart)
                        showingAddChartView.toggle()
                    }
                }
            }
        }
    }
}

extension Color {
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ChartModel.self, inMemory: true)
}
