//
//  EventSource.swift
//  EventSource
//
//  Created by Andres on 2/13/15.
//  Copyright (c) 2015 Inaka. All rights reserved.
//
import Foundation

public enum EventSourceState {
    case connecting
    case open
    case closed
}

open class EventSource: NSObject, URLSessionDataDelegate {
    static let DefaultsKey = "com.inaka.eventSource.lastEventId"

    let url: URL
    fileprivate let lastEventIDKey: String
    fileprivate let receivedString: NSString?
    fileprivate var onOpenCallback: (() -> Void)?
    fileprivate var onErrorCallback: ((NSError?) -> Void)?
    fileprivate var onMessageCallback: ((_ id: String?, _ event: String?, _ data: String?) -> Void)?
    open internal(set) var readyState: EventSourceState
    open fileprivate(set) var retryTime = 3000
    fileprivate var eventListeners = Dictionary < String, (_ id: String?, _ event: String?, _ data: String?) -> Void > ()
    fileprivate var headers: Dictionary<String, String>
    internal var urlSession: Foundation.URLSession?
    internal var task: URLSessionDataTask?
    fileprivate var operationQueue: OperationQueue
    fileprivate var errorBeforeSetErrorCallBack: NSError?
    internal let receivedDataBuffer: NSMutableData
    fileprivate let uniqueIdentifier: String
    fileprivate let validNewlineCharacters = ["\r\n", "\n", "\r"]

    var event = Dictionary<String, String>()

    public init(url: String, headers: [String: String] = [:]) {
        self.url = URL(string: url)!
        self.headers = headers
        readyState = EventSourceState.closed
        operationQueue = OperationQueue()
        receivedString = nil
        receivedDataBuffer = NSMutableData()

        let port = String(self.url.port ?? 80)
        let relativePath = self.url.relativePath
        let host = self.url.host ?? ""
        let scheme = self.url.scheme ?? ""

        uniqueIdentifier = "\(scheme).\(host).\(port).\(relativePath)"
        lastEventIDKey = "\(EventSource.DefaultsKey).\(uniqueIdentifier)"

        super.init()
        connect()
    }

    // Mark: Connect
    func connect() {
        var additionalHeaders = headers
        if let eventID = self.lastEventID {
            additionalHeaders["Last-Event-Id"] = eventID
        }

        additionalHeaders["Accept"] = "text/event-stream"
        additionalHeaders["Cache-Control"] = "no-cache"

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(INT_MAX)
        configuration.timeoutIntervalForResource = TimeInterval(INT_MAX)
        configuration.httpAdditionalHeaders = additionalHeaders

        readyState = EventSourceState.connecting
        urlSession = newSession(configuration)
        task = urlSession!.dataTask(with: url)

        resumeSession()
    }

    internal func resumeSession() {
        task!.resume()
    }

    internal func newSession(_ configuration: URLSessionConfiguration) -> Foundation.URLSession {
        return Foundation.URLSession(configuration: configuration,
                                     delegate: self,
                                     delegateQueue: operationQueue)
    }

    // Mark: Close
    open func close() {
        readyState = EventSourceState.closed
        urlSession?.invalidateAndCancel()
    }

    fileprivate func receivedMessageToClose(_ httpResponse: HTTPURLResponse?) -> Bool {
        guard let response = httpResponse else {
            return false
        }

        if response.statusCode == 204 {
            close()
            return true
        }
        return false
    }

    // Mark: EventListeners
    open func onOpen(_ onOpenCallback: @escaping (() -> Void)) {
        self.onOpenCallback = onOpenCallback
    }

    open func onError(_ onErrorCallback: @escaping ((NSError?) -> Void)) {
        self.onErrorCallback = onErrorCallback

        if let errorBeforeSet = self.errorBeforeSetErrorCallBack {
            self.onErrorCallback!(errorBeforeSet)
            errorBeforeSetErrorCallBack = nil
        }
    }

    open func onMessage(_ onMessageCallback: @escaping ((_ id: String?, _ event: String?, _ data: String?) -> Void)) {
        self.onMessageCallback = onMessageCallback
    }

    open func addEventListener(_ event: String, handler: @escaping ((_ id: String?, _ event: String?, _ data: String?) -> Void)) {
        eventListeners[event] = handler
    }

    open func removeEventListener(_ event: String) {
        eventListeners.removeValue(forKey: event)
    }

    open func events() -> Array<String> {
        return Array(eventListeners.keys)
    }

    // MARK: URLSessionDataDelegate

    open func urlSession(_: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if receivedMessageToClose(dataTask.response as? HTTPURLResponse) {
            return
        }

        if readyState != EventSourceState.open {
            return
        }

        receivedDataBuffer.append(data)
        let eventStream = extractEventsFromBuffer()
        parseEventStream(eventStream)
    }

    open func urlSession(_: URLSession, dataTask: URLSessionDataTask, didReceive _: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        completionHandler(URLSession.ResponseDisposition.allow)

        if receivedMessageToClose(dataTask.response as? HTTPURLResponse) {
            return
        }

        readyState = EventSourceState.open
        if onOpenCallback != nil {
            DispatchQueue.main.async {
                self.onOpenCallback!()
            }
        }
    }

