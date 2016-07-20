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


    /**

     You can associate disymetric Type name
     For example if you create an Alias class that uses Generics
     runTimeTypeName() & typeName() can diverges.

     **IMPORTANT** You Cannot use NSecureCoding for diverging classes

     The role of declareTypes() is to declare diverging members.
     Or to produce an adaptation layer (from a type to another)

     ## Let's take an advanced example:

     ```
     public class Alias<T:Collectible>:JObject {

     override public class func typeName() -> String {
        return "Alias<\(T.typeName())>"
     }

     ```
     Let's say we instantiate an Alias<Tag>

     To insure **cross product deserialization**
     Eg:  "_TtGC11BartlebyKit5AliasCS_3Tag_" or "_TtGC5bsync5AliasCS_3Tag_" are transformed to "Alias<Tag>"

     To associate those disymetric type you can add the class declareTypes
     And implement typeName() and runTimeTypeName()

     ```
     public class func declareTypes() {
        Registry.declareCollectibleType(Object)
        Registry.declareCollectibleType(Alias<Object>)

     ```
     */
    public class func declareTypes() {
        /*
         Registry.declareCollectibleType(Object)
         Registry.declareCollectibleType(Alias<Object>)
        */
    }

    #if os(OSX)
    required public init() {
        super.init()
        JDocument.declareTypes()
    }
    #else

    private var _fileURL: NSURL

    public required init(fileURL url: NSURL) {
        self._fileURL = url
        super.init(fileUrl: url)
        JDocument.declareTypes()
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
