import SwiftUI

struct ProviderMessagesView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(DataManager.self) private var dataManager
    @State private var viewModel: ProviderMessagesViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    if viewModel.selectedPatient == nil {
                        // Patient Picker
                        List(viewModel.patients, id: \.id) { patient in
                            Button {
                                viewModel.selectedPatient = patient
                                viewModel.markAsRead()
                            } label: {
                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundStyle(AppConstants.Colors.primary)

                                    VStack(alignment: .leading) {
                                        Text(patient.user.name)
                                            .font(.body)
                                            .fontWeight(.medium)
                                        if let lastMessage = patient.messages.sorted(by: { $0.sentAt > $1.sentAt }).first {
                                            Text(lastMessage.content)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                                .lineLimit(1)
                                        }
                                    }

                                    Spacer()

                                    let unread = viewModel.unreadCount(patient)
                                    if unread > 0 {
                                        Text("\(unread)")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.white)
                                            .frame(width: 22, height: 22)
                                            .background(AppConstants.Colors.primary)
                                            .clipShape(Circle())
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .navigationTitle("Messages")
                    } else {
                        // Chat View
                        VStack(spacing: 0) {
                            ScrollViewReader { proxy in
                                ScrollView {
                                    LazyVStack(spacing: 8) {
                                        ForEach(viewModel.messages, id: \.id) { message in
                                            MessageBubbleView(
                                                message: message,
                                                isFromCurrentUser: message.senderRole == .provider
                                            )
                                            .id(message.id)
                                        }
                                    }
                                    .padding()
                                }
                                .onChange(of: viewModel.messages.count) {
                                    if let lastMessage = viewModel.messages.last {
                                        withAnimation {
                                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                        }
                                    }
                                }
                            }

                            Divider()

                            HStack(spacing: 8) {
                                TextField("Type a message...", text: Bindable(viewModel).messageText, axis: .vertical)
                                    .lineLimit(1...4)
                                    .textFieldStyle(.roundedBorder)

                                Button {
                                    viewModel.sendMessage()
                                } label: {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.title2)
                                }
                                .disabled(viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                            .padding()
                        }
                        .navigationTitle(viewModel.selectedPatient?.user.name ?? "Chat")
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button("Back", systemImage: "chevron.left") {
                                    viewModel.selectedPatient = nil
                                }
                            }
                        }
                    }
                } else {
                    ContentUnavailableView("Loading...", systemImage: "hourglass")
                }
            }
            .onAppear {
                if let provider = authViewModel.currentProvider {
                    viewModel = ProviderMessagesViewModel(provider: provider, dataManager: dataManager)
                }
            }
        }
    }
}
