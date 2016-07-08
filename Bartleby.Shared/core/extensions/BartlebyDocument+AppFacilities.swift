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



extension BartlebyDocument {


    #if os(OSX)


    //MARK: - APP KIT FACILITIES

    /**
     Saves the registry Metadata to a file

     - parameter crypted: should the data be crypted?
     */
    public func saveMetadata(crypted:Bool){
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        if crypted{
            savePanel.allowedFileTypes=["data"]
        }else{
            savePanel.allowedFileTypes=["json"]
        }
        savePanel.beginWithCompletionHandler({ (result) in
            if result==NSFileHandlingPanelOKButton{
                if let url = savePanel.URL {
                    if let filePath=url.path {
                        self.exportMetadataTo(filePath,crypted: crypted, handlers:Handlers(completionHandler: { (exported) in
                            if exported.success==false{
                                bprint("Failure on metadata export \(exported)", file: #file, function: #function, line: #line, category:Default.BPRINT_CATEGORY, decorative: false)
                            }
                        })
                        )
                    }
                }
            }
        })
    }

    /**
     Loads the registry Metadata from a file and apply it to a BartlebyDocument

     - parameter crypted: should the data be decrypted?
     */
    public func loadMetadata(crypted:Bool){
        let openPanel = NSOpenPanel()
        openPanel.canCreateDirectories = false
        if crypted{
            openPanel.allowedFileTypes=["data"]
        }else{
            openPanel.allowedFileTypes=["json"]
        }
        openPanel.beginWithCompletionHandler({ (result) in
            if result==NSFileHandlingPanelOKButton{
                if let url = openPanel.URL {
                    if let filePath=url.path {
                    self.importMetadataFrom(filePath,crypted: crypted,handlers:Handlers(completionHandler: { (imported) in
                            if imported.success==false{
                                bprint("Failure on metadata imported \(imported)", file: #file, function: #function, line: #line, category:Default.BPRINT_CATEGORY, decorative: false)
                            }
                        })
                        )
                    }
                }
            }

        })
    }

    
    #endif





}
