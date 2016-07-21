//
//  IdentifableCardContext.swift
//  bsync
//
//  Created by Benoit Pereira da silva on 21/07/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

#if !USE_EMBEDDED_MODULES
    import BartlebyKit
#endif

/**
 *  A protocol used to designate minimal contract to be an identifiable card context.
 */
protocol IdentifiableCardContext:Identifiable {
    var name: String {get set}
}
