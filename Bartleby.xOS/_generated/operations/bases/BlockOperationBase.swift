//
//  BlockOperationBase.swift
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
	import ObjectMapper
#endif

@objc(BlockOperationBase) public class BlockOperationBase : BartlebyObject,BartlebyOperation{

    // Universal type support
    override open class func typeName() -> String {
        return "BlockOperationBase"
    }

    fileprivate var _block:Block = Block()

    fileprivate var _documentUID:String=Default.NO_UID

    required public init() {
        super.init()
    }


    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["_block","_documentUID"])
        return exposed
    }


    /// Set the value of the given key
    ///
    /// - parameter value: the value
    /// - parameter key:   the key
    ///
    /// - throws: throws an Exception when the key is not exposed
    override open func setExposedValue(_ value:Any?, forKey key: String) throws {
        switch key {
            case "_block":
                if let casted=value as? Block{
                    self._block=casted
                }
            case "_documentUID":
                if let casted=value as? String{
                    self._documentUID=casted
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
    override open func getExposedValueForKey(_ key:String) throws -> Any?{
        switch key {
            case "_block":
               return self._block
            case "_documentUID":
               return self._documentUID
            default:
                return try super.getExposedValueForKey(key)
        }
    }
    // MARK: - Mappable

    required public init?(map: Map) {
        super.init(map:map)
    }

    override open func mapping(map: Map) {
        super.mapping(map: map)
        self.silentGroupedChanges {
			self._block <- ( map["_block"] )
			self._documentUID <- ( map["_documentUID"] )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.silentGroupedChanges {
			self._block=decoder.decodeObject(of:Block.self, forKey: "_block")! 
			self._documentUID=String(describing: decoder.decodeObject(of: NSString.self, forKey: "_documentUID")! as NSString)
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		coder.encode(self._block,forKey:"_block")
		coder.encode(self._documentUID,forKey:"_documentUID")
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }


    /**
     Returns an operation with self.UID as commandUID

     - returns: return the operation
     */
    fileprivate func _getOperation()->PushOperation{
        if let document = Bartleby.sharedInstance.getDocumentByUID(self._documentUID) {
            if let ic:PushOperationsManagedCollection = try? document.getCollection(){
                let pushOperations=ic.filter({ (pushOperation) -> Bool in
                    return pushOperation.commandUID==self.UID
                })
                if let pushOperation=pushOperations.first {
                    return pushOperation
                }}
        }
        let pushOperation=PushOperation()
        pushOperation.silentGroupedChanges {
            pushOperation.commandUID=self.UID
            pushOperation.defineUID()
        }
        return pushOperation
    }


    /**
    Creates the operation and proceeds to commit

    - parameter block: the instance
    - parameter documentUID:     the document UID
    */
    static func commit(_ block:Block, inDocumentWithUID documentUID:String){
        let operationInstance=BlockOperationBase()
        operationInstance._block=block
        operationInstance._documentUID=documentUID
        operationInstance.commit()
    }


    func commit(){
        let context=Context(code:1141150322, caller: "\(self.runTimeTypeName()).commit")
        if let document = Bartleby.sharedInstance.getDocumentByUID(self._documentUID) {
            // Provision the pushOperation.
            do{
                let ic:PushOperationsManagedCollection = try document.getCollection()
                let pushOperation=self._getOperation()
                pushOperation.counter += 1
                pushOperation.status=PushOperation.Status.pending
                pushOperation.creationDate=Date()
				pushOperation.summary="\(self.runTimeTypeName())(\(self._block.UID))"
                if let currentUser=document.metadata.currentUser{
                    pushOperation.creatorUID=currentUser.UID
                    self.creatorUID=currentUser.UID
                }
				self._block.committed=true

                pushOperation.toDictionary=self.dictionaryRepresentation()
                ic.add(pushOperation, commit:false)
            }catch{
               document.dispatchAdaptiveMessage(context,
                    title: "Structural Error",
                    body: "Operation collection is missing in \(self.runTimeTypeName())",
                    onSelectedIndex: { (selectedIndex) -> () in
                })
            }
        }else{
            glog(NSLocalizedString("Document is missing", comment: "Document is missing")+" documentUID =\(self._documentUID)", file: #file, function: #function, line: #line, category: Default.LOG_CATEGORY, decorative: false)
        }
    }

    open func push(sucessHandler success:@escaping (_ context:HTTPContext)->(),
        failureHandler failure:@escaping (_ context:HTTPContext)->()){
        // The unitary operation are not always idempotent
        // so we do not want to push multiple times unintensionnaly.
        // Check BartlebyDocument+Operations.swift to understand Operation status
        let pushOperation=self._getOperation()
        if  pushOperation.canBePushed(){
            // We try to execute
            pushOperation.status=PushOperation.Status.inProgress
            type(of: self).execute(self._block,
                inDocumentWithUID:self._documentUID,
                sucessHandler: { (context: HTTPContext) -> () in 
					self._block.distributed=true
                    pushOperation.counter=pushOperation.counter+1
                    pushOperation.status=PushOperation.Status.completed
                    pushOperation.responseDictionary=Mapper<HTTPContext>().toJSON(context)
                    pushOperation.lastInvocationDate=Date()
                    let completion=Completion.successStateFromHTTPContext(context)
                    completion.setResult(context)
                    pushOperation.completionState=completion
                    success(context)
                },
                failureHandler: {(context: HTTPContext) -> () in
                    pushOperation.counter=pushOperation.counter+1
                    pushOperation.status=PushOperation.Status.completed
                    pushOperation.responseDictionary=Mapper<HTTPContext>().toJSON(context)
                    pushOperation.lastInvocationDate=Date()
                    let completion=Completion.failureStateFromHTTPContext(context)
                    completion.setResult(context)
                    pushOperation.completionState=completion
                    failure(context)
                }
            )
        }else{
            // This document is not available there is nothing to do.
            glog(NSLocalizedString("Document is missing", comment: "Document is missing")+" documentUID =\(self._documentUID)", file: #file, function: #function, line: #line, category: Default.LOG_CATEGORY, decorative: false)
        }
    }


    /// Should be implemented in a children.
    /// Don't forget to override typeName()
    /// - Parameters:
    ///   - block: the block    ///   - documentUID: the documentUID
    ///   - success: the success closure
    ///   - failure: the failure closure
    open class func execute(_ block:Block,
            inDocumentWithUID documentUID:String,
            sucessHandler success: @escaping(_ context:HTTPContext)->(),
            failureHandler failure: @escaping(_ context:HTTPContext)->()){
    }
}
