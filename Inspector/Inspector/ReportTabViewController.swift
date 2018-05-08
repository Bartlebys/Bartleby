//
//  ReportTabViewController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 01/11/2016.
//
//

import Cocoa
import BartlebyKit

class ReportTabViewController: NSTabViewController,AsyncDocumentDependent,DocumentProvider {

    override var nibName : NSNib.Name { return NSNib.Name("ReportTabViewController") }

    internal var _decryptorTabViewItem:NSTabViewItem?

    @IBOutlet var metadataDetailsViewController: MetadataDetails!{
        didSet{
            metadataDetailsViewController.reportMode=true
        }
    }

    @IBOutlet var chronologyController: ChronologyViewController!{
        didSet{
            chronologyController.title=NSLocalizedString("Chronology", comment: "Chronology")
        }
    }

    @IBOutlet var logsViewController: LogsViewController!{
        didSet{
            logsViewController.title=NSLocalizedString("Logs", comment: "Logs")
        }
    }

    @IBOutlet var decryptor: DecryptorViewController!{
        didSet{
            decryptor.title=NSLocalizedString("Paste your crypted report", comment: "Paste your crypted report")
            self._decryptorTabViewItem=NSTabViewItem(viewController:self.decryptor)
            self.addTabViewItem(self._decryptorTabViewItem!)
            // The decryptView will generate a document based on the crypted data
            self.documentProvider=self.decryptor
            self.decryptor.addDocumentConsumer(consumer: self)
        }
    }

    //MARK : View Life Cycle

    override open func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - DocumentProvider

    fileprivate var _document:BartlebyDocument?

    open func getDocument() -> BartlebyDocument?{
        return self._document
    }


    // MARK: - AsyncDocumentDependent

    open var documentProvider: AsyncDocumentProvider?

    public func providerHasADocument(){
        if let documentReference=self.documentProvider?.getDocument(){
            self._document=documentReference // We can become DocumentProvider for the other tab.
            self.removeTabViewItem(self._decryptorTabViewItem!)

            let metadataTabViewItem=NSTabViewItem(viewController:self.metadataDetailsViewController)
            self.addTabViewItem(metadataTabViewItem)
            self.metadataDetailsViewController.representedObject=documentReference.metadata

            let logsTabViewItem=NSTabViewItem(viewController:self.logsViewController)
            self.addTabViewItem(logsTabViewItem)
            self.logsViewController.documentProvider=self

            let chronologyTabViewItem=NSTabViewItem(viewController:self.chronologyController)
            self.addTabViewItem(chronologyTabViewItem)
            self.chronologyController.documentProvider=self
        }
    }
}
