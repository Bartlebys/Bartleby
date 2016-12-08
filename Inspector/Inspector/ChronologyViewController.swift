//
//  ChronologyViewController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 24/10/2016.
//
//

import Cocoa
import BartlebyKit

class ChronologyViewController: NSViewController ,DocumentDependent,NSTableViewDelegate{

    override var nibName : String { return "ChronologyViewController" }

    internal dynamic var _document:BartlebyDocument?

    @IBOutlet weak var tableView: BXTableView!

    @IBOutlet weak var searchField: NSSearchField!

    @IBOutlet var arrayController: NSArrayController!

    fileprivate var _lockFilterUpdate=false

    @IBOutlet var metricsViewController: MetricsDetailsViewController!


    // MARK - DocumentDependent

    internal var documentProvider: DocumentProvider?{
        didSet{
            if let documentReference=self.documentProvider?.getDocument(){
                self._document=documentReference
            }
        }
    }

    public func providerHasADocument(){}



    // MARK: life Cycle

    override func viewDidAppear() {
        super.viewDidAppear()
        self._updateFilter()
    }


    // Present the metricsViewController
    @IBAction func doubleClick(_ sender: BXTableView) {
        if self.metricsViewController.presenting == nil{
            if let metrics=arrayController.arrangedObjects as? [Metrics]{
                let rows=sender.selectedRowIndexes
                if rows.count>0 {
                    let frame = tableView.frameOfCell(atColumn: sender.clickedColumn, row: sender.clickedRow)
                    var selectedMetrics:[Metrics]=[Metrics]()
                    for idx in rows{
                        selectedMetrics.append(metrics[idx])
                    }
                    selectedMetrics=selectedMetrics.sorted(by: { (rMetrics, lMetrics) -> Bool in
                        return rMetrics.counter > lMetrics.counter
                    })
                    self.metricsViewController.arrayOfmetrics=selectedMetrics
                    self.presentViewController(self.metricsViewController,
                                               asPopoverRelativeTo: frame,
                                               of: tableView,
                                               preferredEdge:NSRectEdge(rawValue: 2)!,
                                               behavior: NSPopoverBehavior.transient)
                }
            }
        }
    }

    @IBAction func copyToPasteBoard(_ sender: AnyObject) {
        var stringifyedMetrics=Default.NO_MESSAGE
        if self.arrayController.selectedObjects.count>0{
            // Take the selection
            if let m=self.arrayController.selectedObjects as? [Metrics]{
                if let j = m.toJSONString(){
                    stringifyedMetrics=j.jsonPrettify()
                }
            }
        }else{
            // Take all the metricss
            if let m=self.arrayController.arrangedObjects as? [Metrics]{
                if let j = m.toJSONString(){
                    stringifyedMetrics=j.jsonPrettify()
                }
            }
        }
        NSPasteboard.general().clearContents()
        let ns:NSString=stringifyedMetrics as NSString
        NSPasteboard.general().writeObjects([ns])
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
