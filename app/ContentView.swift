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
    var data: [ChartData]

    init(name: String, xAxis: String, yAxis: String, new: Bool, data: [ChartData]) {
        self.name = name
        self.xAxis = xAxis
        self.yAxis = yAxis
        self.new = new
        self.data = data
    }
}


struct ChartData: Identifiable {
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
                        showingAddChartView = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingAddChartView) {
            AddChartView()
        }
    }
}

struct ChartView: View {
    var data: [ChartData]
    var xName: String
    var yName: String

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
    var body: some View {
        VStack {
            Spacer()
            Text("Add Chart View")
            Spacer()
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
