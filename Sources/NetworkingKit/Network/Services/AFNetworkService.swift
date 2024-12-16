//
//  AFNetworkService.swift
//  NetworkingKit
//
//  Created by El Mostafa El Ouatri on 30/09/24.
//

import Alamofire
import Combine
import Foundation

/// A configuration structure for the `AFNetworkService` class.
public struct AFNetworkServiceConfiguration {
    /// The server trust manager responsible for handling server trust evaluations.
    let serverTrustManager: ServerTrustManager?
    
    /// The response caching mechanism used by the network service.
    let cacheResponse: ResponseCacher
    
    /// The encoding used for URL-based requests (e.g., GET).
    let urlEncoding: URLEncoding
    
    /// The encoding used for JSON-based requests (e.g., POST, PUT).
    let jsonEncoding: JSONEncoding
    
    /// Initializes a new instance of `AFNetworkServiceConfiguration`.
    ///
    /// - Parameters:
    ///   - serverTrustManager: The `ServerTrustManager` used for SSL pinning and server trust evaluations.
    ///   - cacheResponse: The `ResponseCacher` used for caching responses. Defaults to `.doNotCache`.
    ///   - urlEncoding: The parameter encoding used for URL-based requests. Defaults to `URLEncoding.init(arrayEncoding: .noBrackets, boolEncoding: .literal)`.
    ///   - jsonEncoding: The parameter encoding used for JSON-based requests. Defaults to `JSONEncoding.default`.
    public init(
        serverTrustManager: ServerTrustManager? = nil,
        cacheResponse: ResponseCacher = .doNotCache,
        urlEncoding: URLEncoding = URLEncoding.init(arrayEncoding: .noBrackets, boolEncoding: .literal),
        jsonEncoding: JSONEncoding = JSONEncoding.default
    ) {
        self.serverTrustManager = serverTrustManager
        self.cacheResponse = cacheResponse
        self.urlEncoding = urlEncoding
        self.jsonEncoding = jsonEncoding
    }
}

/// A network service implementation using Alamofire.
public final class AFNetworkService: NetworkServiceProtocol {
    // MARK: - Properties
    
    /// Configuration for the network service.
    private let configuration: AFNetworkServiceConfiguration
    
    // MARK: - Initialization
    
    /// Initializes a new instance of `AFNetworkService`.
    ///
    /// - Parameter configuration: The configuration object containing trust manager, caching, and encoding settings.
    public init(configuration: AFNetworkServiceConfiguration) {
        self.configuration = configuration
    }

    // MARK: - Asynchronous Request using async/await
    
    /// Performs an asynchronous network request using async/await.
    ///
    /// - Parameters:
    ///   - request: The `APIRequestable` defining the request to perform.
    ///   - parameters: Additional parameters to include in the request.
    ///   - method: The HTTP method of the request (e.g., GET, POST).
    /// - Returns: An `APIDataResponse` containing the response or an error.
    public func request<T>(
        _ request: APIRequestable,
        with parameters: [String: Any]?,
        method: HTTPMethod
    ) async throws -> APIDataResponse<T> where T: Sendable {
        let session = try prepareSession(for: request, with: parameters, method: method)
        
        let response = await session
            .serializingData()
            .response

        // Log the network response using the `NetworkLogger`.
        NetworkLogger.log(response: response.response, data: response.data)

        return DataResponse(
            request: response.request,
            response: response.response,
            data: response.value as? T,
            error: response.error
        )
    }

    // MARK: - Asynchronous Request using Combine
    
    /// Performs a network request using Combine.
    ///
    /// - Parameters:
    ///   - request: The `APIRequestable` defining the request to perform.
    ///   - parameters: Additional parameters to include in the request.
    ///   - method: The HTTP method of the request (e.g., GET, POST).
    /// - Returns: A publisher emitting an `APIDataResponse` or a default error response.
    public func request<T>(
        _ request: APIRequestable,
        with parameters: [String: Any]?,
        method: HTTPMethod
    ) -> AnyAPIDataResponse<T> where T: Sendable  {
        do {
            let session = try prepareSession(for: request, with: parameters, method: method)

            return session
                .publishData()
                .tryMap { response in
                    DataResponse(
                        request: response.request,
                        response: response.response,
                        data: response.value as? T,
                        error: response.error
                    )
                }
                .mapError { error -> NetworkError in
                        // Log the error
                    NetworkLogger.log(error: error)
                    
                    var networkError: NetworkError = error as! NetworkError
                    
                    switch URLError.Code(rawValue: (error as NSError).code) {
                        case .notConnectedToInternet:
                            networkError = .notConnected
                        case .cancelled:
                            networkError = .cancelled
                        default:
                            break
                    }
                    
                    return networkError
                }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        } catch {
            NetworkLogger.log(error: error)
            return Fail(error: NetworkError.generic(error)).eraseToAnyPublisher()
        }
    }
    
    // MARK: - Private Helper Methods
    
    /// Prepares an Alamofire session and a configured `DataRequest` for the given API request.
    /// - Parameters:
    ///   - request: The `APIRequestable` instance containing request details.
    ///   - parameters: Optional parameters for the request.
    ///   - method: The HTTP method for the request.
    /// - Returns: A configured `DataRequest` ready for execution.
    private func prepareSession(
        for request: APIRequestable,
        with parameters: [String: Any]?,
        method: HTTPMethod
    ) throws -> DataRequest {
        // Prepare the URLRequest
        let urlRequest = try request.asURLRequest(with: method)
        let encoding: ParameterEncoding = method.isGET ? configuration.urlEncoding : configuration.jsonEncoding
        let encodedRequest = try encoding.encode(urlRequest, with: parameters)

        // Configure the session
        let session: Session
        if let serverTrustManager = configuration.serverTrustManager {
            session = Session(configuration: URLSessionConfiguration.af.default, serverTrustManager: serverTrustManager)
        } else {
            session = AF
        }

        // Create and return the configured DataRequest
        return session.request(encodedRequest)
            .cacheResponse(using: configuration.cacheResponse)
            .validate()
            .cURLDescription { NetworkLogger.log($0) }
    }
}
