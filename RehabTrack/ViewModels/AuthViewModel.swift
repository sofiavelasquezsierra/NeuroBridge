import Foundation
import SwiftData

@Observable
final class AuthViewModel {
    var currentUser: User?
    var isLoggedIn: Bool { currentUser != nil }

    var currentPatient: Patient? {
        currentUser?.patientProfile
    }

    var currentProvider: Provider? {
        currentUser?.providerProfile
    }

    var isPatient: Bool {
        currentUser?.role == .patient
    }

    var isProvider: Bool {
        currentUser?.role == .provider
    }

    func login(as user: User) {
        currentUser = user
    }

    func logout() {
        currentUser = nil
    }
}
