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


public class RegistryInspector: NSWindowController,RegistryDelegate,RegistryDependent {

    static let CHANGES_HAS_BEEN_RESET_NOTIFICATION="CHANGES_HAS_BEEN_RESET_NOTIFICATION"

    // In the tool bar
    @IBOutlet weak var scopeSegmentedControl: NSSegmentedControl!

    @IBOutlet weak var globalTabView: NSTabView!

    // View Controllers

    @IBOutlet var inspectorViewController: InspectorViewController!


    @IBOutlet weak var logsViewController:LogsViewController!

    @IBOutlet var webStackViewController: WebStack!

    @IBOutlet weak var activityViewController:ActivityProgressViewController!


    // We bind this index on the scopeSegmentedControl
    public dynamic var selectedIndex:Int = -1{
        didSet{
            if oldValue != selectedIndex || (oldValue == -1  && selectedIndex >= 0 ){
                self.globalTabView.selectTabViewItemAtIndex(selectedIndex)
            }
        }
    }

    // The selected Registry
    private var registry:BartlebyDocument?


    public func getRegistry() -> BartlebyDocument?{
        return self.registry
    }



    //MARK : Window

    override public func windowDidLoad() {
        super.windowDidLoad()
    }

    override public var windowNibName: String?{
        return "RegistryInspector"
    }


    // MARK: RegistryDependent

    public var registryDelegate: RegistryDelegate?{
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

                let activityViewItem=NSTabViewItem(viewController:self.activityViewController)
                self.globalTabView.addTabViewItem(activityViewItem)
                self.activityViewController.registryDelegate=self

            }
        }
    }



    @IBAction func openWebStack(sender:AnyObject)  {
        if let document=self.registry {
            let url:NSURL=NSURL(string: document.baseURL.absoluteString.stringByReplacingOccurrencesOfString("/api/v1", withString: "")+"/signIn?spaceUID=\(document.spaceUID)&userUID=\(document.registryMetadata.currentUser!.UID)&password=\(document.registryMetadata.currentUser!.password)")!
            NSWorkspace.sharedWorkspace().openURL(url)
        }
    }



    @IBAction func pushOperations(sender: AnyObject) {
            if let document=self.registry {
                let synchronizationHandlers=Handlers(completionHandler: { (completion) in
                    bprint("End of synchronizePendingOperations (\(completion)", file:#file, function:#function, line:#line,category: Default.BPRINT_CATEGORY,decorative: false)

                    }, progressionHandler: { (progression) in
                        bprint("\(progression)", file:#file, function:#function, line:#line,category: Default.BPRINT_CATEGORY,decorative: false)
                })

                document.synchronizePendingOperations(synchronizationHandlers)
            }
    }
}