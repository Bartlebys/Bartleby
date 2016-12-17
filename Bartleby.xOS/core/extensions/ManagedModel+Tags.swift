//
//  ManagedObject+Tag.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 17/12/2016.
//
//

import Foundation

public extension ManagedModel{

    // You should use Document.newTag before to use this api.

    func tagWith(_ tag:Tag){
        self.declaresFreeRelationShip(to: tag)
    }

    func unTag(_ tag:Tag){
        self.removeRelation(Relationship.free, to: tag)
    }

    func tags()->[Tag]?{
        return self.relations(Relationship.free)
    }

    func hasTag(_ tag:Tag)->Bool{
        return self._relations.contains { $0.UID == tag.UID }
    }

}
