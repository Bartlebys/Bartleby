//
//  Contract.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 07/12/2016.
//
//
import Foundation

// Check BartlebyObject+Relationships for details.

public enum Relationship:String{
    case free="free" // In case of deletion of one of the related terms the other is preserved
    case owned="owned" // In case of deletion of the owner the owned is automatically deleted. (the contract is exclusive)
    case owns="owns" // reciprocity of owned
    case co_owns="co_owns" // shared ownerships
    case co_owned="co_owned"// reciprocity of co_owns
    case fusional="fusional" // both object owns the other if one is deleted the other is also deleted
}
