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

    @IBOutlet weak var detailsOutlineView: NSOutlineView!

    @IBOutlet var textView: NSTextView!
    
    private var _collectionListDelegate:CollectionListDelegate?

    private var _detailDelegate:DetailsDelegate?

    internal var registryDelegate: RegistryDelegate?{
        didSet{
            if let registry=self.registryDelegate?.getRegistry(){
                self._collectionListDelegate=CollectionListDelegate(registry:registry,outlineView:self.listOutlineView,onSelection: { (selected) in
                    if selected is CollectibleCollection{
                        // !!! not efficient
                        let objectMask=JObject()
                        let dictionary=selected.dictionaryRepresentation()
                        objectMask.patchFrom(dictionary)
                        let selectedJSON=selected.toJSONString(true)
                        self.textView.string=selectedJSON
                    }else{
                        let selectedJSON=selected.toJSONString(true)
                        self.textView.string=selectedJSON
                    }

                })
                self.listOutlineView.setDelegate(self._collectionListDelegate)
                self.listOutlineView.setDataSource(self._collectionListDelegate)
                self.listOutlineView.reloadData()
            }
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func outlineViewFor(delegate:NSOutlineViewDelegate)-> NSOutlineView{
        if delegate is CollectionListDelegate{
            return self.listOutlineView
        }
        return self.detailsOutlineView
    }

}



// MARK: - CollectionListDelegate

class CollectionListDelegate:NSObject,NSOutlineViewDelegate,NSOutlineViewDataSource,Identifiable{

    private var _registry:BartlebyDocument

    private weak var _outlineView:NSOutlineView!

    private var _collectionNames=[String]()

    private var _selectionHandler:((selected:Collectible)->())

    public var UID: String = Bartleby.createUID()

    required init(registry:BartlebyDocument,outlineView:NSOutlineView,onSelection:((selected:Collectible)->())) {
        self._registry=registry
        self._outlineView=outlineView
        self._collectionNames=registry.getCollectionsNames()
        self._selectionHandler=onSelection
        super.init()
        do{
            try self._registry.iterateOnCollections { (collection) in
                collection.addChangesObserver(self, closure: { (key, oldValue, newValue) in
                    self._outlineView.reloadData()
                })
            }
        } catch{
        }
    }



    //MARK: NSOutlineViewDataSource


    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if let collection  = item as? CollectibleCollection {
            return collection.count
        }
        return self._collectionNames.count
    }

    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
       if let collection  = item as? CollectibleCollection {
            return collection.itemAtIndex(index) as! AnyObject
       }else{
            let collectionName=self._collectionNames[index]
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

         if let element = item as? CollectibleCollection {
            let view = outlineView.makeViewWithIdentifier("CollectionCell", owner: self) as! NSTableCellView
            if let textField = view.textField {
                textField.stringValue = element.d_collectionName
            }
            if let imageView = view.imageView {
                //imageView.image=NSImage(named:"1052-database" )
            }
             return view

         }else if let element = item as? Collectible {
            let view = outlineView.makeViewWithIdentifier("ObjectCell", owner: self) as! NSTableCellView
            if let textField = view.textField {
                textField.stringValue = Pluralization.singularize(element.d_collectionName)+" <"+(element.summary ?? element.UID)+">"
            }
            if let imageView = view.imageView {
                //imageView.image=NSImage(named:"916-planet")
            }
            return view
        }
        return NSView()
    }


    func outlineView(outlineView: NSOutlineView, heightOfRowByItem item: AnyObject) -> CGFloat {
        if let element = item as? CollectibleCollection {
            return 24
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


// MARK: - DetailsDelegate

class DetailsDelegate:NSObject,NSOutlineViewDelegate,NSOutlineViewDataSource{

    private var _instance:Collectible

    private weak var _outlineView:NSOutlineView!

    required init(object:Collectible,outlineView:NSOutlineView) {
        self._instance=object
        self._outlineView=outlineView
    }

    func outlineViewSelectionDidChange(notification: NSNotification) {
        if let item=self._outlineView.itemAtRow(_outlineView.selectedRow) {
            bprint("** \(item)", file: #file, function: #function, line: #line, category: Default.BPRINT_CATEGORY, decorative: false)
        }
    }

}

