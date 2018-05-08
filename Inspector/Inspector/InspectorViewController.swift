//
//  InspectorViewController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 15/07/2016.
//
//

import BartlebyKit
import Cocoa

protocol FilterPredicateDelegate {
    func filterSelectedIndex() -> Int
    func filterExpression() -> String
}

class InspectorViewController: NSViewController, DocumentDependent, FilterPredicateDelegate {
    override var nibName: NSNib.Name { return NSNib.Name("InspectorViewController") }

    @IBOutlet var listOutlineView: NSOutlineView!

    @IBOutlet var topBox: NSBox!

    @IBOutlet var bottomBox: NSBox!

    // Provisionned View controllers

    @IBOutlet var sourceEditor: SourceEditor!

    @IBOutlet var operationViewController: OperationViewController!

    @IBOutlet var changesViewController: ChangesViewController!

    @IBOutlet var metadataViewController: MetadataDetails!

    @IBOutlet var contextualMenu: NSMenu!

    @IBOutlet var filterPopUp: NSPopUpButton!

    @IBOutlet var filterField: NSSearchField!

    override func validateMenuItem(_: NSMenuItem) -> Bool {
        return true
    }

    // The currently associated View Controller
    fileprivate var _topViewController: NSViewController?

    fileprivate var _bottomViewController: NSViewController?

    // MARK: - Menu Actions

