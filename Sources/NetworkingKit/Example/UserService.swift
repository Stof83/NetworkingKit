//
//  UserService.swift
//  NetworkingKit
//
//  Created by El Mostafa El Ouatri on 14/12/24.
//


class UserService {
    private let apiClientManager = APIClientManager()
    
    func fetchUserDetails(userId: String) async throws -> User? {
        let endpoint = UserAPI.fetchUserDetails(userId)
        return try await apiClientManager.request(for: endpoint, method: .get)
    }
    
    func updateUserDetails(userId: String, userDetails: UserUpdateRequest) async throws -> User? {
        let endpoint = UserAPI.updateUserDetails(userId)
        return try await apiClientManager.request(for: endpoint, with: userDetails, method: .put)
    }
}

// Usage Example
struct User: Decodable {
    let id: String
    let name: String
    let email: String
}

struct UserUpdateRequest: Encodable {
    let name: String
    let email: String
}

let userService = UserService()

func fetchUserDetails() {
    Task {
        do {
            if let user = try await userService.fetchUserDetails(userId: "12345") {
                print("User Details: \(user)")
            }
        } catch {
            print("Error: \(error)")
        }
    }
}

func updatedUserDetails() {
    Task {
        do {
            let updatedUserDetails = UserUpdateRequest(name: "New Name", email: "new.email@example.com")
            if let updatedUser = try await userService.updateUserDetails(userId: "12345", userDetails: updatedUserDetails) {
                print("Updated User: \(updatedUser)")
            }
        } catch {
            print("Error: \(error)")
        }
    }
}
