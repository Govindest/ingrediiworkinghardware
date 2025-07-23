import Foundation

extension DateFormatter {
  static let shortDate: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .short
    df.timeStyle = .none
    return df
  }()
}
