//
//  MasterKey+Helper.swift
//  Bartleby macOS
//
//  Created by Benoit Pereira da silva on 12/08/2017.
//

import Foundation
#if os(OSX)
    import Cocoa
#endif

extension MasterKey{

    #if os(OSX)
    open static func save(from document:BartlebyDocument){
        do{
            // Create a master key from the current document.
            let masterKey = MasterKey()
            masterKey.password = document.currentUser.password ?? Default.NO_PASSWORD
            masterKey.key = document.metadata.sugar

            // Ask where to save its crypted data
            let encoded = try JSON.encoder.encode(masterKey)
            let data = try Bartleby.cryptoDelegate.encryptData(encoded, useKey: Bartleby.configuration.KEY)
            let url = document.fileURL
            let ext = (url?.pathExtension == nil) ? "" : "."+url!.pathExtension
            let name = url?.lastPathComponent.replacingOccurrences(of:ext, with: "") ?? NSLocalizedString("Untitled", comment: "Untitled")
            if let window=document.windowControllers.first?.window{
                let savePanel = NSSavePanel()
                savePanel.message = NSLocalizedString("Where do you want to save the key?", comment: "Where do you want to save the key?")
                savePanel.prompt = NSLocalizedString("Save", comment: "Save")
                savePanel.nameFieldStringValue = name
                savePanel.canCreateDirectories = true
                savePanel.allowedFileTypes=["bkey"]
                savePanel.beginSheetModal(for:window,completionHandler: { (result) in
                    if result.rawValue==NSFileHandlingPanelOKButton{
                        if let url = savePanel.url {
                            Bartleby.syncOnMain{
                                do{
                                    try data.write(to: url, options: Data.WritingOptions.atomic)
                                }catch{
                                    document.log("\(error)",category:Default.LOG_IDENTITY)
                                }
                            }
                        }
                    }
                    savePanel.close()
                })
            }
        }catch{
            document.log("\(error)",category:Default.LOG_IDENTITY)
        }
    }
    #endif
}
