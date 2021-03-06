//
//  MetadataDetails.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 22/09/2016.
//
//

import Cocoa
import BartlebyKit

public let REFRESH_METADATA_INFOS_NOTIFICATION_NAME="REFRESH_METADATA_INFOS_NOTIFICATION_NAME"

class MetadataDetails: NSViewController , Editor, Identifiable,NSTabViewDelegate,DocumentDependent{


    @IBOutlet weak var infosItem: NSTabViewItem!
    @IBOutlet weak var userItem: NSTabViewItem!
    @IBOutlet weak var triggerAnalysisItem: NSTabViewItem!
    @IBOutlet weak var operationQuarantineItem: NSTabViewItem!


    var reportMode:Bool=false


    typealias EditorOf=DocumentMetadata

    var UID:String=Bartleby.createUID()

    override var nibName : NSNib.Name { return NSNib.Name("MetadataDetails") }

    @IBOutlet weak var tabView: NSTabView!{
        didSet{
            tabView.delegate=self
        }
    }


    // MARK: - DocumentDependent

    internal var documentProvider: DocumentProvider?



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
        if reportMode==true, let t=triggerAnalysisItem{
            self.tabView.removeTabViewItem(t)
        }

    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: REFRESH_METADATA_INFOS_NOTIFICATION_NAME), object: nil)
    }


    @objc fileprivate dynamic var _metadata:DocumentMetadata?

    override var representedObject: Any?{
        willSet{
        }
        didSet{
            self._metadata=representedObject as? EditorOf
        }
    }


    // MARK: NSTabViewDelegate

    public func tabView(_ tabView: NSTabView, willSelect tabViewItem: NSTabViewItem?){
        if let tabViewItem = tabViewItem{
            if let documentReference=self.documentProvider?.getDocument(){
                if let identifier=tabViewItem.identifier as? String{
                    if identifier == "TriggersAnalysis"  {
                        self.triggersDiagnosticTextView.string=documentReference.getTriggerBufferInformations()
                    }
                    if identifier == "OperationsQuarantine" {
                        self.operationsQuarantineTextView.string=documentReference.metadata.jsonOperationsQuarantine
                    }
                }
            }
        }
    }


    @objc public func refreshMetadata(notification:Notification){
        if let documentReference=self.documentProvider?.getDocument(){
            self.triggersDiagnosticTextView.string=documentReference.getTriggerBufferInformations()
            self.operationsQuarantineTextView.string=documentReference.metadata.jsonOperationsQuarantine
        }
    }

}
