//
//  PrintEntry.swift
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

// MARK: Bartleby's Core: A single print entry (bprint)
@objc(PrintEntry) open class PrintEntry : BartlebyObject{

    // Universal type support
    override open class func typeName() -> String {
        return "PrintEntry"
    }

	//The print entry counter
	dynamic open var counter:Int = -1

	//The referent line
	dynamic open var line:Int = -1

	//The elasped duration
	dynamic open var elapsed:Double = -1

	//the message
	dynamic open var message:String = "no message"

	//the file
	dynamic open var file:String = "no file"

	//the function
	dynamic open var function:String = "no function"

	//the category
	dynamic open var category:String = "no category"

	//Is the entry decorative or significant? decoration includes separators, etc...
	dynamic open var decorative:Bool = false

	//Is the entry decorative or significant? decoration includes separators, etc...
	dynamic private var _runUID:String = "\(Bartleby.runUID)"

    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["counter","line","elapsed","message","file","function","category","decorative"])
        return exposed
    }


    /// Set the value of the given key
    ///
    /// - parameter value: the value
    /// - parameter key:   the key
    ///
    /// - throws: throws an Exception when the key is not exposed
    override open func setExposedValue(_ value:Any?, forKey key: String) throws {
        switch key {

            case "counter":
                if let casted=value as? Int{
                    self.counter=casted
                }
            case "line":
                if let casted=value as? Int{
                    self.line=casted
                }
            case "elapsed":
                if let casted=value as? Double{
                    self.elapsed=casted
                }
            case "message":
                if let casted=value as? String{
                    self.message=casted
                }
            case "file":
                if let casted=value as? String{
                    self.file=casted
                }
            case "function":
                if let casted=value as? String{
                    self.function=casted
                }
            case "category":
                if let casted=value as? String{
                    self.category=casted
                }
            case "decorative":
                if let casted=value as? Bool{
                    self.decorative=casted
                }
            default:
                throw ObjectExpositionError.UnknownKey(key: key)
        }
    }


    /// Returns the value of an exposed key.
    ///
    /// - parameter key: the key
    ///
    /// - throws: throws Exception when the key is not exposed
    ///
    /// - returns: returns the value
    override open func getExposedValueForKey(_ key:String) throws -> Any?{
        switch key {

            case "counter":
               return self.counter
            case "line":
               return self.line
            case "elapsed":
               return self.elapsed
            case "message":
               return self.message
            case "file":
               return self.file
            case "function":
               return self.function
            case "category":
               return self.category
            case "decorative":
               return self.decorative
            default:
                return try super.getExposedValueForKey(key)
        }
    }
    // MARK: - Mappable

    required public init?(map: Map) {
        super.init(map:map)
    }

    override open func mapping(map: Map) {
        super.mapping(map: map)
        self.silentGroupedChanges {
			self.counter <- ( map["counter"] )
			self.line <- ( map["line"] )
			self.elapsed <- ( map["elapsed"] )
			self.message <- ( map["message"] )
			self.file <- ( map["file"] )
			self.function <- ( map["function"] )
			self.category <- ( map["category"] )
			self.decorative <- ( map["decorative"] )
			self._runUID <- ( map["_runUID"] )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {super.init(coder: decoder)
        self.silentGroupedChanges {
			self.counter=decoder.decodeInteger(forKey:"counter") 
			self.line=decoder.decodeInteger(forKey:"line") 
			self.elapsed=decoder.decodeDouble(forKey:"elapsed") 
			self.message=String(describing: decoder.decodeObject(of: NSString.self, forKey: "message")! as NSString)
			self.file=String(describing: decoder.decodeObject(of: NSString.self, forKey: "file")! as NSString)
			self.function=String(describing: decoder.decodeObject(of: NSString.self, forKey: "function")! as NSString)
			self.category=String(describing: decoder.decodeObject(of: NSString.self, forKey: "category")! as NSString)
			self.decorative=decoder.decodeBool(forKey:"decorative") 
			self._runUID=String(describing: decoder.decodeObject(of: NSString.self, forKey: "_runUID")! as NSString)
        }
    }

    override open func encode(with coder: NSCoder) {super.encode(with:coder)
		coder.encode(self.counter,forKey:"counter")
		coder.encode(self.line,forKey:"line")
		coder.encode(self.elapsed,forKey:"elapsed")
		coder.encode(self.message,forKey:"message")
		coder.encode(self.file,forKey:"file")
		coder.encode(self.function,forKey:"function")
		coder.encode(self.category,forKey:"category")
		coder.encode(self.decorative,forKey:"decorative")
		coder.encode(self._runUID,forKey:"_runUID")
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }


     required public init() {
        super.init()
    }

    // MARK: Identifiable

    override open class var collectionName:String{
        return "printEntries"
    }

    override open var d_collectionName:String{
        return PrintEntry.collectionName
    }

}
