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

protocol RegistryDependent {
    var registryDelegate:RegistryDelegate? { get set }
}

public protocol Editor:Identifiable{
    associatedtype EditorOf:Collectible
}


public class RegistryInspector: NSWindowController,RegistryDelegate {

    static let CHANGES_HAS_BEEN_RESET_NOTIFICATION="CHANGES_HAS_BEEN_RESET_NOTIFICATION"

    // In the tool bar
    @IBOutlet weak var scopeSegmentedControl: NSSegmentedControl!

    @IBOutlet weak var globalTabView: NSTabView!

    // View Controllers

    @IBOutlet var inspectorViewController: InspectorViewController!


    @IBOutlet weak var logsViewController:LogsViewController!

    @IBOutlet var webStackViewController: WebStack!

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

        let logsTabViewItem=NSTabViewItem(viewController:self.logsViewController)
        self.globalTabView.addTabViewItem(logsTabViewItem)
        self.logsViewController.registryDelegate=self

        let webTabViewItem=NSTabViewItem(viewController:self.webStackViewController)
        self.globalTabView.addTabViewItem(webTabViewItem)
        self.webStackViewController.registryDelegate=self

    }



    @IBAction func resetChanges(sender: AnyObject) {

        self.registry?.registryMetadata.changedKeys.removeAll()
        self.registry?.registryMetadata.currentUser?.changedKeys.removeAll()

        self.registry?.iterateOnCollections({ (collection) in
            if let o = collection as? JObject{
                o.changedKeys.removeAll()
            }
        })

        self.registry?.superIterate({ (element) in
            if let o = element as? JObject{
                o.changedKeys.removeAll()
            }
        })

        NSNotificationCenter.defaultCenter().postNotificationName(RegistryInspector.CHANGES_HAS_BEEN_RESET_NOTIFICATION, object: nil)
    }


    @IBAction func openWebStack(sender:AnyObject)  {
        if let document=self.registry {
            let url:NSURL=NSURL(string: document.baseURL.absoluteString.stringByReplacingOccurrencesOfString("/api/v1", withString: "")+"/signIn?spaceUID=\(document.spaceUID)&userUID=\(document.registryMetadata.currentUser!.UID)&password=\(document.registryMetadata.currentUser!.password)")!
            NSWorkspace.sharedWorkspace().openURL(url)
        }
    }

    @IBAction func commitPendingChanges(sender: AnyObject) {        if let document=self.registry {
            do {
                try document.commitPendingChanges()
            } catch {
            }
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