//
//  InspectorViewController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 15/07/2016.
//
//

import Cocoa

class InspectorViewController: NSViewController,RegistryViewController{


    @IBOutlet weak var listOutlineView: NSOutlineView!

    @IBOutlet weak var topBox: NSBox!

    @IBOutlet weak var bottomBox: NSBox!

    // Provisionned View controllers

    @IBOutlet var sourceEditor: SourceEditor!

    @IBOutlet var operationEditor: OperationsViewController!

    @IBOutlet var changesViewController: ChangesViewController!

    
    // The currently associated View Controller
    private var _topViewController:NSViewController?

    private var _bottomViewController:NSViewController?


    //MARK:  Collections

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


    func updateRepresentedObject(selected:Collectible) -> () {
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
        do{
            try self._registry.iterateOnCollections { (collection) in
                collection.addChangesObserver(self, closure: { (key, oldValue, newValue) in
                    self.reloadData()
                })
            }
        } catch{
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
        return self._collectionNames.count + 2
    }

    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if let collection  = item as? CollectibleCollection {
            return collection.itemAtIndex(index) as! AnyObject
        }else{
            if index==0{
                return self._registry.registryMetadata.currentUser!
            }

            if index==1{
                return self._registry.registryMetadata
            }
            let collectionName=self._collectionNames[index - 2]
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

            if let inlineButton = view.viewWithTag(2) as? NSButton{
                inlineButton.title="\(element.count)"
            }
            return view
        case let element  where element is RegistryMetadata :
             //let casted=(element as! RegistryMetadata)
            let view = outlineView.makeViewWithIdentifier("ObjectCell", owner: self) as! NSTableCellView
            if let textField = view.textField {
                textField.stringValue = "Registry Metadata"
          }
            return view
        case let element  where element is User :
            let casted=(element as! User)
            let view = outlineView.makeViewWithIdentifier("UserCell", owner: self) as! NSTableCellView
            if let textField = view.textField {
                if casted.creatorUID==casted.UID{
                    textField.stringValue = "Current User"
                }else{
                    textField.stringValue = casted.email ?? casted.UID
                }
            }
            return view
        case let element  where element is Collectible :
            let casted=(element as! Collectible)
            let view = outlineView.makeViewWithIdentifier("ObjectCell", owner: self) as! NSTableCellView
            if let textField = view.textField {
                textField.stringValue =  Pluralization.singularize(casted.d_collectionName)+" <"+(casted.summary ?? casted.UID)+">"
            }
            return view

        default:
            return  NSView()
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
            self._selectionHandler(selected: item)
        }
    }

}