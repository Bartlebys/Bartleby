//
//  RegistryInspector.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 14/07/2016.
//
//

import Cocoa


public protocol Editor:Identifiable{
    associatedtype EditorOf:Collectible
}


open class RegistryInspector: NSWindowController,RegistryDelegate,RegistryDependent {

    static let CHANGES_HAS_BEEN_RESET_NOTIFICATION="CHANGES_HAS_BEEN_RESET_NOTIFICATION"

    // In the tool bar
    @IBOutlet weak var scopeSegmentedControl: NSSegmentedControl!

    @IBOutlet weak var globalTabView: NSTabView!

    // View Controllers

    @IBOutlet weak var inspectorViewController: InspectorViewController!


    @IBOutlet weak var logsViewController:LogsViewController!

    @IBOutlet weak var webStackViewController: WebStack!


    // We bind this index on the scopeSegmentedControl
    open dynamic var selectedIndex:Int = -1{
        didSet{
            if oldValue != selectedIndex || (oldValue == -1  && selectedIndex >= 0 ){
                self.globalTabView.selectTabViewItem(at: selectedIndex)
            }
        }
    }

    // The selected Registry
    dynamic weak var registry:BartlebyDocument?


    open func getRegistry() -> BartlebyDocument?{
        return self.registry
    }



    //MARK : Window

    override open func windowDidLoad() {
        super.windowDidLoad()
    }

    override open var windowNibName: String?{
        return "RegistryInspector"
    }


    // MARK: RegistryDependent

    open var registryDelegate: RegistryDelegate?{
        didSet{
            if let registry=self.registryDelegate?.getRegistry(){
                self.registry=registry
                self.window?.title=NSLocalizedString("Inspector", tableName:"bartlebys.OSX-Apps", comment: "Inspector window title") + " (" + ( registry.fileURL?.lastPathComponent ?? "" ) + ")"

                let inspectorTabViewItem=NSTabViewItem(viewController:self.inspectorViewController)
                self.globalTabView.addTabViewItem(inspectorTabViewItem)
                self.inspectorViewController.registryDelegate=self

                let logsTabViewItem=NSTabViewItem(viewController:self.logsViewController)
                self.globalTabView.addTabViewItem(logsTabViewItem)
                self.logsViewController.registryDelegate=self

                let webTabViewItem=NSTabViewItem(viewController:self.webStackViewController)
                self.globalTabView.addTabViewItem(webTabViewItem)
                self.webStackViewController.registryDelegate=self

            }
        }
    }



    @IBAction func openWebStack(_ sender:AnyObject)  {
        if let document=self.registry {
            let url:URL=URL(string: document.baseURL.absoluteString!.replacingOccurrences(of: "/api/v1", with: "")+"/signIn?spaceUID=\(document.spaceUID)&userUID=\(document.registryMetadata.currentUser!.UID)&password=\(document.registryMetadata.currentUser!.password)")!
            NSWorkspace.shared().open(url)
        }
    }



    @IBAction func pushOperations(_ sender: AnyObject) {
            if let document=self.registry {
                document.synchronizePendingOperations()
            }
    }
}
