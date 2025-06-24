import SwiftUI

struct FoodDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: FoodDetailViewModel
    @State private var showDeleteAlert = false

    init(food: Food) {
        _viewModel = StateObject(wrappedValue: FoodDetailViewModel(food: food))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                AsyncImage(url: URL(string: viewModel.food.imageUrl)) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Color.gray
                }
                .frame(height: 200)

                TextField("食品名", text: $viewModel.food.name)
                    .textFieldStyle(.roundedBorder)

                DatePicker("賞味期限", selection: $viewModel.food.expireDate, displayedComponents: .date)
                    .datePickerStyle(.compact)

                Button("更新") {
                    viewModel.updateFood()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)

                Button("消費済み（削除）", role: .destructive) {
                    showDeleteAlert = true
                }
                .buttonStyle(.bordered)
                .alert("削除してもよろしいですか？", isPresented: $showDeleteAlert) {
                    Button("キャンセル", role: .cancel) {}
                    Button("削除", role: .destructive) {
                        viewModel.deleteFood()
                        dismiss()
                    }
                } message: {
                    Text("この食品を削除します")
                }
            }
            .padding()
        }
        .navigationTitle("食品詳細")
    }
}

#Preview {
    FoodDetailView(food: Food(id: "1", name: "Sample", imageUrl: "", expireDate: Date()))
}
