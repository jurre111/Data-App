import SwiftUI
import Charts

struct ChartData: Identifiable {
    var year: Int
    var value: Double
    var id = UUID()
}

struct ContentView: View {
    var data: [ChartData] = [
        .init(year: 2021, value: 2.0),
        .init(year: 2022, value: 2.3),
        .init(year: 2023, value: 2.5),
        .init(year: 2024, value: 2.2),
        .init(year: 2025, value: 3.1)
        
    ]
    var name = "Amount of Gun Violence in USA in the last 5 Years"
    var new = true
    var xName = "Time"
    var yName = "Violence"

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text(name)
                        .frame(width: 100)
                        .font(.headline)
                    Circle()
                        .fill(new ? .green : .gray)
                        .frame(width: 10, height: 10)
                }
                ChartView(data: data, xName: xName, yName: yName)
                    .frame(height: 300)
                    .padding()
            }
            .padding(.bottom)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.gray)
            )
        }
        .padding(.leading: 10, .trailing: 10, .top: 0, .bottom: 0)
        .navigationTitle("Home")
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
        .chartXAxisLabel(xName)
        .chartYAxisLabel(yName)
    }
}

#Preview {
    ContentView()
}
