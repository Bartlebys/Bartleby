//
//  InspectorViewController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 15/07/2016.
//
//

import Cocoa

@objc class InspectorViewController: NSViewController,RegistryDependent{


    @IBOutlet weak var listOutlineView: NSOutlineView!

    @IBOutlet weak var topBox: NSBox!

    @IBOutlet weak var bottomBox: NSBox!

    // Provisionned View controllers

    @IBOutlet var sourceEditor: SourceEditor!

    @IBOutlet var operationViewController: OperationViewController!

    @IBOutlet var changesViewController: ChangesViewController!

    @IBOutlet var contextualMenu: NSMenu!

    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        return true
        //return super.validateMenuItem(menuItem)
    }




    // The currently associated View Controller
    fileprivate var _topViewController:NSViewController?

    fileprivate var _bottomViewController:NSViewController?

    //MARK:- Menu Actions

    @IBAction func resetAllSupervisionCounter(_ sender: AnyObject) {
        if let registry=self.registryDelegate?.getRegistry(){
            registry.registryMetadata.changedKeys.removeAll()
            registry.registryMetadata.currentUser?.changedKeys.removeAll()
            registry.iterateOnCollections({ (collection) in
                if let o = collection as? JObject{
                    o.changedKeys.removeAll()
                }
            })
            registry.superIterate({ (element) in
                if let o = element as? JObject{
                    o.changedKeys.removeAll()
                }
            })
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: RegistryInspector.CHANGES_HAS_BEEN_RESET_NOTIFICATION), object: nil)

    }

    @IBAction func commitChanges(_ sender: AnyObject) {
        if let registry=self.registryDelegate?.getRegistry(){
            do {
                try registry.commitPendingChanges()
            } catch {
            }
        }
    }

    @IBAction func openWebStack(_ sender: AnyObject) {
        if let document=self.registryDelegate?.getRegistry() {
            let currentUser=document.registryMetadata.currentUser!
            let cryptoPassword:String = (try? Bartleby.cryptoDelegate.encryptString(currentUser.password)) ?? currentUser.password
            let url:URL=URL(string: document.baseURL.absoluteString.replacingOccurrences(of: "/api/v1", with: "")+"/signIn?spaceUID=\(document.spaceUID)&userUID=\(document.registryMetadata.currentUser!.UID)&password=\(cryptoPassword)")!
            NSWorkspace.shared().open(url)
        }
    }

    @IBAction func saveRegistry(_ sender: AnyObject) {
        if let registry=self.registryDelegate?.getRegistry(){
            registry.save(sender)
        }
    }


    @IBAction func deleteOperations(_ sender: AnyObject) {
        if let registry=self.registryDelegate?.getRegistry(){
            for operation in registry.pushOperations.reversed(){
                registry.pushOperations.removeObject(operation, commit: false)
            }
        }
    }


    //MARK:-  Collections

    fileprivate var _collectionListDelegate:CollectionListDelegate?

    internal var registryDelegate: RegistryDelegate?{
        didSet{
            if let registry=self.registryDelegate?.getRegistry(){
                self._collectionListDelegate=CollectionListDelegate(registry:registry,outlineView:self.listOutlineView,onSelection: { [unowned self](selected) in
                    self.updateRepresentedObject(selected)
                })

                self._topViewController=self.sourceEditor
                self._bottomViewController=self.changesViewController

                self.topBox.contentView=self._topViewController!.view
                self.bottomBox.contentView=self._bottomViewController!.view

                self.listOutlineView.delegate = self._collectionListDelegate
                self.listOutlineView.dataSource = self._collectionListDelegate
                self._collectionListDelegate?.reloadData()

            }
        }
    }

    //MARK: initialization

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }


    override func viewDidAppear() {
        super.viewDidAppear()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: RegistryInspector.CHANGES_HAS_BEEN_RESET_NOTIFICATION), object: nil, queue: nil) { (notification) in
            self._collectionListDelegate?.reloadData()
        }
    }

    override func viewWillDisappear() {
        NotificationCenter.default.removeObserver(self)
    }

    /**
     Updates and adapts the children viewControllers to the Represented Object

     - parameter selected: the outline selected Object
     */
    func updateRepresentedObject(_ selected:Any?) -> () {

        if selected==nil {
            print("NIL")
        }
        if let object=selected as? JObject{
            // Did the type of represented object changed.
            if object.runTimeTypeName() != (self._bottomViewController?.representedObject as? Collectible)?.runTimeTypeName(){

                switch object {
                case _  where object is PushOperation :
                    //self._bottomViewController=self.changesViewController
                    self._bottomViewController=self.operationViewController
                    break
                default:
                    self._bottomViewController=self.changesViewController
                }

                if self.topBox.contentView != self._topViewController!.view{
                    self.topBox.contentView=self._topViewController!.view
                }

                if self.bottomBox.contentView != self._bottomViewController!.view{
                    self.bottomBox.contentView=self._bottomViewController!.view
                }
            }
            
            self._topViewController?.representedObject=selected
            self._bottomViewController?.representedObject=selected
        }


    }

}

// MARK: - CollectionListDelegate

class CollectionListDelegate:NSObject,NSOutlineViewDelegate,NSOutlineViewDataSource,Identifiable{

    fileprivate var _registry:BartlebyDocument

