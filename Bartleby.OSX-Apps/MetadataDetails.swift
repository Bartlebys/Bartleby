//
//  MetadataDetails.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 22/09/2016.
//
//

import Cocoa

class MetadataDetails: NSViewController , Editor, Identifiable{

    typealias EditorOf=RegistryMetadata

    var UID:String=Bartleby.createUID()


    @IBOutlet var receivedTriggersTextView: NSTextView!{
        didSet{
            receivedTriggersTextView.textColor=NSColor.white
        }
    }

    @IBOutlet var triggersQuarantineTextView: NSTextView!{
        didSet{
            triggersQuarantineTextView.textColor=NSColor.white
        }
    }

    @IBOutlet var operationsQuarantineTextView: NSTextView!{
        didSet{
            operationsQuarantineTextView.textColor=NSColor.white
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    fileprivate dynamic var _metadata:RegistryMetadata?

    override var representedObject: Any?{
        willSet{
            if let _=self._metadata{
                self._metadata?.removeChangesSuperviser(self)
            }
        }
        didSet{
            self._metadata=representedObject as? EditorOf
        }
    }
    
}
