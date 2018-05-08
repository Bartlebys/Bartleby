//
//  BXDocument.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 08/02/2017.
//
//

#if os(OSX)

    import AppKit

    // BXDocument is the base type for Documents.
    // Registry implements Identifiable
    open class BXDocument:NSDocument{
    }



#elseif os(iOS)
    
    import UIKit

    // BXDocument is the base type of Documents
    // Registry implements Identifiable
    open class BXDocument:UIDocument{
    }
    
    
#elseif os(watchOS)
#elseif os(tvOS)
#endif
