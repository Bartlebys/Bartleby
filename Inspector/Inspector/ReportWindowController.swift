//
//  ReportWindowController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 29/10/2016.
//
//

import Cocoa
import BartlebyKit

open class ReportWindowController: NSWindowController{

    override open var windowNibName: String?{ return "ReportWindowController" }

    @IBOutlet var reportTabViewController: ReportTabViewController!{
        didSet{
            self.contentViewController=reportTabViewController
        }
    }

     //MARK : Window

    override open func windowDidLoad() {
        super.windowDidLoad()
        self.window?.title=NSLocalizedString("Report", tableName:"bartlebys.OSX-Apps", comment: "Report window title")
    }

}
