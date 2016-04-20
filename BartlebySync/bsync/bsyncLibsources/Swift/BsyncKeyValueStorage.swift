//
//  BsyncKeyValueStorage.swift
//  bsync
//
//  Created by Martin Delille on 13/04/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

enum BsyncKeyValueStorageError : ErrorType {
    case CorruptedData
    case OtherDataProblem
}

extension String:DataSerializable{
    
}

class BsyncKeyValueStorage {
    
    private var _kvs = [String : DataSerializable]()
    private var _filePath: String
    private var _shouldSave = false
    
    init(filePath: String) {
        _filePath = filePath
    }
    
    func open() throws {
        let fm = NSFileManager.defaultManager()
        if fm.fileExistsAtPath(_filePath){
            if let data=NSData(contentsOfFile: _filePath){
                let JSONString=String(data: data, encoding: NSUTF8StringEncoding)
                if let k = Mapper<CryptedKeyValueStorage>().map(JSONString){
                    _kvs = k
                } else {
                    throw BsyncKeyValueStorageError.CorruptedData
                }
            } else {
                throw BsyncKeyValueStorageError.OtherDataProblem
            }
        }
    }
    
    func save() throws {
        if(_shouldSave) {
            if let s:String = _kvs?.toJSONString(){
                if let sdata:NSData=s.dataUsingEncoding(NSUTF8StringEncoding){
                    sdata.writeToFile(_filePath,atomically: true)
                    _shouldSave = false
                }
                
            } else {
                throw BsyncKeyValueStorageError.OtherDataProblem
            }
        }
        
    }
    
    subscript (key: String) -> DataSerializable? {
        get {
            if let kvs = _kvs {
                return kvs.storage[key]
            } else {
                return nil
            }
        }
        set(newValue) {
            if let kvs = _kvs {
                kvs.storage[key] = newValue
                _shouldSave = true
            }
        }
    }
    
    // For generic mappable, I wasn't able to use a subscript
    func read<T: DataSerializable>(key: String) -> T? {
        if let kvs = _kvs {
            return Mapper<T>().map(kvs.storage[key])
        } else {
            return nil
        }
    }
    
    func upsert<T: DataSerializable>(key: String, value: T) {
        if let kvs = _kvs {
            kvs.storage[key] = Mapper<T>().toJSONString(value)
            _shouldSave = true
        }
    }
    
    func delete(key: String) {
        if let kvs = _kvs {
            kvs.storage.removeValueForKey(key)
            _shouldSave = true
        }
    }
    
    func enumerate() -> [(String, String)] {
        var result = [(String, String)]()
        if let kvs = _kvs {
            for (k, v) in kvs.storage {
                result.append((k, v))
            }
        }
        return result
    }
    
    // Maybe we should
    func removeAll() throws {
        let fm = NSFileManager()
        try fm.removeItemAtPath(_filePath)
        _shouldSave = false
    }
}