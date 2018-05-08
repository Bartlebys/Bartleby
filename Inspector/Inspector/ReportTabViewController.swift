//
//  ReportTabViewController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 01/11/2016.
//
//

import BartlebyKit
import Cocoa

class ReportTabViewController: NSTabViewController, AsyncDocumentDependent, DocumentProvider {
    override var nibName: NSNib.Name { return NSNib.Name("ReportTabViewController") }

    internal var _decryptorTabViewItem: NSTabViewItem?

    @IBOutlet var metadataDetailsViewController: MetadataDetails! {
        didSet {
            metadataDetailsViewController.reportMode = true
        }
    }

    @IBOutlet var chronologyController: ChronologyViewController! {
        didSet {
            chronologyController.title = NSLocalizedString("Chronology", comment: "Chronology")
        }
    }

    @IBOutlet var logsViewController: LogsViewController! {
        didSet {
            logsViewController.title = NSLocalizedString("Logs", comment: "Logs")
        }
    }

    @IBOutlet var decryptor: DecryptorViewController! {
        didSet {
            decryptor.title = NSLocalizedString("Paste your crypted report", comment: "Paste your crypted report")
            self._decryptorTabViewItem = NSTabViewItem(viewController: self.decryptor)
            self.addTabViewItem(self._decryptorTabViewItem!)
            // The decryptView will generate a document based on the crypted data
            self.documentProvider = self.decryptor
            self.decryptor.addDocumentConsumer(consumer: self)
        }
    }

    // MARK: View Life Cycle

    open override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - DocumentProvider

    fileprivate var _document: BartlebyDocument?

    open func getDocument() -> BartlebyDocument? {
        return _document
    }

    // MARK: - AsyncDocumentDependent

    open var documentProvider: AsyncDocumentProvider?

    public func providerHasADocument() {
        if let documentReference = self.documentProvider?.getDocument() {
            _document = documentReference // We can become DocumentProvider for the other tab.
            removeTabViewItem(_decryptorTabViewItem!)

            let metadataTabViewItem = NSTabViewItem(viewController: metadataDetailsViewController)
            addTabViewItem(metadataTabViewItem)
            metadataDetailsViewController.representedObject = documentReference.metadata

            let logsTabViewItem = NSTabViewItem(viewController: logsViewController)
            addTabViewItem(logsTabViewItem)
            logsViewController.documentProvider = self

            let chronologyTabViewItem = NSTabViewItem(viewController: chronologyController)
            addTabViewItem(chronologyTabViewItem)
            chronologyController.documentProvider = self
        }
    }
}
