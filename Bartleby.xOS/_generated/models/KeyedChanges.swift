//
//  KeyedChanges.swift
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

// MARK: Bartleby's Core: used to keep track of changes in memory when inspecting an App (Value Object)
@objc(KeyedChanges) open class KeyedChanges : UnManagedModel {


	//the elapsed time since the app has been launched
	dynamic open var elapsed:Double = Bartleby.elapsedTime

	//the key
	dynamic open var key:String = "\(Default.NO_KEY)"

	//A description of the changes that have occured
	dynamic open var changes:String = "\(Default.NO_MESSAGE)"


    // MARK: - Mappable

    required public init?(map: Map) {
        super.init(map:map)
    }

    override open func mapping(map: Map) {
        super.mapping(map: map)
        self.quietChanges {
			self.elapsed <- ( map["elapsed"] )
			self.key <- ( map["key"] )
			self.changes <- ( map["changes"] )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.quietChanges {
			self.elapsed=decoder.decodeDouble(forKey:"elapsed") 
			self.key=String(describing: decoder.decodeObject(of: NSString.self, forKey: "key")! as NSString)
			self.changes=String(describing: decoder.decodeObject(of: NSString.self, forKey: "changes")! as NSString)
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		coder.encode(self.elapsed,forKey:"elapsed")
		coder.encode(self.key,forKey:"key")
		coder.encode(self.changes,forKey:"changes")
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }

     required public init() {
        super.init()
    }
}