//
//  APIRequestable.swift
//
//  Created by El Mostafa El Ouatri on 14/02/23.
//

import Foundation

/// A protocol defining the contract for a network request.
public protocol APIRequestable {
    /// The base URL for the API.
    var baseURL: URL? { get }

    /// The complete URL for the request, constructed from the base URL, API version, and path.
    var requestURL: URL { get }

    /// The API version used in the request.
    var apiVersion: String { get }

    /// The path for the request, relative to the base URL and API version.
    var path: String { get }

    /// The HTTP headers for the request.
    var headers: HTTPHeaders { get }

    /// A flag indicating whether the service is using mock data.
    var isMocked: Bool { get }

    /// The name of the JSON file containing mock data (if applicable).
    var jsonFile: String { get }

    /// The JSON data for the mock response (if applicable).
    var jsonData: Data? { get }

    /// The timeout interval for the network request, in seconds.
    var timeoutInterval: TimeInterval { get }

    /// Converts the instance into a `URLRequest` with the specified HTTP method.
    ///
    /// - Parameter method: The HTTP method to use for the request.
    /// - Throws: An error if the `URLRequest` cannot be constructed.
    /// - Returns: A configured `URLRequest` instance.
    func asURLRequest(with method: HTTPMethod) throws -> URLRequest
}

// MARK: - URLRequestConvertible
extension APIRequestable {
    /// The complete URL for the request, constructed from the base URL, API version, and path.
    public var requestURL: URL {
        guard let baseURL else {
            fatalError("Base URL is nil. Ensure a valid base URL is provided.")
        }
        return baseURL.appendingPathComponent(apiVersion).appendingPathComponent(path)
    }

    /// A default implementation indicating that the service does not use mock data.
    public var isMocked: Bool { false }

    /// A default implementation providing an empty JSON file name.
    public var jsonFile: String { "" }

    /// A default implementation returning `nil` for mock JSON data.
    public var jsonData: Data? { nil }

    /// A default implementation providing a timeout interval of 60 seconds.
    public var timeoutInterval: TimeInterval { 60 }

    /// Converts the instance into a `URLRequest` with the specified HTTP method.
    ///
    /// - Parameter method: The HTTP method to use for the request.
    /// - Throws: An error if the `URLRequest` cannot be constructed.
    /// - Returns: A configured `URLRequest` instance.
    public func asURLRequest(with method: HTTPMethod) throws -> URLRequest {
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = headers.dictionary
        urlRequest.timeoutInterval = timeoutInterval

        return urlRequest
    }
}
