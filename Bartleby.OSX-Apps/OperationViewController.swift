//
//  OperationsViewController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 15/07/2016.
//
//

import Cocoa

class OperationViewController: NSViewController,Editor{

    typealias EditorOf=Operation

    var UID:String=Bartleby.createUID()

    dynamic weak var selectedItem:EditorOf?

    override var representedObject: Any?{
        willSet{
            if let _=self.selectedItem{
                self.selectedItem?.removeChangesSuperviser(self)
            }
        }
        didSet{
            self.selectedItem=representedObject as? EditorOf
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }


    @IBAction func pushSelectedOperation(_ sender: AnyObject) {
        if let operation=self.selectedItem{
            var ops=[Operation]()
            ops.append(operation)
            let handlers=Handlers(completionHandler: { (completion) in
                bprint("\(completion)", file:#file, function:#function, line:#line)
            })
            handlers.appendProgressHandler({ (progression) in
                bprint("\(progression)", file:#file, function:#function, line:#line)
            })
            if let document=self.selectedItem?.document{
                document.pushSortedOperations(ops, handlers: handlers)
            }
        }
    }
    
}
