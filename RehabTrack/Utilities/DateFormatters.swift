import Foundation

extension Date {
    var shortDateString: String {
        formatted(date: .abbreviated, time: .omitted)
    }

    var timeString: String {
        formatted(date: .omitted, time: .shortened)
    }

    var dateTimeString: String {
        formatted(date: .abbreviated, time: .shortened)
    }

    var relativeDateString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
