//
//  BsyncKeyValueStorage.swift
//  bsync
//
//  Created by Martin Delille on 13/04/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

#if !USE_EMBEDDED_MODULES
    import BartlebyKit
#endif



enum BsyncKeyValueStorageError: ErrorType {
    case CorruptedData
    case OtherDataProblem
}

class BsyncKeyValueStorage {

    private var _kvs = [String : String]()
    private var _url: NSURL
    private var _shouldSave = false

    init(url: NSURL) {
        self._url = url
    }

    func open() throws {
        let fm = NSFileManager.defaultManager()
        if let path = _url.path {
            if fm.fileExistsAtPath(path) {
                if let data=NSData(contentsOfFile: path) {
                    if let kvs = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? [String: String] {
                        _kvs = kvs
                    }
                }
            }
        }
    }

    func save() throws {
        if(_shouldSave) {
            let json = try NSJSONSerialization.dataWithJSONObject(_kvs, options: NSJSONWritingOptions.PrettyPrinted)

            let fm = NSFileManager.defaultManager()
            if let folderUrl = _url.URLByDeletingLastPathComponent {
                if let folderPath = folderUrl.path {
                    if !fm.fileExistsAtPath(folderPath) {
                        try fm.createDirectoryAtURL(folderUrl, withIntermediateDirectories: false, attributes: [:])
                    }
                }
                try json.writeToURL(_url, options: NSDataWritingOptions.AtomicWrite)
            }

        }
    }

    subscript (key: String) -> Serializable? {
        get {
            if let base64CryptedValueString = _kvs[key] {
                if let cryptedValueData = NSData(base64EncodedString: base64CryptedValueString, options: [.IgnoreUnknownCharacters]) {
                    do {
                        let decryptedValueData =  try Bartleby.cryptoDelegate.decryptData(cryptedValueData)
                        return try JSerializer.deserialize(decryptedValueData)
                    } catch {

                    }
                }
            }
            return nil
        }
        set(newValue) {
            if let newValue = newValue {
                let newValueData = newValue.serialize()
                do {
                    let newValueCryptedData = try Bartleby.cryptoDelegate.encryptData(newValueData)
                    let newValueBase64CryptedString = newValueCryptedData.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn)
                    _kvs[key] = newValueBase64CryptedString
                    _shouldSave = true
                } catch {

                }
            }
        }
    }




    func delete(key: String) {
        _kvs.removeValueForKey(key)
        _shouldSave = true
    }

    func enumerate() -> [(String, String)] {
        var result = [(String, String)]()
        for (k, v) in _kvs {
            result.append((k, v))
        }
        return result
    }

    // Maybe we should
    func removeAll() throws {
        let fm = NSFileManager()
        try fm.removeItemAtURL(_url)
        _shouldSave = false
    }
}




// Direct Support of String and NSdata
extension BsyncKeyValueStorage{

    func setStringValue(value:String?,forKey key:String) -> () {
        let j=JString()
        j.string=value
        self[key]=j
    }

    func  getStringValueForKey(key:String) -> String? {
        if let s = self[key] as? JString{
            return s.string
        }
        return nil
    }


    func setDataValue(value:NSData,forKey key:String) -> () {
        let d=JData()
        d.data=value
        self[key]=d
    }

    func getDataValueForKey(key:String) -> NSData? {
        if let d = self[key] as? JData{
            return d.data
        }
        return nil
    }

}
