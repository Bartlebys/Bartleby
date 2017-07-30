//
//  KeyedData.swift
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

// MARK: A simple wrapper to associate a key and a Data
@objc(KeyedData) open class KeyedData : UnManagedModel {


	//The key
	dynamic open var key:String = "\(Default.NO_KEY)"

	//The Data
	dynamic open var data:Data = Data()


    // MARK: - Mappable

    required public init?(map: Map) {
        super.init(map:map)
    }

    override open func mapping(map: Map) {
        super.mapping(map: map)
        self.quietChanges {
			self.key <- ( map["key"] )
			self.data <- ( map["data"], DataTransform() )
        }
    }

     required public init() {
        super.init()
    }
}