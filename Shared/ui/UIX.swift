//
//  UIX.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 18/12/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.


// Aliases to simplify cross implementation
// Those type Aliases are used to share signatures not implementation

// MARK: UIX

#if os(OSX)
    
    import AppKit
    
    public typealias BXView=NSView
    public typealias BXViewController=NSViewController
    public typealias BXTableView=NSTableView
    
    public typealias BXDocument=NSDocument
    
#elseif os(iOS)
    
    import UIKit
    
    public typealias BXView=UIView
    public typealias BXViewController=UIViewController
    public typealias BXTableView=UITableView
    
    public typealias BXDocument=UIDocument
    
#elseif os(watchOS)
    // TODO: watchOS
#elseif os(tvOS)
    // TODO: tvOS

#endif

