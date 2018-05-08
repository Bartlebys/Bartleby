//
//  UpdateNode.swift
//  Bartleby
//
// THIS FILE AS BEEN GENERATED BY BARTLEBYFLEXIONS for [Benoit Pereira da Silva] (https://pereira-da-silva.com/contact)
// DO NOT MODIFY THIS FILE YOUR MODIFICATIONS WOULD BE ERASED ON NEXT GENERATION!
//
// Copyright (c) 2016  [Bartleby's org] (https://bartlebys.org)   All rights reserved.
//
import Foundation
#if !USE_EMBEDDED_MODULES
    import Alamofire
#endif

@objc public class UpdateNode: ManagedModel, BartlebyOperation {
    // Universal type support
    open override class func typeName() -> String {
        return "UpdateNode"
    }

    open override class var collectionName: String { return "embeddedInPushOperations" }

    open override var d_collectionName: String { return "embeddedInPushOperations" }

    fileprivate var _payload: Data?

    public required init() {
        super.init()
    }

    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    open override var exposedKeys: [String] {
        var exposed = super.exposedKeys
        exposed.append(contentsOf: ["_payload"])
        return exposed
    }

    /// Set the value of the given key
    ///
    /// - parameter value: the value
    /// - parameter key:   the key
    ///
    /// - throws: throws an Exception when the key is not exposed
    open override func setExposedValue(_ value: Any?, forKey key: String) throws {
        switch key {
        case "_payload":
            if let casted = value as? Data {
                _payload = casted
            }
        default:
            return try super.setExposedValue(value, forKey: key)
        }
    }

    /// Returns the value of an exposed key.
    ///
    /// - parameter key: the key
    ///
    /// - throws: throws Exception when the key is not exposed
    ///
    /// - returns: returns the value
    open override func getExposedValueForKey(_ key: String) throws -> Any? {
        switch key {
        case "_payload":
            return _payload
        default:
            return try super.getExposedValueForKey(key)
        }
    }

    // MARK: - Codable

