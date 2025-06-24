import SwiftUI

struct FoodDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: FoodDetailViewModel
    @State private var showDeleteAlert = false
    @State private var showNameAlert = false
    @State private var showDateAlert = false
    @State private var showUpdatedAlert = false
    @State private var showDeletedAlert = false
    @State private var showUpdateErrorAlert = false
    @State private var showDeleteErrorAlert = false
    @EnvironmentObject private var userSettings: UserSettings

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
                    if viewModel.food.name.trimmingCharacters(in: .whitespaces).isEmpty {
                        showNameAlert = true
                    } else if Calendar.current.startOfDay(for: viewModel.food.expireDate) < Calendar.current.startOfDay(for: Date()) {
                        showDateAlert = true
                    } else {
                        viewModel.updateFood { error in
                            if error != nil {
                                showUpdateErrorAlert = true
                            } else {
                                showUpdatedAlert = true
                            }
                        }
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("消費済み（削除）", role: .destructive) {
                    showDeleteAlert = true
                }
                .buttonStyle(.bordered)
                .alert("削除してもよろしいですか？", isPresented: $showDeleteAlert) {
                    Button("キャンセル", role: .cancel) {}
                    Button("削除", role: .destructive) {
                        viewModel.deleteFood { error in
                            if error != nil {
                                showDeleteErrorAlert = true
                            } else {
                                showDeletedAlert = true
                            }
                        }
                    }
                } message: {
                    Text("この食品を削除します")
                }
                .alert("削除しました", isPresented: $showDeletedAlert) {
                    Button("OK") { dismiss() }
                }
            }
            .padding()
        }
        .navigationTitle("食品詳細")
        .safeAreaInset(edge: .bottom) {
            if !userSettings.isPremium {
                BannerAdView()
                    .frame(height: 50)
            }
        }
        .alert("食品名を入力してください", isPresented: $showNameAlert) {}
        .alert("賞味期限が過去の日付です", isPresented: $showDateAlert) {}
        .alert("更新しました", isPresented: $showUpdatedAlert) { Button("OK") { dismiss() } }
        .alert("更新に失敗しました", isPresented: $showUpdateErrorAlert) {}
        .alert("削除に失敗しました", isPresented: $showDeleteErrorAlert) {}
    }
}

#Preview {
    FoodDetailView(food: Food(id: "1", name: "Sample", imageUrl: "", expireDate: Date()))
        .environmentObject(UserSettings())
}
