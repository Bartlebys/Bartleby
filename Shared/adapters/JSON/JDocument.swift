//
//  JDocument.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 03/11/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation
#if !USE_EMBEDDED_MODULES
import ObjectMapper
#endif

@objc(JDocument) public class JDocument: Registry {

    #if os(OSX)
    required public init() {
        super.init()
    }
    #else
    
    private var _fileURL: NSURL
    
    public required init(fileURL url: NSURL) {
        self._fileURL = url
        super.init(fileUrl: url)
    }
    
    #endif

    override public func configureSchema(){
        super.configureSchema()
    }
        
    override public func registryDidLoad(){
        super.registryDidLoad() 
    }
    
    override public func registryWillSave() {
        super.registryWillSave()
    }
}

