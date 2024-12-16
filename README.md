# NetworkingKit

[![Swift Version](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)]()

`NetworkingKit` is a Swift library that simplifies making network requests using modern tools and methodologies, including Alamofire, Combine, and async/await. It provides a flexible, extensible solution for handling various types of requests, including data and file downloads, while also providing detailed error handling, response logging, and network connectivity monitoring.

## Features

- Asynchronous network requests using async/await.
- Network requests with Combine for reactive programming.
- Supports different HTTP methods (GET, POST, PUT, DELETE, etc.).
- Customizable request parameters, headers, and encoding.
- Integrated network error handling.
- Detailed request and response logging.
- Network connectivity monitoring using `NWPathMonitor`.
- SSL pinning and server trust management.
- Response caching and request retry capabilities.

## Requirements

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
- Swift 5.10+
- Alamofire 5.x
- Combine (for reactive functionality)

## Installation

### Swift Package Manager

To integrate `NetworkingKit` into your Xcode project using Swift Package Manager, add the following to your `Package.swift`:

```swift
// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "YourPackageName",
    dependencies: [
        .package(url: "https://github.com/Stof83/NetworkingKit.git", from: "1.0.0")
    ],
    targets: [
        .target(
                name: "YourTargetName",
                dependencies: [
                    .product(name: "NetworkingKit", package: "NetworkingKit")
                ]
        )
    ]
)
```

## Example Usage

### Define a User API

Define your API endpoint by conforming to the APIRequestable protocol. Here’s an example for a user API:
```swift
enum UserAPI {
    case fetchUserDetails(String)
    case updateUserDetails(String)
}

extension UserAPI: APIRequestable {
    
    var baseURL: URL? {
        URL(string: "https://api.example.com")
    }
    
    var apiVersion: String {
        "v1/users"
    }

    var path: String {
        switch self {
        case .fetchUserDetails(let userId):
            return "\(userId)"
        case .updateUserDetails(let userId):
            return "\(userId)/update"
        }
    }
    
    var headers: HTTPHeaders {
        ["Authorization": "Bearer token", "Accept": "application/json"]
    }
}

```

### Create a UserService

Create a service that fetches and updates user details. Below is an example of how to set it up:
```swift
class UserService {
    private let apiClientManager = APIClientManager()
    
    func fetchUserDetails(userId: String) async throws -> User? {
        let endpoint = UserAPI.fetchUserDetails(userId)
        return try await apiClientManager.request(for: endpoint, method: .get)
    }
    
    func updateUserDetails(userId: String, userDetails: UserUpdateRequest) async throws -> User? {
        let endpoint = UserAPI.updateUserDetails(userId)
        return try await apiClientManager.request(for: endpoint, with: userDetails, method: .put)
    }
}
```
### Model Definitions

Define your data models as Decodable and Encodable structs. Example for User and UserUpdateRequest:
```swift
struct User: Decodable {
    let id: String
    let name: String
    let email: String
}

struct UserUpdateRequest: Encodable {
    let name: String
    let email: String
}
```

### Perform Network Requests

Now, you can use UserService to fetch and update user details. Here's how you would do it:

#### Fetch User Details
```swift
let userService = UserService()

Task {
    do {
        if let user = try await userService.fetchUserDetails(userId: "12345") {
            print("User Details: \(user)")
        }
    } catch {
        print("Error: \(error)")
    }
}
```

#### Update User Details
```swift
let userService = UserService()

Task {
    do {
        let updatedUserDetails = UserUpdateRequest(name: "New Name", email: "new.email@example.com")
        if let updatedUser = try await userService.updateUserDetails(userId: "12345", userDetails: updatedUserDetails) {
            print("Updated User: \(updatedUser)")
        }
    } catch {
        print("Error: \(error)")
    }
}
```

### APIClientManager

