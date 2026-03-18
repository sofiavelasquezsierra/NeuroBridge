import SwiftUI

struct PatientMessagesView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(DataManager.self) private var dataManager
    @State private var viewModel: PatientMessagesViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    VStack(spacing: 0) {
                        // Messages List
                        ScrollViewReader { proxy in
                            ScrollView {
                                LazyVStack(spacing: 8) {
                                    ForEach(viewModel.messages, id: \.id) { message in
                                        MessageBubbleView(
                                            message: message,
                                            isFromCurrentUser: message.senderRole == .patient
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

                        // Message Input
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
                } else {
                    ContentUnavailableView("Loading...", systemImage: "hourglass")
                }
            }
            .navigationTitle("Messages")
            .onAppear {
                if let patient = authViewModel.currentPatient {
                    viewModel = PatientMessagesViewModel(patient: patient, dataManager: dataManager)
                    viewModel?.markAsRead()
                }
            }
        }
    }
}
