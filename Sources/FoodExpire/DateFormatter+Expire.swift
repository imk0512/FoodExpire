import Foundation

extension DateFormatter {
    static let expireFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy/MM/dd"
        return f
    }()
}
