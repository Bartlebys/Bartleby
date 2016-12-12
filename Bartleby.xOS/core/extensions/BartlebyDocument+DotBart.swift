//
//  Documente+AppKitFacilities.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 08/07/2016.
//
//

import Foundation

#if os(OSX)
    import AppKit
#else
    import UIKit
#endif

#if !USE_EMBEDDED_MODULES
    import Alamofire
#endif


extension BartlebyDocument {

    #if os(OSX)

    //MARK: - APP KIT FACILITIES

    /**
     Saves the Metadata to a file

     - parameter crypted: should the data be crypted?
     */
    public func saveMetadata(_ crypted:Bool,handlers: Handlers){
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.nameFieldStringValue = self.fileURL?.lastPathComponent ?? "metadata"
        if crypted{
            savePanel.allowedFileTypes=["bart"]
        }else{
            savePanel.allowedFileTypes=["json"]
        }
        savePanel.begin(completionHandler: { (result) in
           Async.main{
                if result==NSFileHandlingPanelOKButton{
                    if let url = savePanel.url {
                        let filePath=url.path
                        self.exportMetadataTo(filePath,crypted: crypted, handlers:handlers)
                    }
                }
            }
        })
    }

    /**
     Loads the  Metadata from a file and apply it to a BartlebyDocument

     - parameter crypted: should the data be decrypted?
     */
    public func loadMetadata(_ crypted:Bool,handlers: Handlers){
        let openPanel = NSOpenPanel()
        openPanel.canCreateDirectories = false
        if crypted{
            openPanel.allowedFileTypes=["bart"]
        }else{
            openPanel.allowedFileTypes=["json"]
        }
        openPanel.begin(completionHandler: { (result) in
           Async.main{
                if result==NSFileHandlingPanelOKButton{
                    if let url = openPanel.url {
                        let filePath=url.path
                        self.importMetadataFrom(filePath,crypted: crypted,handlers:handlers)
                
                    }
                }
            }
        })
    }


    #endif

    /**
     Call the export Endpoint

     - parameter handlers: the handlers
     */
    public func importCollectionsFromCollaborativeServer(_ handlers: Handlers){
        self.currentUser.login( sucessHandler: {

            let pathURL=self.baseURL.appendingPathComponent("/Export")
            let dictionary=["excludeTriggers":"true","observationUID":self.metadata.persistentUID];

            let urlRequest=HTTPManager.requestWithToken(inDocumentWithUID:self.UID, withActionName:"Export", forMethod:"GET", and: pathURL)

            do {
                let r=try URLEncoding().encode(urlRequest,with:dictionary)
                request(r).validate().responseJSON(completionHandler: { (response) in

                let result=response.result
                let httpResponse=response.response

                if result.isFailure {
                   let completionState = Completion.failureStateFromAlamofire(response)
                    handlers.on(completionState)
                } else {

                    if let statusCode=httpResponse?.statusCode {
                        if 200...299 ~= statusCode {
                            var issues=[String]()
                            if let dictionary=result.value as? [String:Any]{
                                if let collections=dictionary["collections"] as? [String:Any] {
                                    for (collectionName,collectionData) in collections{
                                        if let proxy=self.collectionByName(collectionName) as? CollectibleCollection,
                                            let collectionDictionary=collectionData as? [Any]{
                                            for itemRep in collectionDictionary{
                                                if let itemRepDictionary = itemRep as? [String:Any]{
                                                    do {
                                                        if let instance=try Bartleby.defaultSerializer.deserializeFromDictionary(itemRepDictionary) as? Collectible{
                                                            if let user:User=instance as? User{
                                                                // We donnot want to expose the document current user
                                                                if user.creatorUID != user.UID{
                                                                    proxy.upsert(instance,commit:false)
                                                                }
                                                            }else{
                                                                // We want to upsert any object
                                                                proxy.upsert(instance,commit:false)
                                                            }
                                                        }
                                                    }catch{
                                                        issues.append("\(error)")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            if issues.count==0{
                                handlers.on(Completion.successState())
                            }else{
                                handlers.on(Completion.failureState(issues.joined(separator: "\n"), statusCode: StatusOfCompletion.expectation_Failed))
                            }
                        } else {
                            var status = StatusOfCompletion.undefined
                            if let statusCode=httpResponse?.statusCode{
                                status = StatusOfCompletion (rawValue:statusCode) ?? StatusOfCompletion.undefined
                            }
                            handlers.on(Completion.failureState("\(result)", statusCode:status ))
                        }
                    }
                }
            })
            }catch{
                handlers.on(Completion.failureStateFromError(error))
            }

        }) { (context) in
            handlers.on(Completion.failureStateFromHTTPContext(context))
        }
        
    }

    /**
     Export the metadata to a given path

     - parameter path: the path

     - parameter crypted : should the file be crypted? ( true is highly recommanded)

     */
    public func exportMetadataTo(_ path:String,crypted:Bool, handlers: Handlers) {
        do{
            let data = try self._getSerializedMetadata(crypted)
            Bartleby.fileManager.writeData(data, path: path, handlers: Handlers(completionHandler: { (dataWritten) in
                handlers.on(dataWritten)
            }))
        }catch{
            handlers.on(Completion.failureStateFromError(error))
        }
    }

    /**
     Imports the metadata from a given path

     - parameter path: the import path

     - parameter handlers: the handlers

     */
    public func importMetadataFrom(_ path:String,crypted:Bool,handlers: Handlers) {
        let readDataHandler=Handlers { (dataCompletion) in
            if var data=dataCompletion.data{
                do{
                    if crypted{
                        data = try Bartleby.cryptoDelegate.decryptData(data)
                    }
                    if let newDocumentMetadata=try Bartleby.defaultSerializer.deserialize(data) as? DocumentMetadata{
                        newDocumentMetadata.saveThePassword=false // Do not allow password bypassing on .bart import
                        self.dotBart=true// turn on the flag (the UI should ask for the password)
                        let previousUID=self.UID
                        Bartleby.sharedInstance.forget(previousUID)

                        // Disconnect from SSE
                        self._closeSSE()

                        // Reallocate the new  Metadata
                        self.metadata=newDocumentMetadata
                        Bartleby.sharedInstance.declare(self)
                        self.metadata.currentUser?.referentDocument=self

                        // Reconnect to SSE
                        self._connectToSSE()

                        handlers.on(Completion.successState())
                    }else{
                        handlers.on(Completion.failureState("Deserialization of document has failed", statusCode: StatusOfCompletion.expectation_Failed))
                    }
                }catch{
                    handlers.on(Completion.failureStateFromError(error))
                }

            }else{
                handlers.on(dataCompletion)
            }
        }
        Bartleby.fileManager.readData(contentsOfFile:path, handlers: readDataHandler)
    }


    /**

     - parameter crypted: is set to true the metadata will be crypted (recommanded)

     - throws: serialization exceptions

     - returns: the NSData
     */
    fileprivate func _getSerializedMetadata(_ crypted:Bool=true) throws -> Data{
        let serializedMetadata=self.metadata.serialize()
        if crypted{
            return try Bartleby.cryptoDelegate.encryptData(serializedMetadata)
        }else{
            return serializedMetadata as Data
        }
    }

    /**

     - parameter data: the serialized data

     - throws: deserialization exceptions
     */
    fileprivate func _useSerializedMetadata(_ data:Data) throws {
        if let metadata = try Bartleby.defaultSerializer.deserialize(data) as? DocumentMetadata{
            self.metadata=metadata
        }
    }

    
    
}
