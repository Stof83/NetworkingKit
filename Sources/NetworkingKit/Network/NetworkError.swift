//
//  NetworkError.swift
//
//  Created by El Mostafa El Ouatri on 13/03/23.
//

import Foundation

/// An enumeration representing various network-related errors.
public enum NetworkError: Error {
    /// An error indicating a specific response error from the server, including the response Data and the status code.
    case serverError(data: Data?, statusCode: Int)
    /// An error indicating that the device is not connected to the internet.
    case notConnected
    /// An error indicating that the network request was cancelled.
    case cancelled
    /// An error indicating a generic error occurred during the network operation.
    case generic(Error)
    /// An error indicating a problem with URL generation.
    case urlGeneration
    /// An error indicating that the requested resource was not found on the server (HTTP status code 404).
    case notFound
    /// An error indicating that no data was received in the response.
    case noData
    /// An error indicating an invalid response was received from the server.
    case invalidResponse
    /// An error indicating a bad response received from the server.
    case badResponse(String?) // Adding an optional message for clarity.

    // MARK: - Localized Properties
    
    /// The localized title for the error.
    public var localizedTitle: String? {
        switch self {
            case .serverError:
                return L10n.NetworkError.Error.title
            case .notConnected:
                return L10n.NetworkError.NotConnected.title
            case .cancelled:
                return L10n.NetworkError.Cancelled.title
            case .generic:
                return L10n.error
            case .urlGeneration:
                return L10n.NetworkError.UrlGeneration.title
            case .notFound:
                return L10n.NetworkError.NotFound.title
            case .noData:
                return L10n.NetworkError.NoData.title
            case .invalidResponse:
                return L10n.NetworkError.InvalidResponse.title
            case .badResponse:
                return L10n.NetworkError.BadResponse.title
        }
    }
    
    /// The localized description for the error.
    public var localizedDescription: String {
        switch self {
            case .serverError:
                return L10n.NetworkError.Error.description
            case .notConnected:
                return L10n.NetworkError.NotConnected.description
            case .cancelled:
                return L10n.NetworkError.Cancelled.description
            case let .generic(error):
                return "\(L10n.anErrorOccured): \(error.localizedDescription)"
            case .urlGeneration:
                return L10n.NetworkError.UrlGeneration.description
            case .notFound:
                return L10n.NetworkError.NotFound.description
            case .noData:
                return L10n.NetworkError.NoData.description
            case .invalidResponse:
                return L10n.NetworkError.InvalidResponse.description
            case let .badResponse(message):
                return message ?? L10n.NetworkError.BadResponse.description
        }
    }
}

