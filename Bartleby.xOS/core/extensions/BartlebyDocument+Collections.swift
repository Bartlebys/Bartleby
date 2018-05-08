//
//  BartlebyDocument+Collections.swift
//  bartleby
//
//  Created by Benoit Pereira da silva on 25/11/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

extension BartlebyDocument {

    // MARK: - Collections Public API

    open func getCollection<T: CollectibleCollection>() throws -> T {
        guard let collection = self.collectionByName(T.collectionName) as? T else {
            throw DocumentError.unExistingCollection(collectionName: T.collectionName)
        }
        return collection
    }

    /**
     Returns the collection Names.

     - returns: the names
     */
    open func getCollectionsNames() -> [String] {
        return _collections.map { $0.0 }
    }

    // Any call should always be casted to a IterableCollectibleCollection
    open func collectionByName(_ name: String) -> BartlebyCollection? {
        if _collections.keys.contains(name) {
            return _collections[name]
        }
        return nil
    }

    // Weak Casting for internal behavior
    // Those dynamic method are only used internally
    internal func _addCollection(_ collection: BartlebyCollection) {
        let collectionName = collection.d_collectionName
        _collections[collectionName] = collection
    }

    /**
     Returns the collection file name

     - parameter metadatum: the collectionMetadatim

     - returns: the crypted and the non crypted file name in a tupple.
     */
    internal func _collectionFileNames(_ metadatum: CollectionMetadatum) -> (notCrypted: String, crypted: String) {
        let cryptedExtension = BartlebyDocument.DATA_EXTENSION
        let nonCryptedExtension = ".\(serializer.fileExtension)"
        let cryptedFileName = metadatum.collectionName + cryptedExtension
        let nonCryptedFileName = metadatum.collectionName + nonCryptedExtension
        return (notCrypted: nonCryptedFileName, crypted: cryptedFileName)
    }
}
