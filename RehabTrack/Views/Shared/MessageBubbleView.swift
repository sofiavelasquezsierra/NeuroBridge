import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    let isFromCurrentUser: Bool

    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer(minLength: 60) }

            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(isFromCurrentUser ? AppConstants.Colors.primary : Color(.systemGray5))
                    .foregroundStyle(isFromCurrentUser ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                Text(message.sentAt.relativeDateString)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            if !isFromCurrentUser { Spacer(minLength: 60) }
        }
    }
}
