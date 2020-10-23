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

public protocol AnalyticsEvent {
    var name: String {get}
    var attributes: Logger.Metadata? {get}
}

///
/// AnalyticsScreen
///
public struct AnalyticsScreen {
    public var screenName: String
    public var screenClass: String
}

extension AnalyticsScreen {
    var metadata: Logger.Metadata {
        return [
            "screenName": "\(self.screenName)",
            "screenClass": "\(self.screenClass)"
        ]
    }
}

///
/// AnalyticsError
///

public protocol AnalyticsError {
    var domain: String {get}
    var code: Int {get}
    var userInfo: AnalyticsErrorInfo? {get}
}

public struct AnalyticsErrorInfo {
    public let description: String
    public let failureReason: String?
    public let recoverySuggestion: String?

    public init(description: String, failureReason: String?, recoverySuggestion: String?) {
        self.description = description
        self.failureReason = failureReason
        self.recoverySuggestion = recoverySuggestion
    }
}

extension AnalyticsError {
    var metadata: Logger.Metadata {
        return [
            "domain": "\(self.domain)",
            "code": "\(self.code)",
            "description": "\(self.userInfo?.description ?? "")",
            "failureReason": "\(self.userInfo?.failureReason ?? "")",
            "recoverySuggestion": "\(self.userInfo?.recoverySuggestion ?? "")"
        ]
    }
}

extension Error {
    var metadata: Logger.Metadata {
        let nserror = self as NSError
        return [
            "domain": "\(nserror.domain)",
            "code": "\(nserror.code)",
            "description": "\(nserror.description)",
            "failureReason": "\(nserror.localizedFailureReason ?? "")",
            "recoverySuggestion": "\(nserror.localizedRecoverySuggestion ?? "")"
        ]
    }
}

///
/// Logger.Metadata+Analytics
///
extension Logger.Metadata {
    public var nserror: NSError {
        let domain = self["domain"]?.description ?? ""
        let code = self["code"].map { (Int($0.description) ?? 0) } ?? 0

        let userInfo: Dictionary<String, String>? = {
            return [
                NSLocalizedDescriptionKey: self["description"]?.description ?? "",
                NSLocalizedFailureReasonErrorKey: self["failureReason"]?.description ?? "",
                NSLocalizedRecoverySuggestionErrorKey: self["recoverySuggestion"]?.description ?? ""
            ]
        }()
        return NSError(domain: domain, code: code, userInfo: userInfo)
    }
    
    public var screenName: String? {
        return self["screenName"]?.description
    }
    
    public var screenClass: String? {
        return self["screenClass"]?.description
    }
}

///
/// String+Analytics
///
extension String {
    public var isSourceAnalytics: Bool {
        return self.isSourceAnalyticsError
            || self.isSourceAnalyticsEvent
            || self.isSourceAnalyticsScreen
    }
    
    public var isSourceAnalyticsError: Bool {
        return self == Logger.Source.AnalyticsError
    }
    
    public var isSourceAnalyticsEvent: Bool {
        return self == Logger.Source.AnalyticsEvent
    }
    
    public var isSourceAnalyticsScreen: Bool {
        return self == Logger.Source.AnalyticsScreen
    }
}

///
/// Logger+Addition
///
extension Logger {

    public func error(_ error: @autoclosure () -> Error) {
        let err = error()
        let nserror = err as NSError
        self.error("\(nserror.domain)[\(nserror.code)]", metadata: err.metadata)
    }

}

///
/// Logger+Analytics
///
extension Logger {

    struct Source {
        static let AnalyticsError = "AnalyticsError"
        static let AnalyticsEvent = "AnalyticsEvent"
        static let AnalyticsScreen = "AnalyticsScreen"
    }

    public func record(_ error: @autoclosure () -> AnalyticsError) {
        let err = error()
        self.error("\(err.domain)[\(err.code)]", metadata: err.metadata, source: Source.AnalyticsError)
    }

    public func record(_ event: @autoclosure () -> AnalyticsEvent) {
        let ev = event()
        self.info("\(ev.name)", metadata: ev.attributes, source: Source.AnalyticsEvent)
    }

    public func record(_ screen: @autoclosure () -> AnalyticsScreen) {
        self.info("Screen View", metadata: screen().metadata, source: Source.AnalyticsScreen)
    }

    public func recordScreen(_ screenName: String, screenClass: String) {
        self.record(AnalyticsScreen(screenName: screenName, screenClass: screenClass))
    }

}
