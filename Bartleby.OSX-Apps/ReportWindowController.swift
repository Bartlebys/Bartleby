//
//  ReportWindowController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 29/10/2016.
//
//

import Cocoa

open class ReportWindowController: NSWindowController,AsyncDocumentDependent,DocumentProvider{


    override open var windowNibName: String?{ return "ReportWindowController" }

    @IBOutlet var tabViewController: NSTabViewController!

    internal var _decryptorTabViewItem:NSTabViewItem?

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
        }
    }

    //MARK : Window

    override open func windowDidLoad() {
        super.windowDidLoad()
        self.window?.title=NSLocalizedString("Report", tableName:"bartlebys.OSX-Apps", comment: "Inspector window title")

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        self.contentViewController=tabViewController

        self._decryptorTabViewItem=NSTabViewItem(viewController:self.decryptor)
        self.tabViewController.addTabViewItem(self._decryptorTabViewItem!)

         // The decryptView will generate a document based on the crypted data
        self.documentProvider=self.decryptor
        self.decryptor.addDocumentConsumer(consumer: self)
    }


    // DocumentProvider

    open func getDocument() -> BartlebyDocument?{
        return self.document as? BartlebyDocument
    }


    // MARK: DocumentDependent

    open var documentProvider: AsyncDocumentProvider?


    public func providerHasADocument(){
        if let documentReference=self.documentProvider?.getDocument(){
            self.document=documentReference // We can become DocumentProvider for the other tab.

            self.tabViewController.removeTabViewItem(self._decryptorTabViewItem!)

            let logsTabViewItem=NSTabViewItem(viewController:self.logsViewController)
            self.tabViewController.addTabViewItem(logsTabViewItem)
            self.logsViewController.documentProvider=self

            let chronologyTabViewItem=NSTabViewItem(viewController:self.chronologyController)
            self.tabViewController.addTabViewItem(chronologyTabViewItem)
            self.chronologyController.documentProvider=self
        }
    }




    
}
