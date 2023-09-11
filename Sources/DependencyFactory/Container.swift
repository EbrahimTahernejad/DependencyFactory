//
//  ServiceContainer.swift
//  Sibaro
//
//  Created by Ebrahim Tahernejad on 5/24/1402 AP.
//

import Foundation

// MARK: - Protocols
public protocol ManagedContainer {
    var manager: ContainerManager { get }
}

public protocol ContainerManager {
    func register<T>(
        key: String,
        clear: Bool,
        factory: @escaping () -> T
    )
    
    func resolve<T>(key: String) -> T?
}


// MARK: - Class Implementations
public final class Container: ManagedContainer {
    public lazy var manager: ContainerManager = {
        return CachingContainerManager(self)
    }()
    public static let shared: Container = Container()
}

public final class CachingContainerManager: ContainerManager {
    private weak var container: Container?
    private var registered: [String:AnyServiceFactoryContainer] = [:]
    private var registeredCached: [String:Any] = [:]
    private let lock = RecursiveLock()
    
    public init(_ container: Container) {
        self.container = container
    }
    
    public func register<T>(
        key: String,
        clear: Bool,
        factory: @escaping () -> T
    ) {
        lock.lock()
        if clear || registered[key] == nil {
            registeredCached[key] = nil
            registered[key] = ServiceFactoryContainer(factory: factory)
        }
        lock.unlock()
    }
    
    public func resolve<T>(key: String) -> T? {
        lock.lock()
        let value = (registeredCached[key] as? T) ?? (registered[key] as? ServiceFactoryContainer<T>)?.factory()
        registeredCached[key] = value
        lock.unlock()
        return value
    }
}
