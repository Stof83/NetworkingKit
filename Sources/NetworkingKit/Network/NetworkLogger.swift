//
//  NetworkLogger.swift
//
//  Created by El Mostafa El Ouatri on 13/03/23.
//

import Foundation
import os

/// A logger class to handle network-related logging, providing detailed request and response logs.
final class NetworkLogger {
    /// Private instance of Logger, used for logging in release builds.
    static private let logger = Logger(subsystem: "NetworkingKit", category: "network")

    /// Logs a message. Prints in DEBUG, logs in release.
    /// - Parameter message: The message to log.
    static func log(_ message: String) {
        #if DEBUG
        print(message)
        #else
        logger.log(level: .info, "\(message)")
        #endif
    }

    /// Logs a URLRequest in a curl format for easy debugging.
    /// - Parameter request: The request to log.
    static func log(request: URLRequest?) {
        guard let request = request, let url = request.url else { return }
        
        var curlString = "curl -X \(request.httpMethod ?? "GET") '\(url.absoluteString)'"
        
        if let headers = request.allHTTPHeaderFields {
            for (key, value) in headers {
                curlString += " -H '\(key): \(value)'"
            }
        }
        
        if let bodyData = request.httpBody, let bodyString = String(data: bodyData, encoding: .utf8) {
            curlString += " -d '\(bodyString)'"
        }
        
        let logMessage = """
        ⬆️ ----- START REQUEST ----- ⬆️
        \(curlString)
        ⬆️ ----- END REQUEST ----- ⬆️
        """
        log(logMessage)
    }

    /// Logs an HTTP response, including URL, status code, body, and any potential error.
    /// - Parameters:
    ///   - response: The HTTPURLResponse received.
    ///   - data: The data received in the response body.
    ///   - error: Optional error encountered during the request.
    static func log(response: HTTPURLResponse?, data: Data?, error: Error? = nil) {
        var logMessage = "\n⬇️ ----- START RESPONSE ----- ⬇️"
        
        if let response {
            logMessage += "\n    -- URL: \(response.url?.absoluteString ?? "NO URL")"
            let statusCode = response.statusCode
            
            if (200..<300).contains(statusCode) {
                logMessage += "\n    -- Status Code: ✅ \(statusCode)"
            } else {
                logMessage += "\n    -- Status Code: ❌ \(statusCode)"
            }
        } else {
            logMessage += "\n    -- No Response: NO RESPONSE"
        }
        
        if let data, let stringBody = String(data: data, encoding: .utf8) {
            logMessage += "\n    -- Body: \(stringBody)"
        } else {
            logMessage += "\n    -- Body: NO HTTP BODY"
        }
        
        if let error {
            logMessage += "\n    -- Error: 🚨 \(error.localizedDescription)"
        } else {
            logMessage += "\n    -- No Error: 👌 NO ERROR"
        }

        logMessage += "\n⬇️ ----- END RESPONSE ----- ⬇️"
        log(logMessage)
    }

    /// Logs raw response data as a JSON object.
    /// - Parameter data: The raw data received in the response.
    static func log(responseData data: Data?) {
        guard let data else { return }
        
        if let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            log("Response Data: \(jsonData)")
        } else {
            log("Response Data: Unable to parse data as JSON.")
        }
    }

    /// Logs an error encountered during the network request.
    /// - Parameter error: The error to log.
    static func log(error: Error) {
        log("-- Error: 🚨 \(error.localizedDescription)")
    }

    /// Logs an HTTP status code.
    /// - Parameter statusCode: The status code to log.
    static func log(statusCode: Int) {
        let statusEmoji = (200..<300).contains(statusCode) ? "✅" : "❌"
        log("Status Code: \(statusEmoji) \(statusCode)")
    }
}
