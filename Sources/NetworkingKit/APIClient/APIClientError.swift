//
//  APIClientError.swift
//  NetworkingKit
//
//  Created by El Mostafa El Ouatri on 29/09/24.
//

/// An enumeration representing possible errors during data transfer.
public enum APIClientError: Error {
    /// An error indicating a failure while parsing JSON data.
    case parsingJSON(Error)
    /// An error indicating a network failure, wrapped in a `NetworkError`.
    case networkFailure(NetworkError)
    /// An error indicating a generic error occurred during data transfer.
    case generic(Error)
    /// No data
    case noData
    /// An error indicating no valid response was received.
    case invalidResponse

    
    /// The localized title for the error.
    public var localizedTitle: String? {
        switch self {
            case .parsingJSON:
                return L10n.ApiClientError.ParsingJson.title
            case .networkFailure(let error):
                return error.localizedTitle
            case .generic:
                return L10n.error
            case .noData:
                return L10n.ApiClientError.NoData.title
            case .invalidResponse:
                return L10n.ApiClientError.NoValidResponse.title
        }
    }
    
    /// The localized description for the error.
    public var localizedDescription: String {
        switch self {
            case .parsingJSON:
                return L10n.ApiClientError.ParsingJson.description
            case .networkFailure(let networkError):
                return networkError.localizedDescription
            case .generic:
                return L10n.anErrorOccured
            case .noData:
                return L10n.ApiClientError.NoData.description
            case .invalidResponse:
                return L10n.ApiClientError.NoValidResponse.description
        }
    }
}
