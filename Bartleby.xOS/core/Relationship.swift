//
//  Contract.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 07/12/2016.
//
//
import Foundation

// Check ManagedModel+Relationships for details.

public enum Relationship:String{

    // MARK: - Without reciprocity

    case free="free" // In case of deletion of one of the related terms the other is preserved (there is not necessarly reciprocity of the relation)

    // MARK: - With reciprocity

    case owned="owned"// In case of deletion of the owner the owned is automatically deleted. (the contract is exclusive)
    case ownedBy="ownedBy" // reciprocity of isOwnedBy

    case ownedCollectively="ownedCollectively" // shared ownerships
    case ownedCollectivelyBy="ownedCollectivelyBy"// reciprocity of ownedCollectively

    case fusional="fusional" // both object owns the other if one is deleted the other is also deleted (exclusivity + both are set to fusional)

}
