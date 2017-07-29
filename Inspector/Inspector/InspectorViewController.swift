//
//  InspectorViewController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 15/07/2016.
//
//

import Cocoa
import BartlebyKit


protocol FilterPredicateDelegate {
    func filterSelectedIndex()->Int
    func filterExpression()->String
}

class InspectorViewController: NSViewController,DocumentDependent,FilterPredicateDelegate{

    override var nibName : String { return "InspectorViewController" }

    @IBOutlet var listOutlineView: NSOutlineView!

    @IBOutlet var topBox: NSBox!

    @IBOutlet var bottomBox: NSBox!

    // Provisionned View controllers

    @IBOutlet var sourceEditor: SourceEditor!

    @IBOutlet var operationViewController: OperationViewController!

    @IBOutlet var changesViewController: ChangesViewController!

    @IBOutlet var metadataViewController: MetadataDetails!

    @IBOutlet var contextualMenu: NSMenu!

    @IBOutlet weak var filterPopUp: NSPopUpButton!

    @IBOutlet weak var filterField: NSSearchField!

    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        return true
    }

    // The currently associated View Controller
    fileprivate var _topViewController:NSViewController?

    fileprivate var _bottomViewController:NSViewController?

    //MARK:- Menu Actions

    @IBAction func resetAllSupervisionCounter(_ sender: AnyObject) {
        if let documentReference=self.documentProvider?.getDocument(){
            documentReference.metadata.currentUser?.changedKeys.removeAll()
            documentReference.iterateOnCollections({ (collection) in
                if let o = collection as? ManagedModel{
                    o.changedKeys.removeAll()
                }
            })
            documentReference.superIterate({ (element) in
                if let o = element as? ManagedModel{
                    o.changedKeys.removeAll()
                }
            })
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: DocumentInspector.CHANGES_HAS_BEEN_RESET_NOTIFICATION), object: nil)

    }

    @IBAction func commitChanges(_ sender: AnyObject) {
        if let documentReference=self.documentProvider?.getDocument(){
            do {
                try documentReference.commitPendingChanges()
            } catch {
            }
        }
    }

    @IBAction func openWebStack(_ sender: AnyObject) {
        if let document=self.documentProvider?.getDocument() {
            if let url=document.metadata.currentUser?.signInURL(for:document){
                NSWorkspace.shared().open(url)
            }
        }
    }

    @IBAction func saveDocument(_ sender: AnyObject) {
        if let documentReference=self.documentProvider?.getDocument(){
            documentReference.save(sender)
        }
    }

    @IBAction func deleteOperations(_ sender: AnyObject) {
        if let documentReference=self.documentProvider?.getDocument(){
            for operation in documentReference.pushOperations.reversed(){
                documentReference.pushOperations.removeObject(operation, commit: false)
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: REFRESH_METADATA_INFOS_NOTIFICATION_NAME), object: nil)
        }
    }

    @IBAction func cleanupOperationQuarantine(_ sender: AnyObject) {
        if let document=self.documentProvider?.getDocument() {
            document.metadata.operationsQuarantine.removeAll()
            NotificationCenter.default.post(name: Notification.Name(rawValue: REFRESH_METADATA_INFOS_NOTIFICATION_NAME), object: nil)
        }
    }



    @IBAction func forceDataIntegration(_ sender: AnyObject) {
        if let document=self.documentProvider?.getDocument(){
            document.forceDataIntegration()
            NotificationCenter.default.post(name: Notification.Name(rawValue: REFRESH_METADATA_INFOS_NOTIFICATION_NAME), object: nil)
        }
    }


    @IBAction func deleteBSFSOrpheans(_ sender: NSMenuItem) {
        if let document=self.documentProvider?.getDocument(){
            document.blocks.reversed().forEach({ (block) in
                if block.ownedBy.count == 0{
                    try? block.erase()
                }
            })
            document.nodes.reversed().forEach({ (node) in
                if node.ownedBy.count == 0{
                    try? node.erase()
                }
            })
            document.boxes.reversed().forEach({ (box) in
                if box.ownedBy.count == 0{
                    try? box.erase()
                }
            })
        }
    }

    @IBAction func deleteSelectedEntity(_ sender: NSMenuItem) {
        if let item = self.listOutlineView.item(atRow: self.listOutlineView.selectedRow) as? ManagedModel{
            try? item.erase()
        }
    }


    //MARK:-  Collections

    fileprivate var _collectionListDelegate:CollectionListDelegate?

    // MARK - DocumentDependent

    internal var documentProvider: DocumentProvider?{
        didSet{
            if let documentReference=self.documentProvider?.getDocument(){
                self._collectionListDelegate=CollectionListDelegate(documentReference:documentReference,filterDelegate:self,outlineView:self.listOutlineView,onSelection: {(selected) in
                    self.updateRepresentedObject(selected)
                })

                self._topViewController=self.sourceEditor
                self._bottomViewController=self.changesViewController

                self.topBox.contentView=self._topViewController!.view
                self.bottomBox.contentView=self._bottomViewController!.view

                self.listOutlineView.delegate = self._collectionListDelegate
                self.listOutlineView.dataSource = self._collectionListDelegate
                self._collectionListDelegate?.reloadData()

                self.metadataViewController.documentProvider=self.documentProvider

            }
        }
    }

    func providerHasADocument() {}

    //MARK: - initialization

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }


    override func viewDidAppear() {
        super.viewDidAppear()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: DocumentInspector.CHANGES_HAS_BEEN_RESET_NOTIFICATION), object: nil, queue: nil) {(notification) in
            self._collectionListDelegate?.reloadData()
        }
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        NotificationCenter.default.removeObserver(self)
    }

    /**
     Updates and adapts the children viewControllers to the Represented Object

     - parameter selected: the outline selected Object
     */
    func updateRepresentedObject(_ selected:Any?) -> () {
        if let document=self.documentProvider?.getDocument(){
            if selected==nil {
                document.log("Represented object is nil", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
            }
        }else{
            glog("Document provider fault", file: #file, function: #function, line: #line, category: Default.LOG_FAULT, decorative: false)
        }
        if let object=selected as? ManagedModel{
            // Did the type of represented object changed.
            if object.runTimeTypeName() != (self._bottomViewController?.representedObject as? Collectible)?.runTimeTypeName(){
                switch object {
                case _  where object is PushOperation :
                    self._topViewController=self.sourceEditor
                    self._bottomViewController=self.operationViewController
                    break
                default:
                    self._topViewController=self.sourceEditor
                    self._bottomViewController=self.changesViewController
                }
            }
        }else{
            // It  a UnManagedModel
            if let _ = selected as? DocumentMetadata{
                self._topViewController=self.sourceEditor
                self._bottomViewController=self.metadataViewController
            }
        }

        if let object = selected as? NSObject{

            if self.topBox.contentView != self._topViewController!.view{
                self.topBox.contentView=self._topViewController!.view
            }

            if self.bottomBox.contentView != self._bottomViewController!.view{
                self.bottomBox.contentView=self._bottomViewController!.view
            }

            if (self._topViewController?.representedObject as? NSObject) != object{
                self._topViewController?.representedObject=object
            }
            if (self._bottomViewController?.representedObject as? NSObject) != object {
                self._bottomViewController?.representedObject=object
            }
        }
    }

    // MARK - Filtering


    @IBAction func firstPartOfPredicateDidChange(_ sender: Any) {
        let idx=self.filterPopUp.indexOfSelectedItem
        if idx==0{
            self.filterField.isEnabled=false
        }else{
            self.filterField.isEnabled=true
        }
        self._collectionListDelegate?.updateFilter()
    }


    @IBAction func filterOperandDidChange(_ sender: Any) {
        self._collectionListDelegate?.updateFilter()
    }



    // MARK - FilterPredicateDelegate

    public func filterSelectedIndex()->Int{
        return self.filterPopUp.indexOfSelectedItem
    }

    public func filterExpression()->String{
        return PString.trim(self.filterField.stringValue)
    }


}

// MARK: - CollectionListDelegate

class CollectionListDelegate:NSObject,NSOutlineViewDelegate,NSOutlineViewDataSource,Identifiable{

    fileprivate var _filterPredicateDelegate:FilterPredicateDelegate

    fileprivate var _documentReference:BartlebyDocument

    fileprivate var _outlineView:NSOutlineView!


    fileprivate var _selectionHandler:((_ selected:Any)->())

    fileprivate var _collections:[BartlebyCollection]=[BartlebyCollection]()

    fileprivate var _filteredCollections:[BartlebyCollection]=[BartlebyCollection]()



    var UID: String = Bartleby.createUID()

    required init(documentReference:BartlebyDocument,filterDelegate:FilterPredicateDelegate,outlineView:NSOutlineView,onSelection:@escaping ((_ selected:Any)->())) {
        self._documentReference=documentReference
        self._outlineView=outlineView
        self._selectionHandler=onSelection
        self._filterPredicateDelegate=filterDelegate
        super.init()
        self._documentReference.iterateOnCollections { (collection) in
            self._collections.append(collection)
            collection.addChangesSuperviser(self, closure: { (key, oldValue, newValue) in
                self.reloadData()
            })
        }
        // No Filter by default
        self._filteredCollections=self._collections
    }


    public func updateFilter(){
        let idx=self._filterPredicateDelegate.filterSelectedIndex()
        let expression=self._filterPredicateDelegate.filterExpression()
        if idx == 0 || expression==""{
            self._filteredCollections=self._collections
        }else{
            self._filteredCollections=[BartlebyCollection]()
            for collection  in self._collections {
                let filteredCollection=collection.filteredCopy({ (instance) -> Bool in
                    if let o=instance as? ManagedModel{
                        if idx==1{
                            // UID contains
                            return o.UID.contains(expression, compareOptions: NSString.CompareOptions.caseInsensitive)
                        }else if idx==2{
                            // ExternalId contains
                            return o.externalID.contains(expression, compareOptions: NSString.CompareOptions.caseInsensitive)
                        }else if idx==3{
                            // Is owned by <UID>
                            return o.ownedBy.contains(expression)
                        }else if idx==4{
                             // Is related to <UID>
                            return o.freeRelations.contains(expression)
                        }
                    }
                    return false
                })
                if filteredCollection.count>0{
                    if let casted=filteredCollection as? BartlebyCollection{
                        self._filteredCollections.append(casted)
                    }
                }
            }
        }
        self.reloadData()
    }

    func reloadData(){
        Bartleby.syncOnMain{
            var selectedIndexes=self._outlineView.selectedRowIndexes
            self._outlineView.reloadData()
            if selectedIndexes.count==0 && self._outlineView.numberOfRows > 0 {
                selectedIndexes=IndexSet(integer: 0)
            }
            self._outlineView.selectRowIndexes(selectedIndexes, byExtendingSelection: false)
        }
    }

    //MARK: - NSOutlineViewDataSource

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item==nil{
            return self._filteredCollections.count + 1
        }

        if let object=item as? ManagedModel{
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
                return self._documentReference.metadata
            }else{
                // Return the collections with a shifted index
                return self._filteredCollections[index-1]
            }
        }

        if let object=item as? ManagedModel{
            if let collection  = object as? BartlebyCollection {
                if let element=collection.item(at: index){
                    return element
                }
                return "<!>\(object.runTimeTypeName())"
            }
        }
        return "ERROR #\(index)"
    }


    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let object=item as? ManagedModel{
            return object is BartlebyCollection
        }
        return false
    }

    /*
     NOTE: Returning nil indicates that the item's state will not be persisted.
     */
    func outlineView(_ outlineView: NSOutlineView, persistentObjectForItem item: Any?) -> Any? {
        if let object=item as? Serializable {
            return self._documentReference.serializer.serialize(object)
        }
        return nil
    }

    /*
     NOTE: Returning nil indicates the item no longer exists, and won't be re-expanded.
     */
    func outlineView(_ outlineView: NSOutlineView, itemForPersistentObject object: Any) -> Any? {
        if let deserializable = object as? Data {
            do {
                let o = try self._documentReference.serializer.deserialize(deserializable, register: false)
                return o
            } catch {
                glog("Outline deserialization issue on \(object) \(error)", file:#file, function:#function, line:#line)
            }
        }
        return nil
    }

    //MARK: - NSOutlineViewDelegate

    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let object = item as? ManagedModel{
            if let casted=object as? BartlebyCollection {
                let view = outlineView.make(withIdentifier: "CollectionCell", owner: self) as! NSTableCellView
                if let textField = view.textField {
                    textField.stringValue = casted.d_collectionName
                }
                self.configureInlineButton(view, object: casted)
                return view
            }else if  let casted=object as? User {
                let view = outlineView.make(withIdentifier: "UserCell", owner: self) as! NSTableCellView
                if let textField = view.textField {
                    if casted.UID==self._documentReference.currentUser.UID{
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
            // Value Object
            if let object = item as? DocumentMetadata{
                let view = outlineView.make(withIdentifier: "ObjectCell", owner: self) as! NSTableCellView
                if let textField = view.textField {
                    textField.stringValue = "Document Metadata"
                }
                self.configureInlineButton(view, object: object)
                return view
            }else{
                let view = outlineView.make(withIdentifier: "ObjectCell", owner: self) as! NSTableCellView
                if let textField = view.textField {
                    if let s=item as? String{
                        textField.stringValue = s
                    }else{
                        textField.stringValue = "Anomaly"
                    }
                }
                return view
            }
        }
    }


    fileprivate func configureInlineButton(_ view:NSView,object:Any){
        if let inlineButton = view.viewWithTag(2) as? NSButton{
            if let casted=object as? Collectible{
                if let casted=object as? BartlebyCollection {
                    inlineButton.isHidden=false
                    inlineButton.title="\(casted.count) | \(casted.changedKeys.count)"
                    return
                }else if object is DocumentMetadata{
                    inlineButton.isHidden=true
                    inlineButton.title=""
                }else{
                    if casted.changedKeys.count > 0 {
                        inlineButton.isHidden=false
                        inlineButton.title="\(casted.changedKeys.count)"
                        return
                    }
                }
            }
            inlineButton.isHidden=true
        }
    }


    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        if let object=item as? ManagedModel {
            if object is BartlebyCollection { return 20 }
            return 20 // Any ManagedModel
        }
        if item is DocumentMetadata { return 20 }
        if item is String{ return 20 }
        return 30 // This is not normal.
    }



    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        return true
    }

    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        Bartleby.syncOnMain{
            let selected=self._outlineView.selectedRow
            if let item=self._outlineView.item(atRow: selected){
                self._selectionHandler(item)
            }
        }
    }

}
