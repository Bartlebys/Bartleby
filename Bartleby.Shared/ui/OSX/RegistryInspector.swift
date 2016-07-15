//
//  RegistryInspector.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 14/07/2016.
//
//

import Cocoa



protocol RegistryDelegate {
    func getRegistry() -> BartlebyDocument?
}


protocol RegistryViewController {
    var registryDelegate:RegistryDelegate? { get set }
}

public class RegistryInspector: NSWindowController,RegistryDelegate {

    // In the tool bar
    @IBOutlet weak var scopeSegmentedControl: NSSegmentedControl!

    @IBOutlet weak var globalTabView: NSTabView!

    // View Controllers

    @IBOutlet var inspectorViewController: InspectorViewController!

    @IBOutlet var metadataViewController: MetadataViewController!

    @IBOutlet var userViewController: UserViewController!

    @IBOutlet var operationsViewController: OperationsViewController!

    @IBOutlet weak var logsViewController:LogsViewController!

    @IBOutlet var triggersViewController: TriggersViewController!


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


    func getRegistry() -> BartlebyDocument?{
        return self.registry
    }

    //MARK : Window

    override public func windowDidLoad() {
        super.windowDidLoad()
        if let registry=self.registry{
            self.display(registry)
        }
    }

    override public var windowNibName: String?{
        return "RegistryInspector"
    }

    //MARK : NSTabView Tabless

    public func display(registry:BartlebyDocument){

        self.registry=registry
        self.window?.title=registry.fileURL?.lastPathComponent ?? ""

        let inspectorTabViewItem=NSTabViewItem(viewController:self.inspectorViewController)
        self.globalTabView.addTabViewItem(inspectorTabViewItem)
        self.inspectorViewController.registryDelegate=self


        let metadataTabViewItem=NSTabViewItem(viewController:self.metadataViewController)
        self.globalTabView.addTabViewItem(metadataTabViewItem)

        let userTabViewItem=NSTabViewItem(viewController:self.userViewController)
        self.globalTabView.addTabViewItem(userTabViewItem)

        let operationsTabViewItem=NSTabViewItem(viewController:self.operationsViewController)
        self.globalTabView.addTabViewItem(operationsTabViewItem)

        let logsTabViewItem=NSTabViewItem(viewController:self.logsViewController)
        self.globalTabView.addTabViewItem(logsTabViewItem)

        let triggersTabViewItem=NSTabViewItem(viewController:self.triggersViewController)
        self.globalTabView.addTabViewItem(triggersTabViewItem)

    }

    @IBAction func openWebStack(sender:AnyObject)  {
        if let document=self.registry {
            let url:NSURL=NSURL(string: document.baseURL.absoluteString.stringByReplacingOccurrencesOfString("/api/v1", withString: "")+"/signIn?spaceUID=\(document.spaceUID)&userUID=\(document.registryMetadata.currentUser!.UID)&password=\(document.registryMetadata.currentUser!.password)")!
            NSWorkspace.sharedWorkspace().openURL(url)
        }
    }

}