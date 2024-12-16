//
//  APIClientManager.swift
//  NetworkingKit
//
//  Created by El Mostafa El Ouatri on 30/09/24.
//

import Foundation
import Combine

/// A manager class that provides an interface between the APIClient and the network service.
/// It facilitates making network requests through the APIClient and manages responses.
class APIClientManager {
    private let apiClient: APIClient
    
    /// Initializes a new instance of `APIClientManager`.
    ///
    /// This initializer configures the `APIClient` with an instance of `AFNetworkService` using default settings.
    public init() {
        self.apiClient = APIClient(with: AFNetworkService(configuration: .init()))
    }
    
    /// Performs a network request and returns a decoded response of the specified type.
    ///
    /// - Parameters:
    ///   - endpoint: The API endpoint defining the request details.
    ///   - parameters: The parameters to include in the request (optional).
    ///   - method: The HTTP method to use for the request.
    /// - Returns: The decoded response data of type `Response`.
    /// - Throws: An error if the request fails or the response is invalid.
    func request<Parameters: Encodable & Sendable, Response: Decodable>(
        for endpoint: APIRequestable,
        with parameters: Parameters? = Empty?.none,
        method: HTTPMethod
    ) async throws -> Response? {
        do {
            // Perform the request using the APIClient.
            let response: APIDataResponse<DefaultNetworkResponse<Response>> = try await apiClient.request(
                for: endpoint,
                with: parameters,
                method: method
            )
            
            // Validate the HTTP status code.
            guard response.response?.statusCode == 200 else {
                throw APIClientError.invalidResponse
            }
            
            // Handle the response data.
            guard let data = response.data else {
                throw APIClientError.noData
            }
            
            switch data.status {
                case .success:
                    // Return the decoded data if the status indicates success.
                    return data.data
                case .error:
                    throw APIClientError.invalidResponse
            }
        } catch {
            // Propagate any errors encountered.
            throw error
        }
    }
    
    /// Performs a network request using Combine and returns a decoded response of the specified type.
    ///
    /// - Parameters:
    ///   - endpoint: The API endpoint defining the request details.
    ///   - parameters: The parameters to include in the request (optional).
    ///   - method: The HTTP method to use for the request.
    /// - Returns: A publisher that emits the decoded response data of type `Response` or an error.
    func request<Parameters: Encodable & Sendable, Response: Decodable>(
        for endpoint: APIRequestable,
        with parameters: Parameters? = Empty?.none,
        method: HTTPMethod
    ) -> AnyPublisher<Response?, APIClientError> {
        apiClient
            .request(for: endpoint, with: parameters, method: method)
            .tryMap { (response: APIDataResponse<DefaultNetworkResponse<Response>>) in
                // Validate the HTTP status code.
                guard response.response?.statusCode == 200 else {
                    throw APIClientError.invalidResponse
                }
                
                // Handle the response data.
                guard let data = response.data else {
                    throw APIClientError.noData
                }
                
                switch data.status {
                    case .success:
                        return data.data
                    case .error:
                        throw APIClientError.invalidResponse
                }
            }
            .mapError { error in
                if let clientError = error as? APIClientError {
                    return clientError
                } else {
                    return APIClientError.generic(error)
                }
            }
            .eraseToAnyPublisher()
    }
}

