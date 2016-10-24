//
//  DocumentInspector.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 14/07/2016.
//
//

import Cocoa


public protocol Editor:Identifiable{
    associatedtype EditorOf:Collectible
}


open class DocumentInspector: NSWindowController,DocumentProvider,DocumentDependent {

    override open var windowNibName: String?{ return "DocumentInspector" }

    static let CHANGES_HAS_BEEN_RESET_NOTIFICATION="CHANGES_HAS_BEEN_RESET_NOTIFICATION"

    // In the tool bar
    @IBOutlet weak var scopeSegmentedControl: NSSegmentedControl!

    @IBOutlet weak var globalTabView: NSTabView!

    // View Controllers

    @IBOutlet weak var inspectorViewController: InspectorViewController!

    @IBOutlet weak var logsViewController:LogsViewController!

    @IBOutlet weak var webStackViewController: WebStack!

    @IBOutlet weak var qosViewController: QosViewController!

    // We bind this index on the scopeSegmentedControl
    open dynamic var selectedIndex:Int = -1{
        didSet{
            if oldValue != selectedIndex || (oldValue == -1  && selectedIndex >= 0 ){
                self.globalTabView.selectTabViewItem(at: selectedIndex)
            }
        }
    }

    // The selected document
    dynamic weak var castedDocument:BartlebyDocument?{
        didSet{
            self.castedDocument?.metadata.changesAreInspectables = true
        }
    }


    open func getDocument() -> BartlebyDocument?{
        return self.castedDocument
    }



    //MARK : Window

    override open func windowDidLoad() {
        super.windowDidLoad()
    }

    // MARK: DocumentProvider

    open var documentProvider: DocumentProvider?{
        didSet{
            if let documentReference=self.documentProvider?.getDocument(){
                self.castedDocument=documentReference
                self.window?.title=NSLocalizedString("Inspector", tableName:"bartlebys.OSX-Apps", comment: "Inspector window title") + " (" + ( documentReference.fileURL?.lastPathComponent ?? "" ) + ")"

                let inspectorTabViewItem=NSTabViewItem(viewController:self.inspectorViewController)
                self.globalTabView.addTabViewItem(inspectorTabViewItem)
                self.inspectorViewController.documentProvider=self

                let logsTabViewItem=NSTabViewItem(viewController:self.logsViewController)
                self.globalTabView.addTabViewItem(logsTabViewItem)
                self.logsViewController.documentProvider=self

                let webTabViewItem=NSTabViewItem(viewController:self.webStackViewController)
                self.globalTabView.addTabViewItem(webTabViewItem)
                self.webStackViewController.documentProvider=self

                let qosTabViewItem=NSTabViewItem(viewController:self.qosViewController)
                self.globalTabView.addTabViewItem(qosTabViewItem)
                self.qosViewController.documentProvider=self

            }
        }
    }



    @IBAction func openWebStack(_ sender:AnyObject)  {
        if let document=self.castedDocument {
            if let url=document.metadata.currentUser?.signInURL(for:document){
                NSWorkspace.shared().open(url)
            }
        }
    }



    @IBAction func pushOperations(_ sender: AnyObject) {
        if let document=self.castedDocument {
            document.synchronizePendingOperations()
        }
    }


}