    fileprivate weak var _outlineView:NSOutlineView!

    fileprivate var _collectionNames=[String]()

    fileprivate var _selectionHandler:((_ selected:Collectible)->())

    var UID: String = Bartleby.createUID()

    required init(registry:BartlebyDocument,outlineView:NSOutlineView,onSelection:@escaping ((_ selected:Collectible)->())) {
        self._registry=registry
        self._outlineView=outlineView
        self._collectionNames=registry.getCollectionsNames()
        self._selectionHandler=onSelection
        super.init()
        self._registry.registryMetadata.addChangesSuperviser(self, closure: { (key, oldValue, newValue) in
            self.reloadData()
        })
        self._registry.iterateOnCollections { (collection) in
            collection.addChangesSuperviser(self, closure: { (key, oldValue, newValue) in
                self.reloadData()
            })
        }
    }


    func reloadData(){
        var selectedIndexes=self._outlineView.selectedRowIndexes
        self._outlineView.reloadData()
        if selectedIndexes.count==0 && self._outlineView.numberOfRows > 0 {
            selectedIndexes=IndexSet(integer: 0)
        }
        self._outlineView.selectRowIndexes(selectedIndexes, byExtendingSelection: false)
    }

    //MARK: - NSOutlineViewDataSource

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {

        if item==nil{
            return self._collectionNames.count + 1
        }


        if let object=item as? JObject{
            if let collection  = object as?  BartlebyCollection {
                return collection.count
            }
        }

        return 0

    }


    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item==nil{
            // Root of the tree
            // Return the Metadata
            if index==0{
                return self._registry.registryMetadata
            }else{
                // Return the collections
                let collectionName=self._collectionNames[index-1]
                return self._registry.collectionByName(collectionName)
            }
        }

        if let object=item as? JObject{
            if let collection  = object as? BartlebyCollection {
                if let element=collection.item(at: index){
                    return element
                }
                return "NOTHING"
            }
        }
        return "ERROR"
    }


    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let object=item as? JObject{
            return object is BartlebyCollection
        }
        return false
    }

    /*
     NOTE: Returning nil indicates that the item's state will not be persisted.
     */
    func outlineView(_ outlineView: NSOutlineView, persistentObjectForItem item: Any?) -> Any? {
        if let object=item as? JObject{
            return JSerializer.serialize(object)
        }
        return nil
    }

    /*
     NOTE: Returning nil indicates the item no longer exists, and won't be re-expanded.
     */
    func outlineView(_ outlineView: NSOutlineView, itemForPersistentObject object: Any) -> Any? {
        if let deserializable = object as? Data {
            do {
                let o = try JSerializer.deserialize(deserializable)
                return o
            } catch {
                bprint("Outline deserialization issue on \(object) \(error)", file:#file, function:#function, line:#line)
            }
        }
        return nil
    }

    //MARK: - NSOutlineViewDelegate

    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let object = item as? JObject{
            if let casted=object as? BartlebyCollection {
                let view = outlineView.make(withIdentifier: "CollectionCell", owner: self) as! NSTableCellView
                if let textField = view.textField {
                    textField.stringValue = casted.d_collectionName
                }
                self.configureInlineButton(view, object: casted)
                return view
            }else if let casted=object as? RegistryMetadata {
                let view = outlineView.make(withIdentifier: "ObjectCell", owner: self) as! NSTableCellView
                if let textField = view.textField {
                    textField.stringValue = "Registry Metadata"
                }
                self.configureInlineButton(view, object: casted)
                return view
            }else if  let casted=object as? User {
                let view = outlineView.make(withIdentifier: "UserCell", owner: self) as! NSTableCellView
                if let textField = view.textField {
                    if casted.creatorUID==casted.UID{
                        textField.stringValue = "Current User"
                    }else{
                        textField.stringValue = casted.UID
                    }
                }
                self.configureInlineButton(view, object: casted)
                return view
            }else{
                let casted=object
                let view = outlineView.make(withIdentifier: "ObjectCell", owner: self) as! NSTableCellView
                if let textField = view.textField {
                    textField.stringValue = casted.UID
                }
                self.configureInlineButton(view, object: casted)
                return view
            }
        }else{
            let view = outlineView.make(withIdentifier: "ObjectCell", owner: self) as! NSTableCellView
            if let textField = view.textField {
                textField.stringValue = "ERROR"
            }
            return view
        }
    }


    fileprivate func configureInlineButton(_ view:NSView,object:Any){
        if let inlineButton = view.viewWithTag(2) as? NSButton{
            if let casted=object as? JObject{
                if casted.changedKeys.count > 0 {
                    inlineButton.isHidden=false
                    inlineButton.title="\(casted.changedKeys.count)"
                }else{
                    inlineButton.isHidden=true
                }
            }else{
                inlineButton.isHidden=true
            }
        }
    }


    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        if let object=item as? JObject {
            if object is BartlebyCollection {
                return 20
            }
            if object is RegistryMetadata {
                return 20
            }
        }
        return 80
    }
    
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        return true
    }
    
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        let selected=self._outlineView.selectedRow
        if let item=self._outlineView.item(atRow:selected){
            if let object=item as? JObject{
                self._selectionHandler(object)
            }else{
                print("*\(item)*")
            }

        }else{
            print("*\(selected)*")
        }
    }
    
}
