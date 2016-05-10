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
        Registry.declareCollectibleType(Alias<JObject>)
        Registry.declareCollectibleType(JCollectionMetadatum)
        Registry.declareCollectibleType(Alias<JCollectionMetadatum>)
        Registry.declareCollectibleType(JRegistryMetadata)
        Registry.declareCollectibleType(Alias<JRegistryMetadata>)
        Registry.declareCollectibleType(JHTTPResponse)
        Registry.declareCollectibleType(Alias<JHTTPResponse>)
        Registry.declareCollectibleType(LoginUser)
        Registry.declareCollectibleType(Alias<LoginUser>)
        Registry.declareCollectibleType(LogoutUser)
        Registry.declareCollectibleType(Alias<LogoutUser>)
        Registry.declareCollectibleType(VerifyLocker)
        Registry.declareCollectibleType(Alias<VerifyLocker>)
        Registry.declareCollectibleType(PushOperationTask)
        Registry.declareCollectibleType(Alias<PushOperationTask>)
        Registry.declareCollectibleType(ReactiveTask)
        Registry.declareCollectibleType(Alias<ReactiveTask>)
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
