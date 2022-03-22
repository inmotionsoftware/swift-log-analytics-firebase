# LoggingAnalyticsFirebase

 A logging backend for `SwiftLog` that sends analytics log messages to `Firebase`.

## Getting started

#### Adding the dependency

Xcode's Swift Package Manager integration (Xcode 12 and higher):

```
https://github.com/inmotionsoftware/swift-log-analytics-firebase.git
```

Package.swift:
```
.package(name: "LoggingAnalyticsFirebase",
         url: "https://github.com/inmotionsoftware/swift-log-analytics-firebase.git",
         .branch("0.0.2"))
```

#### Setup Firebase Analytics

Follow quickstart guide to set up Firebase Crashlytics in your app with the Firebase Crashlytics SDK.

https://firebase.google.com/docs/crashlytics/get-started?platform=ios

#### Bootstrap LoggingAnalyticsFirebase

```swift
import Logging
import LoggingAnalyticsFirebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        LoggingSystem.bootstrap(FirebaseLogHandler.init)
}
```

#### Implement AnalyticsEvent and AnalyticsError

Provide app specific analytics event and error implementations.

```swift
enum SampleAnalyticsEvent: AnalyticsEvent {
    case event1
    case event2
    
    var name: String {
        switch self {
            case .event1: return "event1"
            case .event2: return "event2"
        }
    }
    
    var attributes: Logger.Metadata? {
        switch self {
            case .event1: return ["from_screen": "event1"]
            default: return nil
        }
    }
}

enum SampleAnalyticsError: AnalyticsError {
    case error1
    case error2
    
    var domain: String {
        switch self {
            case .error1: return "domain_error1"
            case .error2: return "domain_error2"
        }
    }
    
    var code: Int {
        switch self {
            case .error1: return -1
            case .error2: return -2
        }
    }
    
    var userInfo: AnalyticsErrorInfo? {
        case .error1:
            return AnalyticsErrorInfo(
                        description: "Error 1",
                        failureReason: "Unspecified",
                        recoverySuggestion: "Check your code"
                    )
        default:
            return nil
    }
}
```

#### Let's log

```swift
// 1) let's import the logging API package
import Logging
import LoggingAnalyticsFirebase

// 2) we need to create a logger
let logger = Logger(label:"LoggingExample/ExampleCategory")

// 3) we're now ready to use it
logger.recordEvent(SampleAnalyticsEvent.event1)
logger.recordEvent(SampleAnalyticsEvent.event2)

logger.recordScreen("Screen 1", screenClass: classForCoder.description())

logger.recordError(SampleAnalyticsError.error1)
```

## License

MIT
