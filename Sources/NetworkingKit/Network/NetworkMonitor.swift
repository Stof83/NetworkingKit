//
//  NetworkMonitor.swift
//
//
//  Created by El Mostafa El Ouatri on 11/09/23.
//

import Network

/// A class for monitoring network connectivity using `NWPathMonitor`.
public final class NetworkMonitor {
    
    // MARK: - Static Properties
    
    /// The shared singleton instance of `NetworkMonitor`.
    public static let shared = NetworkMonitor()
    
    // MARK: - Public Properties
    
    /// The `NWPathMonitor` instance responsible for monitoring network changes.
    public let monitor = NWPathMonitor()
    
    /// Indicates whether the network is currently reachable.
    public var isReachable: Bool { status == .satisfied }
    
    /// Indicates whether the network is reachable using cellular data (isExpensive connection).
    public var isReachableOnCellular: Bool = true
    
    // MARK: - Private Properties
    
    /// The current network status (`.satisfied`, `.requiresConnection`, etc.).
    private var status: NWPath.Status = .requiresConnection

    // MARK: - Initialization
    
    /// Initializes a new instance of `NetworkMonitor`.
    private init() {}
    
    // MARK: - Public Methods
    
    /// Starts monitoring network connectivity status.
    /// - Parameters:
    ///   - completion: A closure that gets called when the network status changes.
    ///   - isConnected: A boolean indicating if the network is reachable.
    ///   - isCellular: A boolean indicating if the network connection is cellular.
    public func startMonitoring(
        completion: ((_ isConnected: Bool, _ isCellular: Bool) -> Void)? = nil
    ) {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            self.status = path.status
            self.isReachableOnCellular = path.isExpensive
            
            let isConnected = status == .satisfied

            completion?(isConnected, isReachableOnCellular)
        }

        let queue = DispatchQueue.global(qos: .background)
        monitor.start(queue: queue)
    }
    
    /// Stops monitoring network connectivity.
    public func stopMonitoring() {
        monitor.cancel()
    }
}
