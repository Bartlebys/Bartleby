//
//  MetadataDetails.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 22/09/2016.
//
//

import Cocoa

class MetadataDetails: NSViewController , Editor, Identifiable,NSTabViewDelegate{

    typealias EditorOf=RegistryMetadata

    var UID:String=Bartleby.createUID()

    @IBOutlet weak var tabView: NSTabView!{
        didSet{
            tabView.delegate=self
        }
    }
    // No Bindings we "observe" the selected index ( NSTabViewDelegate)
    @IBOutlet var triggersDiagnosticTextView: NSTextView!{
        didSet{
            triggersDiagnosticTextView.textColor=NSColor.textColor
        }
    }

    @IBOutlet var triggersQuarantineTextView: NSTextView!{
        didSet{
            triggersQuarantineTextView.textColor=NSColor.textColor
        }
    }

    @IBOutlet var operationsQuarantineTextView: NSTextView!{
        didSet{
            operationsQuarantineTextView.textColor=NSColor.textColor
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


    // MARK: NSTabViewDelegate

    public func tabView(_ tabView: NSTabView, willSelect tabViewItem: NSTabViewItem?){
        if let tabViewItem = tabViewItem{
            if let identifier=tabViewItem.identifier as? String{
                if identifier == "TriggersAnalysis"  {
                    if let registry=self._metadata?.document{
                        self.triggersDiagnosticTextView.string=registry.getTriggerBufferInformations()
                    }
                }
            }
        }
        
    }
    
}
