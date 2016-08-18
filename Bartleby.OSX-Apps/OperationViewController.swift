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


     dynamic var selectedItem:EditorOf?{
        didSet{

        }
    }
    

    override var representedObject: AnyObject?{
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



    @IBAction func pushSelectedOperation(sender: AnyObject) {
        if let operation=self.selectedItem{
            var ops=[Operation]()
            ops.append(operation)
            let handlers=Handlers(completionHandler: { (completion) in
                bprint("\(completion)", file:#file, function:#function, line:#line)
            })
            handlers.appendProgressHandler({ (progression) in
                bprint("\(progression)", file:#file, function:#function, line:#line)
            })
            do {
                if let document=self.selectedItem?.document{
                    try document.pushArrayOfOperations(ops, handlers: handlers)
                }
            } catch {
                bprint("Push operation has failed error: \(error)", file:#file, function:#function, line:#line)
            }
        }
    }

}
