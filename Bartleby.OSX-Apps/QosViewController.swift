//
//  QosViewController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 24/10/2016.
//
//

import Cocoa

class QosViewController: NSViewController ,DocumentDependent{

    override var nibName : String { return "QosViewController" }

    internal dynamic var _document:BartlebyDocument?

    @IBOutlet weak var tableView: BXTableView!

    @IBOutlet weak var searchField: NSSearchField!

    @IBOutlet var arrayController: NSArrayController!

    fileprivate var _lockFilterUpdate=false

    // MARK: life Cycle

    internal var documentProvider: DocumentProvider?{
        didSet{
            if let documentReference=self.documentProvider?.getDocument(){
                self._document=documentReference
                if let m=self._document?.metrics{
                    for metrics in m{
                        print(metrics)
                    }
                }
            }
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self._updateFilter()
    }



    @IBAction func didChange(_ sender: AnyObject) {
        self._updateFilter()
    }

    // MARK: Filtering

    fileprivate func _updateFilter() -> () {
        if !self._lockFilterUpdate{
            let predicate=NSPredicate { (object, _) -> Bool in
                if let entry = object as? Metrics{
                    let searched=PString.ltrim(self.searchField.stringValue)
                    if searched != ""{
                        return entry.operationName.contains(searched)
                    }
                }
                return true
            }
            self.arrayController.filterPredicate=predicate
        }
    }
}