    open func urlSession(_: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        readyState = EventSourceState.closed

        if receivedMessageToClose(task.response as? HTTPURLResponse) {
            return
        }

        if error == nil || (error! as NSError).code != -999 {
            let nanoseconds = Double(retryTime) / 1000.0 * Double(NSEC_PER_SEC)
            let delayTime = DispatchTime.now() + Double(Int64(nanoseconds)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self.connect()
            }
        }

        DispatchQueue.main.async {
            if let errorCallback = self.onErrorCallback {
                errorCallback(error as NSError?)
            } else {
                self.errorBeforeSetErrorCallBack = error as NSError?
            }
        }
    }

    // MARK: Helpers

    fileprivate func extractEventsFromBuffer() -> [String] {
        var events = [String]()

        // Find first occurrence of delimiter
        var searchRange = NSRange(location: 0, length: receivedDataBuffer.length)
        while let foundRange = searchForEventInRange(searchRange) {
            // Append event
            if foundRange.location > searchRange.location {
                let dataChunk = receivedDataBuffer.subdata(
                    with: NSRange(location: searchRange.location, length: foundRange.location - searchRange.location)
                )

                if let text = String(bytes: dataChunk, encoding: .utf8) {
                    events.append(text)
                }
            }
            // Search for next occurrence of delimiter
            searchRange.location = foundRange.location + foundRange.length
            searchRange.length = receivedDataBuffer.length - searchRange.location
        }

        // Remove the found events from the buffer
        receivedDataBuffer.replaceBytes(in: NSRange(location: 0, length: searchRange.location), withBytes: nil, length: 0)

        return events
    }

    fileprivate func searchForEventInRange(_ searchRange: NSRange) -> NSRange? {
        let delimiters = validNewlineCharacters.map { "\($0)\($0)".data(using: String.Encoding.utf8)! }

        for delimiter in delimiters {
            let foundRange = receivedDataBuffer.range(of: delimiter,
                                                      options: NSData.SearchOptions(),
                                                      in: searchRange)
            if foundRange.location != NSNotFound {
                return foundRange
            }
        }

        return nil
    }

    fileprivate func parseEventStream(_ events: [String]) {
        var parsedEvents: [(id: String?, event: String?, data: String?)] = Array()

        for event in events {
            if event.isEmpty {
                continue
            }

            if event.hasPrefix(":") {
                continue
            }

            if (event as NSString).contains("retry:") {
                if let reconnectTime = parseRetryTime(event) {
                    retryTime = reconnectTime
                }
                continue
            }

            parsedEvents.append(parseEvent(event))
        }

        for parsedEvent in parsedEvents {
            lastEventID = parsedEvent.id

            if parsedEvent.event == nil {
                if let data = parsedEvent.data, let onMessage = self.onMessageCallback {
                    DispatchQueue.main.async {
                        onMessage(self.lastEventID, "message", data)
                    }
                }
            }

            if let event = parsedEvent.event, let data = parsedEvent.data, let eventHandler = self.eventListeners[event] {
                DispatchQueue.main.async {
                    eventHandler(self.lastEventID, event, data)
                }
            }
        }
    }

    internal var lastEventID: String? {
        set {
            if let lastEventID = newValue {
                let defaults = UserDefaults.standard
                defaults.set(lastEventID, forKey: lastEventIDKey)
                defaults.synchronize()
            }
        }

        get {
            let defaults = UserDefaults.standard

            if let lastEventID = defaults.string(forKey: lastEventIDKey) {
                return lastEventID
            }
            return nil
        }
    }

    fileprivate func parseEvent(_ eventString: String) -> (id: String?, event: String?, data: String?) {
        var event = Dictionary<String, String>()

        for line in eventString.components(separatedBy: CharacterSet.newlines) as [String] {
            autoreleasepool {
                let (k, value) = self.parseKeyValuePair(line)
                guard let key = k else { return }

                if let value = value {
                    if event[key] != nil {
                        event[key] = "\(event[key]!)\n\(value)"
                    } else {
                        event[key] = value
                    }
                } else if value == nil {
                    event[key] = ""
                }
            }
        }

        return (event["id"], event["event"], event["data"])
    }

    fileprivate func parseKeyValuePair(_ line: String) -> (String?, String?) {
        var key: NSString?, value: NSString?
        let scanner = Scanner(string: line)
        scanner.scanUpTo(":", into: &key)
        scanner.scanString(":", into: nil)

        for newline in validNewlineCharacters {
            if scanner.scanUpTo(newline, into: &value) {
                break
            }
        }

        return (key as String?, value as String?)
    }

    fileprivate func parseRetryTime(_ eventString: String) -> Int? {
        var reconnectTime: Int?
        let separators = CharacterSet(charactersIn: ":")
        if let milli = eventString.components(separatedBy: separators).last {
            let milliseconds = trim(milli)

            if let intMiliseconds = Int(milliseconds) {
                reconnectTime = intMiliseconds
            }
        }
        return reconnectTime
    }

    fileprivate func trim(_ string: String) -> String {
        return string.trimmingCharacters(in: CharacterSet.whitespaces)
    }

    open class func basicAuth(_ username: String, password: String) -> String {
        let authString = "\(username):\(password)"
        let authData = authString.data(using: String.Encoding.utf8)
        let base64String = authData!.base64EncodedString(options: [])

        return "Basic \(base64String)"
    }
}
