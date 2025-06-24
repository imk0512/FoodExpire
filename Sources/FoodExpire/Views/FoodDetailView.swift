import SwiftUI
import FirebaseFirestore

struct FoodDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: FoodDetailViewModel
    @State private var showDeleteAlert = false
    @State private var showNameAlert = false
    @State private var showDateAlert = false
    @State private var showLengthAlert = false
    @State private var showUpdatedAlert = false
    @State private var showDeletedAlert = false
    @State private var showUpdateErrorAlert = false
    @State private var showDeleteErrorAlert = false
    @State private var showReRegister = false
    @State private var showAddedAlert = false
    @State private var showAddErrorAlert = false
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

                ZStack(alignment: .topLeading) {
                    if (viewModel.food.note ?? "").isEmpty {
                        Text("開封済み・使い道・保管方法など自由に記入")
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                    }
                    TextEditor(text: Binding(
                        get: { viewModel.food.note ?? "" },
                        set: { viewModel.food.note = $0 }
                    ))
                    .frame(height: 80)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.3))
                    }
                }

                Button("更新") {
                    let trimmed = viewModel.food.name.trimmingCharacters(in: .whitespaces)
                    if trimmed.isEmpty {
                        showNameAlert = true
                    } else if trimmed.count > AppConstants.maxFoodNameLength {
                        showLengthAlert = true
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

                Button("再登録") {
                    showReRegister = true
                }
                .buttonStyle(.bordered)

                Button("買い物リストに追加") {
                    addToShoppingList()
                }
                .buttonStyle(.bordered)

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
        .alert(NSLocalizedString("NameTooLong", comment: ""), isPresented: $showLengthAlert) {}
        .alert("賞味期限が過去の日付です", isPresented: $showDateAlert) {}
        .alert("更新しました", isPresented: $showUpdatedAlert) { Button("OK") { dismiss() } }
        .alert("更新に失敗しました", isPresented: $showUpdateErrorAlert) {}
        .alert("削除に失敗しました", isPresented: $showDeleteErrorAlert) {}
        .alert("追加しました", isPresented: $showAddedAlert) {}
        .alert("追加に失敗しました", isPresented: $showAddErrorAlert) {}
        .sheet(isPresented: $showReRegister) {
            AddFoodView(originalFood: viewModel.food)
        }
    }

    private func addToShoppingList() {
        let data: [String: Any] = [
            "name": viewModel.food.name,
            "createdAt": Timestamp(date: Date()),
            "note": viewModel.food.note ?? "",
            "storageType": "",
            "isChecked": false
        ]
        Firestore.firestore().collection("shoppingList").addDocument(data: data) { error in
            if error != nil {
                showAddErrorAlert = true
            } else {
                showAddedAlert = true
            }
        }
    }
}

#Preview {
    FoodDetailView(food: Food(id: "1", name: "Sample", imageUrl: "", expireDate: Date()))
        .environmentObject(UserSettings())
}
