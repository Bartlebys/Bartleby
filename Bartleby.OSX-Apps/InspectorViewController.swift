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

    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        return true
        //return super.validateMenuItem(menuItem)
    }




    // The currently associated View Controller
    private var _topViewController:NSViewController?

    private var _bottomViewController:NSViewController?

    //MARK:- Menu Actions

    @IBAction func resetAllSupervisionCounter(sender: AnyObject) {
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
        NSNotificationCenter.defaultCenter().postNotificationName(RegistryInspector.CHANGES_HAS_BEEN_RESET_NOTIFICATION, object: nil)

    }

    @IBAction func commitChanges(sender: AnyObject) {
        if let registry=self.registryDelegate?.getRegistry(){
            do {
                try registry.commitPendingChanges()
            } catch {
            }
        }
    }

    @IBAction func saveRegistry(sender: AnyObject) {
        if let registry=self.registryDelegate?.getRegistry(){
            registry.saveDocument(sender)
        }
    }


    @IBAction func deleteAllPendingTasks(sender: AnyObject) {
        if let registry=self.registryDelegate?.getRegistry(){
            for task in registry.tasks.reverse(){
                registry.tasks.removeObject(task, commit: false)
            }

            for group in registry.tasksGroups.reverse(){
                registry.tasksGroups.removeObject(group, commit: false)
            }
        }
    }

    @IBAction func deleteOperations(sender: AnyObject) {
        if let registry=self.registryDelegate?.getRegistry(){
            for operation in registry.operations.reverse(){
                registry.operations.removeObject(operation, commit: false)
            }
        }
    }


    @IBAction func restartTasksGroups(sender: AnyObject) {
        if let registry=self.registryDelegate?.getRegistry(){
            for group in registry.tasksGroups{
                if let _=try? group.start(){
                    // Explicit silent catch
                }
            }
        }
    }

    @IBAction func pauseTasksGroups(sender: AnyObject) {
        if let registry=self.registryDelegate?.getRegistry(){
            for group in registry.tasksGroups{
                group.pause()
            }
        }
    }

    //MARK:-  Collections

    private var _collectionListDelegate:CollectionListDelegate?

    internal var registryDelegate: RegistryDelegate?{
        didSet{
            if let registry=self.registryDelegate?.getRegistry(){
                self._collectionListDelegate=CollectionListDelegate(registry:registry,outlineView:self.listOutlineView,onSelection: { (selected) in
                    self.updateRepresentedObject(selected)
                })

                self._topViewController=self.sourceEditor
                self._bottomViewController=self.changesViewController

                self.topBox.contentView=self._topViewController!.view
                self.bottomBox.contentView=self._bottomViewController!.view

                self.listOutlineView.setDelegate(self._collectionListDelegate)
                self.listOutlineView.setDataSource(self._collectionListDelegate)
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
        NSNotificationCenter.defaultCenter().addObserverForName(RegistryInspector.CHANGES_HAS_BEEN_RESET_NOTIFICATION, object: nil, queue: nil) { (notification) in
            self._collectionListDelegate?.reloadData()
        }
    }

    override func viewWillDisappear() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    /**
     Updates and adapts the children viewControllers to the Represented Object

     - parameter selected: the outline selected Object
     */
    func updateRepresentedObject(selected:Collectible) -> () {

        // Did the type of represented object changed.
        if selected.runTimeTypeName() != (self._bottomViewController?.representedObject as? Collectible)?.runTimeTypeName(){

            switch selected {

            case let selected  where selected is Operation :
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

        self._topViewController?.representedObject=selected as? AnyObject
        self._bottomViewController?.representedObject=selected as? AnyObject

    }

}

// MARK: - CollectionListDelegate

class CollectionListDelegate:NSObject,NSOutlineViewDelegate,NSOutlineViewDataSource,Identifiable{

    private var _registry:BartlebyDocument

    private weak var _outlineView:NSOutlineView!

    private var _collectionNames=[String]()

    private var _selectionHandler:((selected:Collectible)->())

    var UID: String = Bartleby.createUID()

    required init(registry:BartlebyDocument,outlineView:NSOutlineView,onSelection:((selected:Collectible)->())) {
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
            selectedIndexes=NSIndexSet(index: 0)
        }
        self._outlineView.selectRowIndexes(selectedIndexes, byExtendingSelection: false)


    }


    //MARK: NSOutlineViewDataSource


    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if let collection  = item as? CollectibleCollection {
            return collection.count
        }
        return self._collectionNames.count + 1
    }

    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if let collection  = item as? CollectibleCollection {
            return collection.itemAtIndex(index) as! AnyObject
        }else{
            if index==0{
                return self._registry.registryMetadata
            }
            let collectionName=self._collectionNames[index - 1]
            return self._registry.collectionByName(collectionName) as? AnyObject ?? "ERROR"
        }
    }


    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        return (item is CollectibleCollection)
    }

    func outlineView(outlineView: NSOutlineView, persistentObjectForItem item: AnyObject?) -> AnyObject? {
        if let serializable = item as? Serializable {
            return JSerializer.serialize(serializable)
        }
        return nil
    }

    func outlineView(outlineView: NSOutlineView, itemForPersistentObject object: AnyObject) -> AnyObject? {
        if let deserializable = object as? NSData {
            do {
                let o = try JSerializer.deserialize(deserializable)
                return o as? AnyObject
            } catch {
                bprint("Outline deserialization issue on \(object) \(error)", file:#file, function:#function, line:#line)
            }
        }
        return nil
    }

    //MARK: NSOutlineViewDelegate


    func outlineView(outlineView: NSOutlineView, viewForTableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        switch item {
        case let element where element is CollectibleCollection :
            let view = outlineView.makeViewWithIdentifier("CollectionCell", owner: self) as! NSTableCellView
            if let textField = view.textField {
                textField.stringValue = (element as! CollectibleCollection).d_collectionName
            }
            self.configureInlineButton(view, casted: element as! JObject)
            return view
        case let element  where element is RegistryMetadata :
            let casted=(element as! RegistryMetadata)
            let view = outlineView.makeViewWithIdentifier("ObjectCell", owner: self) as! NSTableCellView
            if let textField = view.textField {
                textField.stringValue = "Registry Metadata"
            }
            self.configureInlineButton(view, casted: casted)
            return view
        case let element  where element is User :
            let casted=(element as! User)
            let view = outlineView.makeViewWithIdentifier("UserCell", owner: self) as! NSTableCellView
            if let textField = view.textField {
                if casted.creatorUID==casted.UID{
                    textField.stringValue = "Current User"
                }else{
                    textField.stringValue = casted.UID
                }
            }
            self.configureInlineButton(view, casted: casted)
            return view
        case let element  where element is Collectible :
            let casted=(element as! JObject)
            let view = outlineView.makeViewWithIdentifier("ObjectCell", owner: self) as! NSTableCellView
            if let textField = view.textField {
                textField.stringValue = casted.UID
            }
            self.configureInlineButton(view, casted: casted)
            return view

        default:
            return  NSView()
        }
    }



    private func configureInlineButton(view:NSView,casted:JObject){
        if let inlineButton = view.viewWithTag(2) as? NSButton{
            if casted.changedKeys.count > 0 {
                inlineButton.hidden=false
                inlineButton.title="\(casted.changedKeys.count)"
            }else{
                inlineButton.hidden=true
            }
        }

    }



    func outlineView(outlineView: NSOutlineView, heightOfRowByItem item: AnyObject) -> CGFloat {
        if let _ = item as? CollectibleCollection {
            return 20
        }else{
            return 20
        }
    }
    
    
    func outlineView(outlineView: NSOutlineView, shouldSelectItem item: AnyObject) -> Bool {
        return true
    }
    
    
    func outlineViewSelectionDidChange(notification: NSNotification) {
        if let item=self._outlineView.itemAtRow(_outlineView.selectedRow) as? Collectible{
            dispatch_async(dispatch_get_main_queue()) {
                self._selectionHandler(selected: item)
            }
        }
    }
    
}