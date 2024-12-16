//
//  APIClient.swift
//
//  Created by El Mostafa El Ouatri on 13/03/23.
//

import Combine
import Foundation

/// A protocol defining the contract for a data transfer service with associated types for response and error types.
public protocol APIClientProtocol: AnyObject {
    /// Sends a network request with parameters and returns the decoded response.
    ///
    /// - Parameters:
    ///   - endpoint: The API endpoint to send the request to.
    ///   - parameters: The parameters to encode and send with the request.
    ///   - method: The HTTP method to use for the request.
    /// - Returns: An `APIDataResponse` containing the decoded response data.
    /// - Throws: An error if the request fails or decoding fails.
    func request<Parameters: Encodable & Sendable, Response: Decodable>(
        for endpoint: APIRequestable,
        with parameters: Parameters?,
        method: HTTPMethod
    ) async throws -> APIDataResponse<Response>

    /// Sends a network request with parameters and returns the decoded response as a publisher.
    ///
    /// - Parameters:
    ///   - endpoint: The API endpoint to send the request to.
    ///   - parameters: The parameters to encode and send with the request.
    ///   - method: The HTTP method to use for the request.
    /// - Returns: A publisher that emits the decoded response data.
    func request<Parameters: Encodable & Sendable, Response: Decodable>(
        for endpoint: APIRequestable,
        with parameters: Parameters?,
        method: HTTPMethod
    ) -> AnyAPIDataResponse<Response>

    /// Decodes a given `Data` object into a response.
    ///
    /// - Parameters:
    ///   - data: The data to decode.
    /// - Returns: An `APIDataResponse` containing the decoded response data.
    /// - Throws: An error if decoding fails.
    func request<Response: Decodable>(_ data: Data?) async throws -> APIDataResponse<Response>

    /// Decodes a given `Data` object into a response as a publisher.
    ///
    /// - Parameters:
    ///   - data: The data to decode.
    /// - Returns: A publisher that emits the decoded response data.
    func request<Response: Decodable>(_ data: Data?) -> AnyAPIDataResponse<Response>
}

/// A concrete implementation of the `APIClientProtocol` using async/await and generics for data transfer.
public class APIClient: APIClientProtocol {
    private let networkService: NetworkServiceProtocol
    private let jsonManager: JSONManager
    private let useMockData: Bool

    /// Initializes a new instance of `APIClient`.
    ///
    /// - Parameters:
    ///   - networkService: The network service used for performing network requests.
    ///   - jsonManager: The JSON manager for encoding and decoding JSON data.
    ///   - useMockData: Indicates whether to use mock data for network requests.
    public init(
        with networkService: NetworkServiceProtocol,
        jsonManager: JSONManager = JSONManager(),
        useMockData: Bool = false
    ) {
        self.networkService = networkService
        self.jsonManager = jsonManager
        self.useMockData = useMockData
    }

    // MARK: - Async Methods

    /// Sends a network request with parameters and returns the decoded response.
    ///
    /// - Parameters:
    ///   - endpoint: The API endpoint to send the request to.
    ///   - parameters: The parameters to encode and send with the request.
    ///   - method: The HTTP method to use for the request.
    /// - Returns: An `APIDataResponse` containing the decoded response data.
    /// - Throws: An error if the request fails or decoding fails.
    public func request<Parameters: Encodable & Sendable, Response: Decodable>(
        for endpoint: APIRequestable,
        with parameters: Parameters? = Empty?.none,
        method: HTTPMethod
    ) async throws -> APIDataResponse<Response> {
        do {
            if useMockData || endpoint.isMocked {
                return try await request(endpoint.jsonData)
            }

            let encodedParameters = encodeParameters(parameters)
            let response: APIDataResponse<Data> = try await networkService.request(endpoint, with: encodedParameters, method: method)
            return try decode(from: response)
        } catch let error as NetworkError {
            throw APIClientError.networkFailure(error)
        } catch {
            throw APIClientError.generic(error)
        }
    }

    /// Decodes a given `Data` object into a response asynchronously.
    ///
    /// - Parameters:
    ///   - data: The data to decode.
    /// - Returns: An `APIDataResponse` containing the decoded response data.
    /// - Throws: An error if decoding fails.
    public func request<Response: Decodable>(_ data: Data?) async throws -> APIDataResponse<Response> {
        guard let data else { throw APIClientError.noData }

        do {
            let decodedResponse: Response = try jsonManager.decode(Response.self, from: data)
            return APIDataResponse<Response>(request: nil, response: nil, data: decodedResponse, error: nil)
        } catch {
            throw APIClientError.parsingJSON(error)
        }
    }

    // MARK: - Combine Methods

    /// Sends a network request with parameters and returns the decoded response as a publisher.
    ///
    /// - Parameters:
    ///   - endpoint: The API endpoint to send the request to.
    ///   - parameters: The parameters to encode and send with the request.
    ///   - method: The HTTP method to use for the request.
    /// - Returns: A publisher that emits the decoded response data.
    public func request<Parameters: Encodable & Sendable, Response: Decodable>(
        for endpoint: APIRequestable,
        with parameters: Parameters? = Empty?.none,
        method: HTTPMethod
    ) -> AnyAPIDataResponse<Response> {
        if useMockData || endpoint.isMocked {
            return request(endpoint.jsonData)
        }

        let encodedParameters = encodeParameters(parameters)
        return networkService.request<Data>(endpoint, with: encodedParameters, method: method)
            .tryMap { response in
                try self.decode(from: response)
            }
            .mapError { error -> APIClientError in
                if let networkError = error as? NetworkError {
                    return .networkFailure(networkError)
                } else {
                    return .generic(error)
                }
            }
            .eraseToAnyPublisher()
    }

    /// Decodes a given `Data` object into a response as a publisher.
    ///
    /// - Parameters:
    ///   - data: The data to decode.
    /// - Returns: A publisher that emits the decoded response data.
    public func request<Response: Decodable>(_ data: Data?) -> AnyAPIDataResponse<Response> {
        guard let data else {
            return Fail(error: APIClientError.noData).eraseToAnyPublisher()
        }
        
        return Just(data)
            .setFailureType(to: APIClientError.self)
            .tryMap { data -> APIDataResponse<Response> in
                let decodedResponse: Response = try self.jsonManager.decode(Response.self, from: data)
                return APIDataResponse<Response>(request: nil, response: nil, data: decodedResponse, error: nil)
            }
            .mapError { error -> APIClientError in
                return .generic(error)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private Helpers

    /// Encodes parameters to a dictionary using the JSONManager.
    ///
    /// - Parameters:
    ///   - parameters: The parameters to encode.
    /// - Returns: A dictionary representation of the parameters.
    private func encodeParameters<Parameters: Encodable>(_ parameters: Parameters?) -> [String: Any]? {
        parameters?.toDictionary(with: jsonManager.encoder)
    }

    /// Decodes the response data into the expected response type.
    ///
    /// - Parameters:
    ///   - response: The response data to decode.
    /// - Returns: A decoded `APIDataResponse` containing the expected response data.
    /// - Throws: An error if decoding fails.
    private func decode<T: Decodable>(from response: APIDataResponse<Data>) throws -> APIDataResponse<T> {
        do {
            let decodedData = try jsonManager.decode(T.self, from: response.data ?? Data())
            return APIDataResponse<T>(
                request: response.request,
                response: response.response,
                data: decodedData,
                error: response.error
            )
        } catch {
            throw APIClientError.parsingJSON(error)
        }
    }
}
