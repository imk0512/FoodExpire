import SwiftUI

struct AddFoodView: View {
    var originalFood: Food? = nil
    var body: some View {
        FoodRegisterView(originalFood: originalFood)
    }
}

#Preview {
    AddFoodView()
}

