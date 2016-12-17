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

    // In case of deletion of one of the related terms the other is preserved 
    // (there is not necessarly reciprocity of the relation)
    // E.G: tags can freely associated
    // N -> N
    case free="free"

    // MARK: - With reciprocity

    // In case of deletion of the owner the owned is automatically deleted. 
    //(the contract is exclusive)
    // If the owner is deleted its properties are deleted.
    // 1 -> 1 X N
    case owns="owns"
    case ownedBy="ownedBy" // reciprocity of owns

    // N -> 1
    case coOwns="coOwns" // shared ownerships
    case coOwnedBy="coOwnedBy"// reciprocity of ownedCollectively

    // 1 <-> 1
    case fusional="fusional" // both object owns the other if one is deleted the other is also deleted (exclusivity + both are set to fusional)

}
