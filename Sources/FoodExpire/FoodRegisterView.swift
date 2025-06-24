import SwiftUI
import PhotosUI
import FirebaseFirestore
import MLKit
import AVFoundation
import UIKit

struct FoodRegisterView: View {
    private let maxNameLength = AppConstants.maxFoodNameLength
    let originalFood: Food?

    @State private var showPhotoPicker = false
    @State private var showCameraPicker = false
    @State private var selectedImage: UIImage?
    @State private var foodName: String
    @State private var expireText: String
    @State private var note: String
    @State private var showNameAlert = false
    @State private var showDateAlert = false
    @State private var showSavedAlert = false
    @State private var showSaveErrorAlert = false
    @State private var showOCRAlert = false
    @State private var showCameraPermissionAlert = false
    @State private var showPhotoPermissionAlert = false
    @State private var showLengthAlert = false

    init(originalFood: Food? = nil) {
        self.originalFood = originalFood
        if let food = originalFood {
            _foodName = State(initialValue: food.name)
            _note = State(initialValue: food.note ?? "")
            _expireText = State(initialValue: "")
            if let data = Data(base64Encoded: food.imageUrl),
               let uiImage = UIImage(data: data) {
                _selectedImage = State(initialValue: uiImage)
            } else {
                _selectedImage = State(initialValue: nil)
            }
        } else {
            _foodName = State(initialValue: "")
            _note = State(initialValue: "")
            _expireText = State(initialValue: "")
            _selectedImage = State(initialValue: nil)
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                if originalFood != nil {
                    Text("再登録モード")
                        .font(.caption)
                        .padding(4)
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                HStack {
                    Button("写真撮影") {
                        checkCameraPermission()
                    }
                    .padding()
                    Button("写真選択") {
                        checkPhotoPermission()
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

                ZStack(alignment: .topLeading) {
                    if note.isEmpty {
                        Text("開封済み・使い道・保管方法など自由に記入")
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                    }
                    TextEditor(text: $note)
                        .frame(height: 80)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.3))
                        }
                }

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
            .alert("保存に失敗しました", isPresented: $showSaveErrorAlert) {}
            .alert("文字認識に失敗しました。手入力してください", isPresented: $showOCRAlert) {}
            .alert("カメラのアクセスが許可されていません。設定から許可してください", isPresented: $showCameraPermissionAlert) {
                Button("設定を開く") { openSettings() }
                Button("OK", role: .cancel) {}
            }
            .alert("写真へのアクセスが許可されていません。設定から許可してください", isPresented: $showPhotoPermissionAlert) {
                Button("設定を開く") { openSettings() }
                Button("OK", role: .cancel) {}
            }
            .alert(NSLocalizedString("NameTooLong", comment: ""), isPresented: $showLengthAlert) {}
        }
    }

    private func processImage(_ image: UIImage) {
        selectedImage = image
        let visionImage = VisionImage(image: image)
        let textRecognizer = TextRecognizer.textRecognizer()
        textRecognizer.process(visionImage) { result, error in
            guard let result = result, error == nil else {
                showOCRAlert = true
                return
            }
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
        let trimmed = foodName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            showNameAlert = true
            return
        }
        guard trimmed.count <= maxNameLength else {
            showLengthAlert = true
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
            "updatedAt": Timestamp(date: Date()),
            "note": note
        ]
        if let image = selectedImage, let imageData = image.jpegData(compressionQuality: 0.8) {
            data["imageUrl"] = imageData.base64EncodedString()
        }
        let ref = db.collection("foods").addDocument(data: data) { error in
            if error != nil {
                showSaveErrorAlert = true
                return
            }
            let newFood = Food(id: ref.documentID, name: foodName, imageUrl: data["imageUrl"] as? String ?? "", expireDate: date, note: note.isEmpty ? nil : note)
            NotificationManager.shared.scheduleNotification(for: newFood)
            foodName = ""
            expireText = ""
            selectedImage = nil
            note = ""
            showSavedAlert = true
        }
    }

    private func dateFromString(_ str: String) -> Date? {
        DateFormatter.expireFormatter.date(from: str)
    }

    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showCameraPicker = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted { showCameraPicker = true } else { showCameraPermissionAlert = true }
            }
        default:
            showCameraPermissionAlert = true
        }
    }

    private func checkPhotoPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            showPhotoPicker = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                if newStatus == .authorized || newStatus == .limited {
                    showPhotoPicker = true
                } else {
                    showPhotoPermissionAlert = true
                }
            }
        default:
            showPhotoPermissionAlert = true
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
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
