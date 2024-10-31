import SwiftUI

struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.move(to: center)
        path.addArc(center: center,
                   radius: radius,
                   startAngle: startAngle - .degrees(90),
                   endAngle: endAngle - .degrees(90),
                   clockwise: false)
        path.closeSubpath()
        
        return path
    }
}

struct PieChartView: View {
    let expenses: [Category: Double]
    let colors: [Category: Color] = [
        .food: .blue,
        .transportation: .green,
        .entertainment: .orange,
        .utilities: .purple,
        .housing: .pink,
        .healthcare: .red,
        .other: .gray
    ]
    
    private var total: Double {
        expenses.values.reduce(0, +)
    }
    
    private var slices: [(Category, Double)] {
        expenses.filter { $0.value > 0 }
            .sorted { $0.value > $1.value }
    }
    
    var body: some View {
        VStack {
            ZStack {
                ForEach(0..<slices.count, id: \.self) { index in
                    let value = slices[index].1
                    let category = slices[index].0
                    let percentage = value / total
                    let startAngle: Double = index == 0 ? 0 : slices[0..<index].map { $0.1 }.reduce(0, +) / total * 360
                    let endAngle = startAngle + (percentage * 360)
                    
                    PieSlice(startAngle: .degrees(startAngle),
                            endAngle: .degrees(endAngle))
                        .fill(colors[category, default: .gray])
                }
            }
            .frame(width: 200, height: 200)
            .padding()
            
            VStack(alignment: .leading) {
                ForEach(slices, id: \.0) { category, value in
                    HStack {
                        Circle()
                            .fill(colors[category, default: .gray])
                            .frame(width: 10, height: 10)
                        Text(category.rawValue)
                        Spacer()
                        Text(String(format: "%.1f%%", (value / total) * 100))
                    }
                }
            }
            .padding()
        }
    }
}
