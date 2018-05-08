//
//  DocumentInspector.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 14/07/2016.
//
//

import BartlebyKit
import Cocoa

public protocol Editor: Identifiable {
    associatedtype EditorOf: AnyObject
}

open class DocumentInspector: NSWindowController, DocumentProvider, DocumentDependent {
    open override var windowNibName: NSNib.Name? { return NSNib.Name("DocumentInspector") }

    static let CHANGES_HAS_BEEN_RESET_NOTIFICATION = "CHANGES_HAS_BEEN_RESET_NOTIFICATION"

    // In the tool bar
    @IBOutlet var scopeSegmentedControl: NSSegmentedControl!

    @IBOutlet var globalTabView: NSTabView!

    // View Controllers

    @IBOutlet var inspectorViewController: InspectorViewController!

    @IBOutlet var logsViewController: LogsViewController!

    @IBOutlet var webStackViewController: WebStack!

    @IBOutlet var chronologyViewController: ChronologyViewController!

    @IBOutlet var bsfsViewController: BSFSViewController!

    // We bind this index on the scopeSegmentedControl
    @objc open dynamic var selectedIndex: Int = -1 {
        didSet {
            if oldValue != selectedIndex || (oldValue == -1 && selectedIndex >= 0) {
                self.globalTabView.selectTabViewItem(at: selectedIndex)
            }
        }
    }

    // The selected document
    @objc dynamic weak var castedDocument: BartlebyDocument?

    // MARK: Window

    open override func windowDidLoad() {
        super.windowDidLoad()
    }

    // MARK: - DocumentProvider

    open func getDocument() -> BartlebyDocument? {
        return castedDocument
    }

    // MARK: - DocumentDependent

    open var documentProvider: DocumentProvider? {
        didSet {
            if let documentReference = self.documentProvider?.getDocument() {
                document = nil
                castedDocument = documentReference
                castedDocument?.metadata.changesAreInspectables = true
                window?.title = NSLocalizedString("Inspector", tableName: "bartlebys.OSX-Apps", comment: "Inspector window title") + " (" + (documentReference.fileURL?.lastPathComponent ?? "") + ")"

                let inspectorTabViewItem = NSTabViewItem(viewController: inspectorViewController)
                globalTabView.addTabViewItem(inspectorTabViewItem)
                inspectorViewController.documentProvider = self

                let logsTabViewItem = NSTabViewItem(viewController: logsViewController)
                globalTabView.addTabViewItem(logsTabViewItem)
                logsViewController.documentProvider = self

                let webTabViewItem = NSTabViewItem(viewController: webStackViewController)
                globalTabView.addTabViewItem(webTabViewItem)
                webStackViewController.documentProvider = self

                let chronologyTabViewItem = NSTabViewItem(viewController: chronologyViewController)
                globalTabView.addTabViewItem(chronologyTabViewItem)
                chronologyViewController.documentProvider = self

                let bsfsTabViewItem = NSTabViewItem(viewController: bsfsViewController)
                globalTabView.addTabViewItem(bsfsTabViewItem)
                bsfsViewController.documentProvider = self
            }
        }
    }

    @IBAction func openWebStack(_: AnyObject) {
        if let document = self.castedDocument {
            if let url = document.metadata.currentUser?.signInURL(for: document) {
                NSWorkspace.shared.open(url)
            }
        }
    }

    @IBAction func pushOperations(_: AnyObject) {
        if let document = self.castedDocument {
            document.synchronizePendingOperations()
        }
    }
}
