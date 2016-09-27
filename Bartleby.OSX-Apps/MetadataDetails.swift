//
//  MetadataDetails.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 22/09/2016.
//
//

import Cocoa


public let REFRESH_METADATA_INFOS_NOTIFICATION_NAME="REFRESH_METADATA_INFOS_NOTIFICATION_NAME"

class MetadataDetails: NSViewController , Editor, Identifiable,NSTabViewDelegate{

    typealias EditorOf=RegistryMetadata

    var UID:String=Bartleby.createUID()

    override var nibName : String { return "MetadataDetails" }

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


    // No Bindings we "observe" the selected index ( NSTabViewDelegate)
    @IBOutlet var operationsQuarantineTextView: NSTextView!{
        didSet{
            operationsQuarantineTextView.textColor=NSColor.textColor
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }


    override func viewDidAppear() {
        super.viewDidAppear()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshMetadata), name: Notification.Name(rawValue: REFRESH_METADATA_INFOS_NOTIFICATION_NAME), object: nil)
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: REFRESH_METADATA_INFOS_NOTIFICATION_NAME), object: nil)
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
            if let registry=self._metadata?.document{
                if let identifier=tabViewItem.identifier as? String{
                    if identifier == "TriggersAnalysis"  {
                        self.triggersDiagnosticTextView.string=registry.getTriggerBufferInformations()
                    }
                    if identifier == "OperationsQuarantine" {
                        self.operationsQuarantineTextView.string=registry.registryMetadata.jsonOperationsQuarantine
                    }
                }
            }
        }
    }


    public func refreshMetadata(notification:Notification){
        if let registry=self._metadata?.document{
            self.triggersDiagnosticTextView.string=registry.getTriggerBufferInformations()
            self.operationsQuarantineTextView.string=registry.registryMetadata.jsonOperationsQuarantine
        }
    }
    
}
