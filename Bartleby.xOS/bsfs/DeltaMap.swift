//
//  DeltaMap.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 12/11/2016.
//
//

import Foundation

struct DeltaMap {

    var created:[NodeBlocks]
    var deleted:[NodeBlocks]
    var updated:[NodeBlocks]
    var copied:[NodeBlocks]
    var moved:[NodeBlocks]

    var createdShadows:[NodeBlocksShadows]
    var deletedShadows:[NodeBlocksShadows]
    var updatedShadows:[NodeBlocksShadows]
    var copiedShadows:[NodeBlocksShadows]
    var movedShadows:[NodeBlocksShadows]

}
