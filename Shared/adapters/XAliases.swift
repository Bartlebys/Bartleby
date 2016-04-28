//
//  UIX.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 18/12/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.


// Aliases to simplify cross implementation
// Those type Aliases are used to share signatures not implementation


// TODO: @bpds X alias for watchOS & TvOS

#if os(OSX)
    import AppKit
    public typealias BXView=NSView
    public typealias BXViewController=NSViewController
    public typealias BXTableView=NSTableView
    public typealias BXDocument=NSDocument
    public typealias BXImage=NSImage
#elseif os(iOS)
    import UIKit
    public typealias BXView=UIView
    public typealias BXViewController=UIViewController
    public typealias BXTableView=UITableView
    public typealias BXDocument=UIDocument
    public typealias BXImage=UIImage
#elseif os(watchOS)
#elseif os(tvOS)
#endif

extension BXView{
}
extension BXViewController{
}
extension BXTableView{
}
extension BXDocument{
}
extension BXImage{
}