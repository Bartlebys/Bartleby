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
            DispatchQueue.main.async(execute: {
                if result==NSFileHandlingPanelOKButton{
                    if let url = savePanel.url {
                        let filePath=url.path
                        self.exportMetadataTo(filePath,crypted: crypted, handlers:handlers)
                    }
                }
            })
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
            DispatchQueue.main.async(execute: {
                if result==NSFileHandlingPanelOKButton{
                    if let url = openPanel.url {
                        let filePath=url.path
                        self.importMetadataFrom(filePath,crypted: crypted,handlers:handlers)
                
                    }
                }
            })
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
            let dictionary=["excludeTriggers":"true","observationUID":self.metadata.rootObjectUID];

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
    
    
}