APIClientManager acts as the main class that handles network requests. It abstracts the details of making requests and handling responses.
```swift
class APIClientManager {
    private let apiClient: APIClient
    
    /// Initializes a new instance of `APIClientManager`.
    public init() {
        self.apiClient = APIClient(with: AFNetworkService(configuration: .init()))
    }
    
    /// Performs a network request and returns a decoded response of the specified type.
    func request<Parameters: Encodable & Sendable, Response: Decodable>(
        for endpoint: APIRequestable,
        with parameters: Parameters? = Empty?.none,
        method: HTTPMethod
    ) async throws -> Response? {
        do {
            let response: APIDataResponse<DefaultNetworkResponse<Response>> = try await apiClient.request(
                for: endpoint,
                with: parameters,
                method: method
            )
            
            guard response.response?.statusCode == 200 else {
                throw APIClientError.invalidResponse
            }
            
            guard let data = response.data else {
                throw APIClientError.noData
            }
            
            switch data.status {
                case .success:
                    return data.data
                case .error:
                    throw APIClientError.invalidResponse
            }
        } catch {
            throw error
        }
    }
    
    /// Performs a network request using Combine and returns a decoded response of the specified type.
    func request<Parameters: Encodable & Sendable, Response: Decodable>(
        for endpoint: APIRequestable,
        with parameters: Parameters? = Empty?.none,
        method: HTTPMethod
    ) -> AnyPublisher<Response?, APIClientError> {
        apiClient
            .request(for: endpoint, with: parameters, method: method)
            .tryMap { (response: APIDataResponse<DefaultNetworkResponse<Response>>) in
                guard response.response?.statusCode == 200 else {
                    throw APIClientError.invalidResponse
                }
                
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
```
## Configuration

The AFNetworkServiceConfiguration allows you to configure the network service:
```swift
let configuration = AFNetworkServiceConfiguration(
    serverTrustManager: yourServerTrustManager, 
    cacheResponse: .cacheResponse,
    urlEncoding: URLEncoding.default,
    jsonEncoding: JSONEncoding.default
)
```

## Server Trust Manager
For handling SSL pinning and server trust evaluations, pass an instance of ServerTrustManager in the configuration.

## Response Caching
NetworkingKit supports caching responses. You can configure caching behavior by passing a ResponseCacher in the network service configuration.

## Customizing Request Encoding
NetworkingKit supports both URL and JSON encoding, which can be customized based on the HTTP method:

- URLEncoding: For methods like GET.
- JSONEncoding: For methods like POST, PUT.

## Logging
NetworkLogger provides detailed logging for requests and responses, including cURL output and error details:

## Error Handling
The APIClientManager uses a custom error handling approach with the APIClientError enum. It includes:

- invalidResponse: Invalid or unexpected response from the API.
- noData: No data in the response.
- generic: A generic error that wraps unexpected errors.

```swift
enum APIClientError: Error {
    case invalidResponse
    case noData
    case generic(Error)
}
```
### Network Error Handling

Network errors are represented by the NetworkError enum, which includes the following cases:

- serverError: An error from the server with status code and response data.
- notConnected: No internet connection.
- cancelled: The network request was cancelled.
- generic: A generic network error.
- urlGeneration: An error when URL generation fails.
- notFound: The requested resource was not found (HTTP 404).
- noData: No data received in the response.
- invalidResponse: The response was invalid.
- badResponse: A bad response from the server with an optional message.

## Network Connectivity Monitoring

NetworkMonitor allows you to monitor network connectivity and handle changes in network status:
```swift
NetworkMonitor.shared.startMonitoring { isConnected, isCellular in
    if isConnected {
        print("Connected to network")
    } else {
        print("No network connection")
    }
}
```

To stop monitoring:
```swift
NetworkMonitor.shared.stopMonitoring()
```

```swift
```

## Compatibility

This SDK is compatible with Alamofire-based iOS apps and requires iOS 13 or later.

## License

This SDK is provided under the MIT License. [See LICENSE](https://github.com/Stof83/NetworkingKit/LICENSE) for details.
Feel free to use, modify, and distribute it as per the terms of the license.
