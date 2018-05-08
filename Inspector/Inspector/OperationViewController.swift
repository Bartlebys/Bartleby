//
//  OperationsViewController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 15/07/2016.
//
//

import BartlebyKit
import Cocoa

class OperationViewController: NSViewController, Editor {
    typealias EditorOf = PushOperation

    var UID: String = Bartleby.createUID()

    override var nibName: NSNib.Name { return NSNib.Name("OperationViewController") }

    @objc dynamic weak var selectedItem: EditorOf?

    override var representedObject: Any? {
        willSet {
            if let _ = self.selectedItem {
                self.selectedItem?.removeChangesSuperviser(self)
            }
        }
        didSet {
            self.selectedItem = representedObject as? EditorOf
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    @IBAction func pushSelectedOperation(_: AnyObject) {
        if let operation = self.selectedItem {
            let ops = [operation]
            let handlers = Handlers(completionHandler: { completion in
                glog("\(completion)", file: #file, function: #function, line: #line)
            })
            handlers.appendProgressHandler({ progression in
                glog("\(progression)", file: #file, function: #function, line: #line)
            })
            if let document = self.selectedItem?.referentDocument {
                document.pushSortedOperations(ops, handlers: handlers)
            }
        }
    }
}
