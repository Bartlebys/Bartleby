//
//  BsyncHashMap+Filter.swift
//  bsync
//
//  Created by Benoit Pereira da silva on 13/06/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

extension BsyncHashMap{

    /**
     A facility to transform ObjC HashMap to BsyncHashMap

     - parameter hashMap: the HashMap

     - returns: the BsyncHashMap
     */
    public static func fromHashMap(hashMap:HashMap)->BsyncHashMap{
        let instance=BsyncHashMap()
        instance.pathToHash=hashMap.dictionaryRepresentation()[pathToHashKey] as! Dictionary<String,String>
        return instance
    }

    /**
     Returns a filtered BsyncHashMap

     - parameter matches: the filtering closure

     - returns: the filtered BsyncHashMap
     */
    public func filter(@noescape matches:(relativePath:String)->Bool)->BsyncHashMap{
        let filteredHashMap=BsyncHashMap()
        for (path,checksum) in self.pathToHash {
            if matches(relativePath:path){
                filteredHashMap.pathToHash[path]=checksum
            }
        }
        return filteredHashMap
    }
    
    
}