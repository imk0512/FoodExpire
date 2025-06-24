import SwiftUI

struct FoodCardView: View {
    let food: Food

    private var remainingDays: Int {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: food.expireDate).day ?? 0
        return days
    }

    private var color: Color {
        if remainingDays < 0 {
            return .red
        }
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
                    .titleFont()
                Text(dateString)
                    .bodyFont()
                Text("残り\(remainingDays)日")
                    .font(.caption)
            }
            Spacer()
        }
        .padding(8)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(alignment: .topTrailing) {
            if let storage = food.storageType, !storage.isEmpty {
                Text(storage)
                    .font(.caption2)
                    .padding(4)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                    .padding(4)
            }
        }
    }

    private var dateString: String {
        DateFormatter.expireFormatter.string(from: food.expireDate)
    }

    private var backgroundColor: Color {
        if remainingDays < 0 {
            return Color.red.opacity(0.2)
        }
        return color.opacity(0.2)
    }
}

#Preview {
    FoodCardView(food: Food(id: "1", name: "Sample", imageUrl: "", expireDate: Date().addingTimeInterval(86400*5)))
}

