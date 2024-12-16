//
//  HTTPRequestPayload.swift
//  NetworkingKit
//
//  Created by El Mostafa El Ouatri on 09/12/24.
//

import Alamofire
import Foundation

public typealias Parameters = [String: any Any & Sendable]

/// An enumeration representing HTTP methods.
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
    case head = "HEAD"
    case options = "OPTIONS"
    case trace = "TRACE"
    case connect = "CONNECT"
    
    // MARK: - Computed Properties
    
    /// Checks if the method is GET.
    var isGET: Bool {
        self == .get
    }
    
    /// Checks if the method is POST.
    var isPOST: Bool {
        self == .post
    }
    
    /// Checks if the method is PUT.
    var isPUT: Bool {
        self == .put
    }
    
    /// Checks if the method is DELETE.
    var isDELETE: Bool {
        self == .delete
    }
    
    /// Checks if the method is considered safe.
    /// - Safe methods do not modify the state on the server (e.g., GET, HEAD, OPTIONS).
    var isSafe: Bool {
        self == .get || self == .head || self == .options
    }
    
    /// Checks if the method is idempotent.
    /// - Idempotent methods can be repeated without changing the state of the resource beyond the initial application (e.g., GET, PUT, DELETE, HEAD, OPTIONS, TRACE).
    var isIdempotent: Bool {
        switch self {
        case .get, .put, .delete, .head, .options, .trace:
            return true
        case .post, .patch, .connect:
            return false
        }
    }
    
    /// Checks if the method supports caching by default.
    /// - Typically, methods like GET, HEAD, and OPTIONS support caching.
    var isCacheable: Bool {
        self == .get || self == .head || self == .options
    }
    
    /// Checks if the method is used for modifying state on the server.
    /// - State-modifying methods include POST, PUT, PATCH, and DELETE.
    var modifiesState: Bool {
        switch self {
        case .post, .put, .patch, .delete:
            return true
        default:
            return false
        }
    }
}


public struct EmptyParameters: Encodable & Sendable {}

/// A struct to hold HTTP method and parameters.
public struct HTTPRequestPayload<Parameters: Encodable & Sendable> {
    var parameters: Parameters? = nil
    var method: HTTPMethod = .get
}
