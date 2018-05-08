//
//  ReportWindowController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 29/10/2016.
//
//

import BartlebyKit
import Cocoa

open class ReportWindowController: NSWindowController {
    open override var windowNibName: NSNib.Name? { return NSNib.Name("ReportWindowController") }

    @IBOutlet var reportTabViewController: ReportTabViewController! {
        didSet {
            self.contentViewController = reportTabViewController
        }
    }

    // MARK: Window

    open override func windowDidLoad() {
        super.windowDidLoad()
        window?.title = NSLocalizedString("Report", tableName: "bartlebys.OSX-Apps", comment: "Report window title")
    }
}