    @IBAction func resetAllSupervisionCounter(_: AnyObject) {
        if let documentReference = self.documentProvider?.getDocument() {
            documentReference.metadata.currentUser?.changedKeys.removeAll()
            documentReference.iterateOnCollections({ collection in
                if let o = collection as? ManagedModel {
                    o.changedKeys.removeAll()
                }
            })
            documentReference.superIterate({ element in
                if let o = element as? ManagedModel {
                    o.changedKeys.removeAll()
                }
            })
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: DocumentInspector.CHANGES_HAS_BEEN_RESET_NOTIFICATION), object: nil)
    }

    @IBAction func commitChanges(_: AnyObject) {
        if let documentReference = self.documentProvider?.getDocument() {
            do {
                try documentReference.commitPendingChanges()
            } catch {
            }
        }
    }

    @IBAction func openWebStack(_: AnyObject) {
        if let document = self.documentProvider?.getDocument() {
            if let url = document.metadata.currentUser?.signInURL(for: document) {
                NSWorkspace.shared.open(url)
            }
        }
    }

    @IBAction func saveDocument(_ sender: AnyObject) {
        if let documentReference = self.documentProvider?.getDocument() {
            documentReference.save(sender)
        }
    }

    @IBAction func deleteOperations(_: AnyObject) {
        if let documentReference = self.documentProvider?.getDocument() {
            for operation in documentReference.pushOperations.reversed() {
                documentReference.pushOperations.removeObject(operation, commit: false)
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: REFRESH_METADATA_INFOS_NOTIFICATION_NAME), object: nil)
        }
    }

    @IBAction func cleanupOperationQuarantine(_: AnyObject) {
        if let document = self.documentProvider?.getDocument() {
            document.metadata.operationsQuarantine.removeAll()
            NotificationCenter.default.post(name: Notification.Name(rawValue: REFRESH_METADATA_INFOS_NOTIFICATION_NAME), object: nil)
        }
    }

    @IBAction func forceDataIntegration(_: AnyObject) {
        if let document = self.documentProvider?.getDocument() {
            document.forceDataIntegration()
            NotificationCenter.default.post(name: Notification.Name(rawValue: REFRESH_METADATA_INFOS_NOTIFICATION_NAME), object: nil)
        }
    }

    @IBAction func deleteBSFSOrpheans(_: NSMenuItem) {
        if let document = self.documentProvider?.getDocument() {
            document.blocks.reversed().forEach({ block in
                if block.ownedBy.count == 0 {
                    try? block.erase()
                }
            })
            document.nodes.reversed().forEach({ node in
                if node.ownedBy.count == 0 {
                    try? node.erase()
                }
            })
            document.boxes.reversed().forEach({ box in
                if box.ownedBy.count == 0 {
                    try? box.erase()
                }
            })
        }
    }

    @IBAction func deleteSelectedEntity(_: NSMenuItem) {
        if let item = self.listOutlineView.item(atRow: self.listOutlineView.selectedRow) as? ManagedModel {
            try? item.erase()
        }
    }

    // MARK: -  Collections

    fileprivate var _collectionListDelegate: CollectionListDelegate?

    // MARK: - DocumentDependent

    internal var documentProvider: DocumentProvider? {
        didSet {
            if let documentReference = self.documentProvider?.getDocument() {
                _collectionListDelegate = CollectionListDelegate(documentReference: documentReference, filterDelegate: self, outlineView: listOutlineView, onSelection: { selected in
                    self.updateRepresentedObject(selected)
                })

                _topViewController = sourceEditor
                _bottomViewController = changesViewController

                topBox.contentView = _topViewController!.view
                bottomBox.contentView = _bottomViewController!.view

                listOutlineView.delegate = _collectionListDelegate
                listOutlineView.dataSource = _collectionListDelegate
                _collectionListDelegate?.reloadData()

                metadataViewController.documentProvider = documentProvider
            }
        }
    }

    func providerHasADocument() {}

    // MARK: - initialization

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: DocumentInspector.CHANGES_HAS_BEEN_RESET_NOTIFICATION), object: nil, queue: nil) { _ in
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
    func updateRepresentedObject(_ selected: Any?) {
        if let document = self.documentProvider?.getDocument() {
            if selected == nil {
                document.log("Represented object is nil", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
            }
        } else {
            glog("Document provider fault", file: #file, function: #function, line: #line, category: Default.LOG_FAULT, decorative: false)
        }
        if let object = selected as? ManagedModel {
            // Did the type of represented object changed.
            if object.runTimeTypeName() != (_bottomViewController?.representedObject as? Collectible)?.runTimeTypeName() {
                switch object {
                case _ where object is PushOperation:
                    _topViewController = sourceEditor
                    _bottomViewController = operationViewController
                    break
                default:
                    _topViewController = sourceEditor
                    _bottomViewController = changesViewController
                }
            }
        } else {
            // It  a UnManagedModel
            if let _ = selected as? DocumentMetadata {
                _topViewController = sourceEditor
                _bottomViewController = metadataViewController
            }
        }

        if let object = selected as? NSObject {
            if topBox.contentView != _topViewController!.view {
                topBox.contentView = _topViewController!.view
            }

            if bottomBox.contentView != _bottomViewController!.view {
                bottomBox.contentView = _bottomViewController!.view
            }

            if (_topViewController?.representedObject as? NSObject) != object {
                _topViewController?.representedObject = object
            }
            if (_bottomViewController?.representedObject as? NSObject) != object {
                _bottomViewController?.representedObject = object
            }
        }
    }

    // MARK: - Filtering

    @IBAction func firstPartOfPredicateDidChange(_: Any) {
        let idx = filterPopUp.indexOfSelectedItem
        if idx == 0 {
            filterField.isEnabled = false
        } else {
            filterField.isEnabled = true
        }
        _collectionListDelegate?.updateFilter()
    }

    @IBAction func filterOperandDidChange(_: Any) {
        _collectionListDelegate?.updateFilter()
    }

    // MARK: - FilterPredicateDelegate

    public func filterSelectedIndex() -> Int {
        return filterPopUp.indexOfSelectedItem
    }

    public func filterExpression() -> String {
        return PString.trim(filterField.stringValue)
    }
}

// MARK: - CollectionListDelegate

class CollectionListDelegate: NSObject, NSOutlineViewDelegate, NSOutlineViewDataSource, Identifiable {
    fileprivate var _filterPredicateDelegate: FilterPredicateDelegate

    fileprivate var _documentReference: BartlebyDocument

    fileprivate var _outlineView: NSOutlineView!

    fileprivate var _selectionHandler: ((_ selected: Any) -> Void)

    fileprivate var _collections: [BartlebyCollection] = [BartlebyCollection]()

    fileprivate var _filteredCollections: [BartlebyCollection] = [BartlebyCollection]()

    var UID: String = Bartleby.createUID()

    required init(documentReference: BartlebyDocument, filterDelegate: FilterPredicateDelegate, outlineView: NSOutlineView, onSelection: @escaping ((_ selected: Any) -> Void)) {
        _documentReference = documentReference
        _outlineView = outlineView
        _selectionHandler = onSelection
        _filterPredicateDelegate = filterDelegate
        super.init()
        _documentReference.iterateOnCollections { collection in
            self._collections.append(collection)
            collection.addChangesSuperviser(self, closure: { _, _, _ in
                self.reloadData()
            })
        }
        // No Filter by default
        _filteredCollections = _collections
    }

    public func updateFilter() {
        let idx = _filterPredicateDelegate.filterSelectedIndex()
        let expression = _filterPredicateDelegate.filterExpression()
        if idx == 0 || expression == "" && idx < 8 {
            _filteredCollections = _collections
        } else {
            _filteredCollections = [BartlebyCollection]()
            for collection in _collections {
                let filteredCollection = collection.filteredCopy({ (instance) -> Bool in
                    if let o = instance as? ManagedModel {
                        if idx == 1 {
                            // UID contains
                            return o.UID.contains(expression, compareOptions: NSString.CompareOptions.caseInsensitive)
                        } else if idx == 2 {
                            // ExternalId contains
                            return o.externalID.contains(expression, compareOptions: NSString.CompareOptions.caseInsensitive)
                        } else if idx == 4 {
                            // ---------
                            // Is owned by <UID>
                            return o.ownedBy.contains(expression)
                        } else if idx == 5 {
                            // Owns <UID>
                            return o.owns.contains(expression)
                        } else if idx == 6 {
                            // Is related to <UID>
                            return o.freeRelations.contains(expression)
                        } else if idx == 8 {
                            // --------- NO Expression required after this separator
                            // Changes Count > 0
                            return o.changedKeys.count > 0
                        }
                    }
                    return false
                })
                if filteredCollection.count > 0 {
                    if let casted = filteredCollection as? BartlebyCollection {
                        _filteredCollections.append(casted)
                    }
                }
            }
        }
        reloadData()
    }

    func reloadData() {
        // Data reload must be async to support deletions.
        Async.main {
            var selectedIndexes = self._outlineView.selectedRowIndexes
            self._outlineView.reloadData()
            if selectedIndexes.count == 0 && self._outlineView.numberOfRows > 0 {
                selectedIndexes = IndexSet(integer: 0)
            }
            self._outlineView.selectRowIndexes(selectedIndexes, byExtendingSelection: false)
        }
    }

    // MARK: - NSOutlineViewDataSource

    func outlineView(_: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return _filteredCollections.count + 1
        }

        if let object = item as? ManagedModel {
            if let collection = object as? BartlebyCollection {
                return collection.count
            }
        }
        return 0
    }

    func outlineView(_: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            // Root of the tree
            // Return the Metadata
            if index == 0 {
                return _documentReference.metadata
            } else {
                // Return the collections with a shifted index
                return _filteredCollections[index - 1]
            }
        }

        if let object = item as? ManagedModel {
            if let collection = object as? BartlebyCollection {
                if let element = collection.item(at: index) {
                    return element
                }
                return "<!>\(object.runTimeTypeName())"
            }
        }
        return "ERROR #\(index)"
    }

    func outlineView(_: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let object = item as? ManagedModel {
            return object is BartlebyCollection
        }
        return false
    }

    func outlineView(_: NSOutlineView, persistentObjectForItem item: Any?) -> Any? {
        if let object = item as? ManagedModel {
            return object.alias().serialize()
        }
        return nil
    }

    func outlineView(_: NSOutlineView, itemForPersistentObject object: Any) -> Any? {
        if let data = object as? Data {
            if let alias = try? Alias.deserialize(from: data) {
                return Bartleby.instance(from: alias)
            }
        }
        return nil
    }

    // MARK: - NSOutlineViewDelegate

    public func outlineView(_ outlineView: NSOutlineView, viewFor _: NSTableColumn?, item: Any) -> NSView? {
        if let object = item as? ManagedModel {
            if let casted = object as? BartlebyCollection {
                let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CollectionCell"), owner: self) as! NSTableCellView
                if let textField = view.textField {
                    textField.stringValue = casted.d_collectionName
                }
                configureInlineButton(view, object: casted)
                return view
            } else if let casted = object as? User {
                let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "UserCell"), owner: self) as! NSTableCellView
                if let textField = view.textField {
                    if casted.UID == _documentReference.currentUser.UID {
                        textField.stringValue = "Current User"
                    } else {
                        textField.stringValue = casted.UID
                    }
                }
                configureInlineButton(view, object: casted)
                return view
            } else {
                let casted = object
                let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ObjectCell"), owner: self) as! NSTableCellView
                if let textField = view.textField {
                    textField.stringValue = casted.UID
                }
                configureInlineButton(view, object: casted)
                return view
            }
        } else {
            // Value Object
            if let object = item as? DocumentMetadata {
                let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ObjectCell"), owner: self) as! NSTableCellView
                if let textField = view.textField {
                    textField.stringValue = "Document Metadata"
                }
                configureInlineButton(view, object: object)
                return view
            } else {
                let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ObjectCell"), owner: self) as! NSTableCellView
                if let textField = view.textField {
                    if let s = item as? String {
                        textField.stringValue = s
                    } else {
                        textField.stringValue = "Anomaly"
                    }
                }
                return view
            }
        }
    }

    fileprivate func configureInlineButton(_ view: NSView, object: Any) {
        if let inlineButton = view.viewWithTag(2) as? NSButton {
            if let casted = object as? Collectible {
                if let casted = object as? BartlebyCollection {
                    inlineButton.isHidden = false
                    inlineButton.title = "\(casted.count) | \(casted.changedKeys.count)"
                    return
                } else if object is DocumentMetadata {
                    inlineButton.isHidden = true
                    inlineButton.title = ""
                } else {
                    if casted.changedKeys.count > 0 {
                        inlineButton.isHidden = false
                        inlineButton.title = "\(casted.changedKeys.count)"
                        return
                    }
                }
            }
            inlineButton.isHidden = true
        }
    }

    func outlineView(_: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        if let object = item as? ManagedModel {
            if object is BartlebyCollection { return 20 }
            return 20 // Any ManagedModel
        }
        if item is DocumentMetadata { return 20 }
        if item is String { return 20 }
        return 30 // This is not normal.
    }

    func outlineView(_: NSOutlineView, shouldSelectItem _: Any) -> Bool {
        return true
    }

    func outlineViewSelectionDidChange(_: Notification) {
        syncOnMain {
            let selected = self._outlineView.selectedRow
            if let item = self._outlineView.item(atRow: selected) {
                self._selectionHandler(item)
            }
        }
    }
}
