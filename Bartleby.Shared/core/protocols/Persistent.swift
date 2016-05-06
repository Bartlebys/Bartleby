//
//  Persistent.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 03/11/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation


/**
 * Adopt this protocol to use  persistency layer like SQLite's
 *
 * You can implement Indexes to allow to query internal members.
 * To retrieve an indexed object you should first fetch the UIDS by Index
 * Then fetch the Instances by their UID.
 */
public protocol Persistent {

    /**
     Returns a tuple with enough information to insure simple stringifyed persistency
     including Classifiers that will be indexed for fetching, ordering, sorting, ...

     You can use Classifiers for example :
        - A,B for two dates (timeIntervalSince1970,timeIntervalSince1970)
        - C,D,E for a geocoding information (long, lat, zoom)
        - S for contextual information ( ... )


     - returns: a tuple composed by the Primary ID : UID, the related collection name, the serialization string, + Classifiers.
     */
    func toPersistentRepresentation()->(UID: String, collectionName: String, serializedUTF8String: String, A: Double, B: Double, C: Double, D: Double, E: Double, S: String)

    /**
     Deserializes from the string

     - parameter serializedUTF8String: serializedUTF8String description

     - returns: the serialized object
     */
    static func fromSerializedUTF8String(serializedUTF8String: String)->Serializable

}
