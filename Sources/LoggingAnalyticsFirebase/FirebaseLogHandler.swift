/***************************************************************************
 * This source file is part of the swift-log-analytics-firebase            *
 * open source project.                                                    *
 *                                                                         *
 * Copyright (c) 2020-present, InMotion Software and the project authors   *
 * Licensed under the MIT License                                          *
 *                                                                         *
 * See LICENSE.txt for license information                                 *
 ***************************************************************************/

import Foundation
import Logging
import struct Logging.Logger
import FirebaseAnalytics
import FirebaseCrashlytics

///
/// A logging backend for `SwiftLog` that sends log messages to `FirebaseAnalytics` and `FirebaseCrashlytics`.
///
public struct FirebaseLogHandler: LogHandler {
    
    public var logLevel: Logger.Level = .info

    public init(label: String) {}

    public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        if source.isSourceAnalyticsEvent {
            Analytics.logEvent(message.description, parameters: metadata)
        } else if source.isSourceAnalyticsScreen {
            Analytics.logEvent(AnalyticsEventScreenView,
                              parameters: [
                                    AnalyticsParameterScreenName: metadata?.screenName ?? "",
                                    AnalyticsParameterScreenClass: metadata?.screenClass ?? ""
                              ])
        } else if source.isSourceAnalyticsError || level == .error {
            guard let nserror = metadata?.nserror else { return }
            Crashlytics.crashlytics().record(error: nserror)
        }
    }

    public var metadata = Logger.Metadata()

    /// Add, remove, or change the logging metadata.
    /// - parameters:
    ///    - metadataKey: the key for the metadata item.
    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            return self.metadata[metadataKey]
        }
        set {
            self.metadata[metadataKey] = newValue
        }
    }

}
