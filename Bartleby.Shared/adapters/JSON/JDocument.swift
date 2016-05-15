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

public class JDocument: Registry {

    public class func declareCollectibleTypes() {
        Registry.declareCollectibleType(JObject)
        Registry.declareCollectibleType(ExternalReference)
       // Registry.declareCollectibleType(ExternalReference<JObject>)
        Registry.declareCollectibleType(CollectionMetadatum)
        //Registry.declareCollectibleType(ExternalReference<CollectionMetadatum>)
        Registry.declareCollectibleType(RegistryMetadata)
        //Registry.declareCollectibleType(ExternalReference<JRegistryMetadata>)
        Registry.declareCollectibleType(JHTTPResponse)
        //Registry.declareCollectibleType(ExternalReference<JHTTPResponse>)
        Registry.declareCollectibleType(LoginUser)
        //Registry.declareCollectibleType(ExternalReference<LoginUser>)
        Registry.declareCollectibleType(LogoutUser)
        //Registry.declareCollectibleType(ExternalReference<LogoutUser>)
        Registry.declareCollectibleType(VerifyLocker)
        //Registry.declareCollectibleType(ExternalReference<VerifyLocker>)
        Registry.declareCollectibleType(PushOperationTask)
        //Registry.declareCollectibleType(ExternalReference<PushOperationTask>)
        Registry.declareCollectibleType(ReactiveTask)
        //Registry.declareCollectibleType(ExternalReference<ReactiveTask>)
    }

    #if os(OSX)
    required public init() {
        super.init()
        JDocument.declareCollectibleTypes()
    }
    #else

    private var _fileURL: NSURL

    public required init(fileURL url: NSURL) {
        self._fileURL = url
        super.init(fileUrl: url)
        JDocument.declareCollectibleTypes()
    }

    #endif

    override public func configureSchema() {
        super.configureSchema()
    }

    override public func registryDidLoad() {
        super.registryDidLoad()
    }

    override public func registryWillSave() {
        super.registryWillSave()
    }
}
