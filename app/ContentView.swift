import SwiftUI
import Charts
import SwiftData


@Model
final class ChartModel {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var xAxis: String
    var yAxis: String
    var new: Bool
    @Relationship(deleteRule: .cascade) var data: [ChartDataModel]

    init(name: String, xAxis: String, yAxis: String, new: Bool, data: [ChartDataModel]) {
        self.name = name
        self.xAxis = xAxis
        self.yAxis = yAxis
        self.new = new
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

struct AddChartData: Identifiable {
    var year: Date
    var value: Double
    var id = UUID()
}

struct ContentView: View {
    @Query var charts: [ChartModel]
    @State private var showingAddChartView = false

    var body: some View {
        NavigationStack {
            ScrollView {
                if charts.isEmpty {
                    VStack {
                        Spacer()
                        Text("No charts available. Please add a chart.")
                        Spacer()
                    }
                } else {
                    ForEach(charts) { chart in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(chart.name)
                                    .frame(width: 200)
                                    .font(.headline)
                                Spacer()
                                Circle()
                                    .fill(chart.new ? .green : .gray)
                                    .frame(width: 10, height: 10)
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
        .chartXAxis {
            AxisMarks(values: .stride(by: .year)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.year()) // only show year
            }
        }
    }
}

struct AddChartView: View {
    @State private var chartName: String = "Name"
    @State private var xAxisName: String = "X-axis Name"
    @State private var yAxisName: String = "Y-axis Name"
    @State private var data: [ChartDataModel] = []
    @Binding var showingAddChartView: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Chart Details")) {
                    TextField("Chart Name", text: $chartName)
                    TextField("X-Axis Name", text: $xAxisName)
                    TextField("Y-Axis Name", text: $yAxisName)
                }
                ForEach($data) { $point in
                    Section(header: Text("Data Point")) {
                        DatePicker("Year", selection: $point.year, displayedComponents: .date)
                        TextField("Value", value: $point.value, format: .number)
                            .keyboardType(.decimalPad)
                    }
                }
                Button(action: {
                    data.append(ChartDataModel(year: Date(), value: 0.0))
                }) {
                    Label("Add Data Point", systemImage: "plus.circle.fill")
                }
            }
            ChartView(data: data, xName: xAxisName, yName: yAxisName)
                .frame(height: 300)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
                .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingAddChartView.toggle()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // save action
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
