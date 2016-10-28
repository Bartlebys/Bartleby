//
//  QosViewController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 24/10/2016.
//
//

import Cocoa

class QosViewController: NSViewController ,DocumentDependent,NSTableViewDelegate{

    override var nibName : String { return "QosViewController" }

    internal dynamic var _document:BartlebyDocument?

    @IBOutlet weak var tableView: BXTableView!

    @IBOutlet weak var searchField: NSSearchField!

    @IBOutlet var arrayController: NSArrayController!

    fileprivate var _lockFilterUpdate=false

    @IBOutlet var metricsViewController: MetricsDetailsViewController!

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


    // Present the metricsViewController
    @IBAction func doubleClick(_ sender: BXTableView) {
        if self.metricsViewController.presenting == nil{
            if let metrics=arrayController.arrangedObjects as? [Metrics]{
                let row=sender.selectedRow
                if metrics.count > row &&  row >= 0 {
                    let frame = tableView.frameOfCell(atColumn: sender.clickedColumn, row: sender.clickedRow)
                    self.metricsViewController.metrics=metrics[row]
                    self.presentViewController(self.metricsViewController,
                                               asPopoverRelativeTo: frame,
                                               of: tableView,
                                               preferredEdge:NSRectEdge(rawValue: 2)!,
                                               behavior: NSPopoverBehavior.transient)
                }
            }
        }
    }


    // MARK: Filtering


    @IBAction func didChange(_ sender: AnyObject) {
        self._updateFilter()
    }

    fileprivate func _updateFilter() -> () {
        if !self._lockFilterUpdate{
            let predicate=NSPredicate { (object, _) -> Bool in
                if let entry = object as? Metrics{
                    let searched=PString.ltrim(self.searchField.stringValue)
                    if searched != ""{
                        return entry.operationName.contains(searched, compareOptions: [NSString.CompareOptions.caseInsensitive,NSString.CompareOptions.diacriticInsensitive])
                    }
                }
                return true
            }
            self.arrayController.filterPredicate=predicate
        }
    }
    

}
