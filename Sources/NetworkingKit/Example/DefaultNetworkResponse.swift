//
//  DefaultNetworkResponse.swift
//  NetworkingKit
//
//  Created by El Mostafa El Ouatri on 14/12/24.
//

import Foundation

/// An enumeration representing the status types of a network response.
enum DefaultNetworkStatusType: String, Decodable {
    /// The network response indicates success.
    case success
    /// The network response indicates an error.
    case error
    
    /// A computed property that indicates if the network response is successful.
    var isSuccess: Bool {
        self == .success
    }
}

/// A generic struct representing a network response.
///
/// It includes the status of the response (`DefaultNetworkStatusType`), the generic data of type `T`,
/// and an optional error (`DefaultNetworkResponseError`) in case of failure.
struct DefaultNetworkResponse<T: Decodable>: Decodable {
    /// The status of the network response (`DefaultNetworkStatusType`).
    let status: DefaultNetworkStatusType
    /// The generic data received in the network response.
    let data: T?
    /// An optional error details in case of failure.
    let error: DefaultNetworkResponseError?

    /// Coding keys used to decode the network response from JSON.
    enum CodingKeys: String, CodingKey {
        case status
        case data
        case error
    }

    /// Initializes a network response struct by decoding from the given decoder.
    ///
    /// - Parameter decoder: The decoder used to decode the network response from JSON.
    /// - Throws: An error if decoding fails.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decode(DefaultNetworkStatusType.self, forKey: .status)
        data = try container.decodeIfPresent(T.self, forKey: .data)
        error = try container.decodeIfPresent(DefaultNetworkResponseError.self, forKey: .error)
    }
}

/// A struct representing an error in the network response.
///
/// It includes optional `title` and `message` properties to provide additional details
/// in case of failure.
struct DefaultNetworkResponseError: Decodable {
    /// An optional title for the error.
    let title: String?
    /// An optional message describing the error.
    let message: String?
}
