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

    public class BXView:NSView,Identifiable{
        public let UID=Bartleby.createUID()
    }

    public class BXViewController:NSViewController,Identifiable{
        public let UID=Bartleby.createUID()
    }

    public class BXTableView:NSTableView,Identifiable{
        public let UID=Bartleby.createUID()
    }

    // BXDocument is the base type of Registry
    // Registry implements Identifiable
    public class BXDocument:NSDocument{
    }

    public class BXImage:NSImage,Identifiable{
        public let UID=Bartleby.createUID()
    }


#elseif os(iOS)
    import UIKit

    public class BXView:UIView,Identifiable{
        public let UID=Bartleby.createUID()
    }

    public class BXViewController:UIViewController,Identifiable{
        public let UID=Bartleby.createUID()
    }

    public class BXTableView:UITableView,Identifiable{
        public let UID=Bartleby.createUID()
    }

    // BXDocument is the base type of Registry
    // Registry implements Identifiable
    public class BXDocument:UIDocument{
    }

    public class BXImage:UIImage,Identifiable{
        public let UID=Bartleby.createUID()
    }

#elseif os(watchOS)
#elseif os(tvOS)
#endif