    public enum payloadCodingKeys: String, CodingKey {
        case _payload
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        try quietThrowingChanges {
            let values = try decoder.container(keyedBy: payloadCodingKeys.self)
            self._payload = try values.decode(Data.self, forKey: ._payload)
        }
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: payloadCodingKeys.self)
        try container.encode(_payload, forKey: ._payload)
    }

    /**
     Creates the operation and proceeds to commit

     - parameter node: the instance
     - parameter document:     the document
     */
    static func commit(_ node: Node, in document: BartlebyDocument) {
        // The operation instance is serialized in a pushOperation
        // That's why we donnot use the document factory to create this instance.
        let operationInstance = UpdateNode()
        operationInstance.UID = Bartleby.createUID()
        operationInstance.referentDocument = document
        let context = Context(code: 3_873_361_880, caller: "\(operationInstance.runTimeTypeName()).commit")
        do {
            operationInstance._payload = try JSON.encoder.encode(node.self)
            let ic: ManagedPushOperations = try document.getCollection()
            // Create the pushOperation
            let pushOperation: PushOperation = document.newManagedModel(commit: false, isUndoable: false)
            pushOperation.quietChanges {
                pushOperation.commandUID = operationInstance.UID
                pushOperation.collection = ic
                pushOperation.counter += 1
                pushOperation.status = PushOperation.Status.pending
                pushOperation.creationDate = Date()
                pushOperation.summary = "\(operationInstance.runTimeTypeName())(\(node.UID))"
                pushOperation.creatorUID = document.metadata.currentUserUID
                operationInstance.creatorUID = document.metadata.currentUserUID

                Bartleby.markCommitted(node.UID)
            }
            pushOperation.operationName = UpdateNode.typeName()
            pushOperation.serialized = operationInstance.serialize()
        } catch {
            document.dispatchAdaptiveMessage(context,
                                             title: "Structural Error",
                                             body: "Operation collection is missing in \(operationInstance.runTimeTypeName())",
                                             onSelectedIndex: { (_) -> Void in
            })
            glog("\(error)", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
        }
    }

    open func push(sucessHandler success: @escaping (_ context: HTTPContext) -> Void,
                   failureHandler failure: @escaping (_ context: HTTPContext) -> Void) {
        do {
            let node = try JSON.decoder.decode(Node.self, from: _payload ?? Data())
            // The unitary operation are not always idempotent
            // so we do not want to push multiple times unintensionnaly.
            // Check BartlebyDocument+Operations.swift to understand Operation status
            let pushOperation = try _getOperation()
            // Provision the operation
            if pushOperation.canBePushed() {
                pushOperation.status = PushOperation.Status.inProgress
                type(of: self).execute(node,
                                       in: documentUID,
                                       sucessHandler: { (context: HTTPContext) -> Void in
                                           pushOperation.counter = pushOperation.counter + 1
                                           pushOperation.status = PushOperation.Status.completed
                                           pushOperation.responseData = try? JSON.encoder.encode(context)
                                           pushOperation.lastInvocationDate = Date()
                                           let completion = Completion.successStateFromHTTPContext(context)
                                           completion.setResult(context)
                                           pushOperation.completionState = completion
                                           success(context)
                                       },
                                       failureHandler: { (context: HTTPContext) -> Void in
                                           pushOperation.counter = pushOperation.counter + 1
                                           pushOperation.status = PushOperation.Status.completed
                                           pushOperation.responseData = try? JSON.encoder.encode(context)
                                           pushOperation.lastInvocationDate = Date()
                                           let completion = Completion.failureStateFromHTTPContext(context)
                                           completion.setResult(context)
                                           pushOperation.completionState = completion
                                           failure(context)
                                       }
                )
            } else {
                referentDocument?.log("UpdateNode can't be pushed \(pushOperation.status)", file: #file, function: #function, line: #line, category: Default.LOG_FAULT, decorative: false)
            }
        } catch {
            let context = HTTPContext(code: 3,
                                      caller: "UpdateNode.execute",
                                      relatedURL: nil,
                                      httpStatusCode: StatusOfCompletion.undefined.rawValue)
            context.message = "\(error)"
            failure(context)
            referentDocument?.log("\(error)", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
        }
    }

    internal func _getOperation() throws -> PushOperation {
        if let document = Bartleby.sharedInstance.getDocumentByUID(self.documentUID) {
            if let idx = document.pushOperations.index(where: { $0.commandUID == self.UID }) {
                return document.pushOperations[idx]
            }
            throw BartlebyOperationError.operationNotFound(UID: "UpdateNode: \(UID)")
        }
        throw BartlebyOperationError.documentNotFound(documentUID: "UpdateNode: \(documentUID)")
    }

    open class func execute(_ node: Node,
                            in documentUID: String,
                            sucessHandler success: @escaping (_ context: HTTPContext) -> Void,
                            failureHandler failure: @escaping (_ context: HTTPContext) -> Void) {
        if let document = Bartleby.sharedInstance.getDocumentByUID(documentUID) {
            let pathURL = document.baseURL.appendingPathComponent("node")
            var parameters = [String: Any]()
            parameters["node"] = node.dictionaryRepresentation()
            let urlRequest = HTTPManager.requestWithToken(inDocumentWithUID: document.UID, withActionName: "UpdateNode", forMethod: "PUT", and: pathURL)
            do {
                let r = try JSONEncoding().encode(urlRequest, with: parameters)
                request(r).responseJSON(completionHandler: { response in

                    // Store the response
                    let request = response.request
                    let result = response.result
                    let timeline = response.timeline
                    let statusCode = response.response?.statusCode ?? 0

                    // Bartleby consignation
                    let context = HTTPContext(code: 3_752_107_916,
                                              caller: "UpdateNode.execute",
                                              relatedURL: request?.url,
                                              httpStatusCode: statusCode)

                    if let request = request {
                        context.request = HTTPRequest(urlRequest: request)
                    }

                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                        context.responseString = utf8Text
                    }
                    // React according to the situation
                    var reactions = Array<Reaction>()

                    if result.isFailure {
                        let m = NSLocalizedString("update  of node",
                                                  comment: "update of node failure description")
                        let failureReaction = Reaction.dispatchAdaptiveMessage(
                            context: context,
                            title: NSLocalizedString("Unsuccessfull attempt result.isFailure is true",
                                                     comment: "Unsuccessfull attempt"),
                            body: "\(m) \n \(response)" + "\n\(#file)\n\(#function)\nhttp Status code: (\(statusCode))",
                            transmit: { (_) -> Void in
                        })
                        reactions.append(failureReaction)
                        failure(context)
                    } else {
                        if 200 ... 299 ~= statusCode {
                            // Acknowledge the trigger if there is one
                            if let dictionary = result.value as? Dictionary<String, AnyObject> {
                                if let index = dictionary["triggerIndex"] as? NSNumber,
                                    let triggerRelayDuration = dictionary["triggerRelayDuration"] as? NSNumber {
                                    if index.intValue >= 0 {
                                        // -2 means the trigger relay has been discarded (the status code can be in 200...299
                                        // -1 means an error has occured (the status code should be >299
                                        let acknowledgment = Acknowledgment()
                                        acknowledgment.httpContext = context
                                        acknowledgment.operationName = "UpdateNode"
                                        acknowledgment.triggerIndex = index.intValue
                                        acknowledgment.latency = timeline.latency
                                        acknowledgment.requestDuration = timeline.requestDuration
                                        acknowledgment.serializationDuration = timeline.serializationDuration
                                        acknowledgment.totalDuration = timeline.totalDuration
                                        acknowledgment.triggerRelayDuration = triggerRelayDuration.doubleValue
                                        acknowledgment.uids = [node.UID]
                                        document.record(acknowledgment)
                                        document.report(acknowledgment) // Acknowlegments are also metrics
                                    }
                                }
                            }
                            success(context)
                        } else {
                            // Bartlby does not currenlty discriminate status codes 100 & 101
                            // and treats any status code >= 300 the same way
                            // because we consider that failures differentiations could be done by the caller.

                            let m = NSLocalizedString("update of node",
                                                      comment: "update of node failure description")
                            let failureReaction = Reaction.dispatchAdaptiveMessage(
                                context: context,
                                title: NSLocalizedString("Unsuccessfull attempt",
                                                         comment: "Unsuccessfull attempt"),
                                body: "\(m) \n \(response)" + "\n\(#file)\n\(#function)\nhttp Status code: (\(statusCode))",
                                transmit: { (_) -> Void in
                            })
                            reactions.append(failureReaction)
                            failure(context)
                        }
                    }
                    // Let's react according to the context.
                    document.perform(reactions, forContext: context)
                })
            } catch {
                let context = HTTPContext(code: 2,
                                          caller: "UpdateNode.execute",
                                          relatedURL: nil,
                                          httpStatusCode: StatusOfCompletion.undefined.rawValue)
                context.message = "\(error)"
                failure(context)
            }

        } else {
            glog(NSLocalizedString("Document is missing", comment: "Document is missing") + " documentUID =\(documentUID)", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
        }
} }
