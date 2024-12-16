//
//  NetworkResponse.swift
//
//  Created by El Mostafa El Ouatri on 15/03/23.
//

import Combine
import Foundation

public typealias APIDataResponse<T> = DataResponse<T> where T: Sendable & Decodable
public typealias APIDownloadResponse<T> = DownloadResponse<T> where T: Sendable & Decodable

/// A typealias representing the result of a network request with decodable data, which is an `AnyPublisher` with generic type `T`.
public typealias AnyAPIDataResponse<T> = AnyPublisher<APIDataResponse<T>, Error> where T: Sendable & Decodable

// MARK: - DataResponse
/// Type used to store all values associated with a serialized response of a `DataRequest` or `UploadRequest`.
public struct DataResponse<T>: Sendable where T: Sendable & Decodable {
    /// The URL request sent to the server.
    public let request: URLRequest?

    /// The server's response to the URL request.
    public let response: HTTPURLResponse?

    /// The data returned by the server.
    public let data: T?
    
    public let error: Error?

}

// MARK: - DownloadResponse
/// Used to store all data associated with a serialized response of a download request.
public struct DownloadResponse<T>: Sendable where T: Sendable & Decodable {
    /// The URL request sent to the server.
    public let request: URLRequest?

    /// The server's response to the URL request.
    public let response: HTTPURLResponse?

    /// The final destination URL of the data returned from the server after it is moved.
    public let fileURL: URL?

    /// The resume data generated if the request was cancelled.
    public let resumeData: Data?
    
    public let error: Error?

}

// MARK: - Empty
/// Protocol representing an empty response. Use `T.emptyValue()` to get an instance.
public protocol EmptyResponse: Sendable {
    /// Empty value for the conforming type.
    ///
    /// - Returns: Value of `Self` to use for empty values.
    static func emptyValue() -> Self
}

/// Type representing an empty value. Use `Empty.value` to get the static instance.
public struct Empty: Codable, Sendable {
    /// Static `Empty` instance used for all `Empty` responses.
    public static let value = Empty()
}

extension Empty: EmptyResponse {
    public static func emptyValue() -> Empty {
        value
    }
}
