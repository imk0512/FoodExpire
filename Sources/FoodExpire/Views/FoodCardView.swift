import SwiftUI

struct FoodCardView: View {
    let food: Food

    private var remainingDays: Int {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: food.expireDate).day ?? 0
        return days
    }

    private var color: Color {
        switch remainingDays {
        case ...3:
            return .red
        case 4...7:
            return .yellow
        default:
            return .green
        }
    }

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: food.imageUrl)) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(food.name)
                    .font(.headline)
                Text(dateString)
                    .font(.subheadline)
                Text("残り\(remainingDays)日")
                    .font(.caption)
            }
            Spacer()
        }
        .padding(8)
        .background(color.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: food.expireDate)
    }
}

#Preview {
    FoodCardView(food: Food(id: "1", name: "Sample", imageUrl: "", expireDate: Date().addingTimeInterval(86400*5)))
}

