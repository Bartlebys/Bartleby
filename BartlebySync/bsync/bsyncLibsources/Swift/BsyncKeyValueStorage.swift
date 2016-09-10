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



enum BsyncKeyValueStorageError: Error {
    case corruptedData
    case otherDataProblem
}

class BsyncKeyValueStorage {

    fileprivate var _kvs = [String : String]()
    fileprivate var _url: URL
    fileprivate var _shouldSave = false

    init(url: URL) {
        self._url = url
    }

    func open() throws {
        let fm = FileManager.default
        if let path = _url.path {
            if fm.fileExists(atPath: path) {
                if let data=try? Data(contentsOf: URL(fileURLWithPath: path)) {
                    if let kvs = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: String] {
                        _kvs = kvs
                    }
                }
            }
        }
    }

    func save() throws {
        if(_shouldSave) {
            let json = try JSONSerialization.data(withJSONObject: _kvs, options: JSONSerialization.WritingOptions.prettyPrinted)

            let fm = FileManager.default
            if let folderUrl = _url.deletingLastPathComponent() {
                if let folderPath = folderUrl.path {
                    if !fm.fileExists(atPath: folderPath) {
                        try fm.createDirectory(at: folderUrl, withIntermediateDirectories: false, attributes: [:])
                    }
                }
                try json.write(to: _url, options: NSData.WritingOptions.atomicWrite)
            }

        }
    }

    subscript (key: String) -> Serializable? {
        get {
            if let base64CryptedValueString = _kvs[key] {
                if let cryptedValueData = Data(base64Encoded: base64CryptedValueString, options: [.ignoreUnknownCharacters]) {
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
                    let newValueBase64CryptedString = newValueCryptedData.base64EncodedString(options: .endLineWithCarriageReturn)
                    _kvs[key] = newValueBase64CryptedString
                    _shouldSave = true
                } catch {

                }
            }
        }
    }




    func delete(_ key: String) {
        _kvs.removeValue(forKey: key)
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
        let fm = FileManager()
        try fm.removeItem(at: _url)
        _shouldSave = false
    }
}




// Direct Support of String and NSdata
extension BsyncKeyValueStorage{

    func setStringValue(_ value:String?,forKey key:String) -> () {
        let j=JString(from:value)
        self[key]=j
    }

    func  getStringValueForKey(_ key:String) -> String? {
        if let s = self[key] as? JString{
            return s.string
        }
        return nil
    }


    func setDataValue(_ value:Data,forKey key:String) -> () {
        let d=JData()
        d.data=value
        self[key]=d
    }

    func getDataValueForKey(_ key:String) -> Data? {
        if let d = self[key] as? JData{
            return d.data as Data?
        }
        return nil
    }

}
