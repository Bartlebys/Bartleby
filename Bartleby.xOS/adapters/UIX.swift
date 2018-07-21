//
//  UIX.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 18/12/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.


// Base type to simplify cross platform implementation

#if os(OSX)

import AppKit

public typealias XColor = NSColor

public typealias XView = NSView

public typealias XImage = NSImage

open class BXImageView: NSImageView, Identifiable{
    public let UID = Bartleby.createUID()
}

open class BXView: NSView, Identifiable{
    public let UID = Bartleby.createUID()
}

open class BXViewController: NSViewController, Identifiable ,MessageListener{
    public let UID = Bartleby.createUID()
    open func handle<T: StateMessage>(message: T){}
}

open class BXWindowController: NSWindowController, MessageListener {
    public let UID = Bartleby.createUID()
    open func handle<T: StateMessage>(message: T){}

}

open class BXTableView: NSTableView, Identifiable{
    public let UID = Bartleby.createUID()
}


#elseif os(iOS)

import UIKit

public typealias XColor = UIColor

public typealias XView = UIView

public typealias XImage = UIImage

open class BXImageView: UIImageView, Identifiable{
    public let UID = Bartleby.createUID()
}

open class BXView: UIView, Identifiable{
    public let UID = Bartleby.createUID()
}

open class BXViewController: UIViewController, Identifiable, MessageListener{
    public let UID = Bartleby.createUID()
    open func handle<T: StateMessage>(message: T){}
}

open class BXTableView: UITableView, Identifiable{
    public let UID = Bartleby.createUID()
}

#elseif os(watchOS)
#elseif os(tvOS)
#endif
