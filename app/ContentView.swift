import SwiftUI
import Charts

struct ChartData: Identifiable {
    var year: Date
    var value: Double
    var id = UUID()
}

struct ContentView: View {
    let data: [ChartData] = [
        ChartData(year: Calendar.current.date(from: DateComponents(year: 2021))!, value: 2.0),
        ChartData(year: Calendar.current.date(from: DateComponents(year: 2022))!, value: 2.3),
        ChartData(year: Calendar.current.date(from: DateComponents(year: 2023))!, value: 2.5),
        ChartData(year: Calendar.current.date(from: DateComponents(year: 2024))!, value: 2.2),
        ChartData(year: Calendar.current.date(from: DateComponents(year: 2025))!, value: 3.1)
    ]

    let name = "Amount of Gun Violence in USA in the last 5 Years"
    let new = true
    let xName = "Time"
    let yName = "Violence"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        Text(name)
                            .frame(width: 200)
                            .font(.headline)
                        Spacer()
                        Circle()
                            .fill(new ? .green : .gray)
                            .frame(width: 10, height: 10)
                    }
                    .padding()
                    ChartView(data: data, xName: xName, yName: yName)
                        .frame(height: 300)
                        .padding()
                }
                .padding(.bottom)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
            }
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .navigationTitle("Home")
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
        .chartXScale(domain: data.map(\.year).min()!...data.map(\.year).max()!)
        .chartXAxis {
            AxisMarks(values: .stride(by: .year)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.year()) // only show year
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
}
