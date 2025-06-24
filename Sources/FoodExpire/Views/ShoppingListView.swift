import SwiftUI

struct ShoppingListView: View {
    @StateObject private var viewModel = ShoppingListViewModel()

    private var uncheckedItems: [ShoppingItem] {
        viewModel.items.filter { !$0.isChecked }
    }

    private var checkedItems: [ShoppingItem] {
        viewModel.items.filter { $0.isChecked }
    }

    var body: some View {
        List {
            ForEach(uncheckedItems) { item in
                row(for: item)
            }
            if !checkedItems.isEmpty {
                Section("購入済み") {
                    ForEach(checkedItems) { item in
                        row(for: item)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .listStyle(.plain)
        .padding(.vertical, 8)
        .navigationTitle("買い物リスト")
        .onAppear { viewModel.fetchItems() }
        .alert("データの取得に失敗しました", isPresented: $viewModel.fetchError) {}
    }

    @ViewBuilder
    private func row(for item: ShoppingItem) -> some View {
        HStack {
            Button(action: { viewModel.toggleChecked(item) }) {
                Image(systemName: item.isChecked ? "checkmark.square" : "square")
            }
            .buttonStyle(.plain)
            VStack(alignment: .leading) {
                Text(item.name)
                    .bodyFont()
                Text(DateFormatter.expireFormatter.string(from: item.createdAt))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .swipeActions {
            Button(role: .destructive) {
                viewModel.deleteItem(item)
            } label: {
                Label("削除", systemImage: "trash")
            }
        }
    }
}

#Preview {
    NavigationStack { ShoppingListView() }
}
