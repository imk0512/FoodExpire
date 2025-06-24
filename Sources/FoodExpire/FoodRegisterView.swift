import SwiftUI
import PhotosUI
import FirebaseFirestore
import MLKit

struct FoodRegisterView: View {
    @State private var showPhotoPicker = false
    @State private var showCameraPicker = false
    @State private var selectedImage: UIImage?
    @State private var foodName: String = ""
    @State private var expireText: String = ""
    @State private var showNameAlert = false
    @State private var showDateAlert = false
    @State private var showSavedAlert = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                HStack {
                    Button("写真撮影") {
                        showCameraPicker = true
                    }
                    .padding()
                    Button("写真選択") {
                        showPhotoPicker = true
                    }
                    .padding()
                }

                if let uiImage = selectedImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                }

                TextField("食品名", text: $foodName)
                    .textFieldStyle(.roundedBorder)
                TextField("賞味期限(YYYY/MM/DD)", text: $expireText)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numbersAndPunctuation)

                Button("保存") {
                    saveFood()
                }
                .padding()
                Spacer()
            }
            .padding()
            .navigationTitle("食品登録")
            .photosPicker(isPresented: $showPhotoPicker, selection: .constant(nil))
            .sheet(isPresented: $showCameraPicker) {
                ImagePicker(sourceType: .camera) { image in
                    processImage(image)
                }
            }
            .alert("食品名を入力してください", isPresented: $showNameAlert) {}
            .alert("賞味期限が過去の日付です", isPresented: $showDateAlert) {}
            .alert("保存しました", isPresented: $showSavedAlert) {}
        }
    }

    private func processImage(_ image: UIImage) {
        selectedImage = image
        let visionImage = VisionImage(image: image)
        let textRecognizer = TextRecognizer.textRecognizer()
        textRecognizer.process(visionImage) { result, error in
            guard let result = result, error == nil else { return }
            let text = result.text
            if foodName.isEmpty {
                foodName = parseFoodName(from: text)
            }
            if expireText.isEmpty, let dateStr = parseExpireDateString(from: text) {
                expireText = dateStr
            }
        }
    }

    private func parseFoodName(from text: String) -> String {
        for line in text.components(separatedBy: "\n") {
            if line.rangeOfCharacter(from: .decimalDigits) == nil {
                return line
            }
        }
        return ""
    }

    private func parseExpireDateString(from text: String) -> String? {
        let pattern = "(\\d{4}[/-]\\d{1,2}[/-]\\d{1,2})"
        if let regex = try? NSRegularExpression(pattern: pattern) {
            if let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
                if let range = Range(match.range(at: 1), in: text) {
                    var dateStr = String(text[range])
                    dateStr = dateStr.replacingOccurrences(of: "-", with: "/")
                    return dateStr
                }
            }
        }
        return nil
    }

    private func saveFood() {
        guard !foodName.trimmingCharacters(in: .whitespaces).isEmpty else {
            showNameAlert = true
            return
        }
        guard let date = dateFromString(expireText) else {
            showDateAlert = true
            return
        }
        if Calendar.current.startOfDay(for: date) < Calendar.current.startOfDay(for: Date()) {
            showDateAlert = true
            return
        }
        let db = Firestore.firestore()
        var data: [String: Any] = [
            "name": foodName,
            "expireDate": Timestamp(date: date),
            "createdAt": Timestamp(date: Date()),
            "updatedAt": Timestamp(date: Date())
        ]
        if let image = selectedImage, let imageData = image.jpegData(compressionQuality: 0.8) {
            data["imageUrl"] = imageData.base64EncodedString()
        }
        let ref = db.collection("foods").addDocument(data: data)
        let newFood = Food(id: ref.documentID, name: foodName, imageUrl: data["imageUrl"] as? String ?? "", expireDate: date)
        NotificationManager.shared.scheduleNotification(for: newFood)
        foodName = ""
        expireText = ""
        selectedImage = nil
        showSavedAlert = true
    }

    private func dateFromString(_ str: String) -> Date? {
        DateFormatter.expireFormatter.date(from: str)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    var completion: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.completion(image)
            }
            picker.dismiss(animated: true)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    FoodRegisterView()
}
