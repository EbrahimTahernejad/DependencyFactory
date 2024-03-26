# DependencyFactory

A simple dependency factory library

## Usage

### Define a service
```swift
import DependencyFactory

protocol StorageServiceProtocol: BaseService {
    var token: String? { get set }
}

class StorageService: BaseService, StorageServiceProtocol {
    @Stored(key: "Token", in: .keychain) var token: String?
}
```

### Add it to container
```swift
import DependencyFactory

extension Container {
    static var storage: Factory<StorageServiceProtocol> {
        Factory(self) { StorageService() }
    }
}
```

### Inject
```swift
class ViewModel: BaseViewModel {
    @Injected(\.storage) var storage
}
```

### Register another class
```swift

class MemoryStorageService: BaseService, StorageServiceProtocol {
    var token: String? 
}
```

```swift
Container.shared.manager.register { () -> StorageServiceProtocol in
    MemoryStorageService()
}
```
