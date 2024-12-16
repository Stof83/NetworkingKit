//
//  UserAPI.swift
//  NetworkingKit
//
//  Created by El Mostafa El Ouatri on 14/12/24.
//

import Foundation

enum UserAPI {
    case fetchUserDetails(String)
    case updateUserDetails(String)
}

extension UserAPI: APIRequestable {
    
    var baseURL: URL? {
        URL(string: "https://api.example.com")
    }
    
    var apiVersion: String {
        "v1/users"
    }

    var path: String {
        switch self {
            case .fetchUserDetails(let userId):
                return "\(userId)"
            case .updateUserDetails(let userId):
                return "\(userId)/update"
        }
    }
    
    var headers: HTTPHeaders {
        ["Authorization": "Bearer token", "Accept": "application/json"]
    }
}
