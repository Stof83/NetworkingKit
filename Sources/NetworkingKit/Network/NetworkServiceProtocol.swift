//
//  NetworkServiceProtocol.swift
//  NetworkingKit
//
//  Created by El Mostafa El Ouatri on 08/12/24.
//

import Combine
import Foundation

/// A protocol defining the contract for a network service.
public protocol NetworkServiceProtocol: AnyObject {
    /// Performs an asynchronous network request using async/await.
    ///
    /// - Parameters:
    ///   - request: The `APIRequestable` defining the request to perform.
    ///   - parameters: Additional parameters to include in the request.
    ///   - method: The HTTP method of the request (e.g., GET, POST).
    /// - Returns: An `APIDataResponse` containing the response or an error.
    func request<T: Sendable>(
        _ request: APIRequestable,
        with parameters: [String: Any]?,
        method: HTTPMethod
    ) async throws -> APIDataResponse<T>
    
    /// Performs a network request using Combine.
    ///
    /// - Parameters:
    ///   - request: The `APIRequestable` defining the request to perform.
    ///   - parameters: Additional parameters to include in the request.
    ///   - method: The HTTP method of the request (e.g., GET, POST).
    /// - Returns: A publisher emitting an `APIDataResponse` or a default error response.
    func request<T: Sendable>(
        _ request: APIRequestable,
        with parameters: [String: Any]?,
        method: HTTPMethod
    ) -> AnyAPIDataResponse<T>
}
