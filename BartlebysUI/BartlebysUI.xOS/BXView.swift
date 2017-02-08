//
//  BXView.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 08/02/2017.
//  Copyright © 2017 Chaosmos SAS. All rights reserved.
//

import Foundation
import BartlebyKit

#if os(OSX)

    import AppKit

    open class BXView:NSView,Identifiable{
        open let UID=Bartleby.createUID()
    }



#elseif os(iOS)
    import UIKit

    open class BXView:UIView,Identifiable{
        public let UID=Bartleby.createUID()
    }

    
#elseif os(watchOS)
#elseif os(tvOS)
#endif
