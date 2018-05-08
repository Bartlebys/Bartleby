//
//  ChronologyViewController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 24/10/2016.
//
//

import BartlebyKit
import BartlebysUI
import Cocoa

class ChronologyViewController: NSViewController, DocumentDependent, NSTableViewDelegate {
    override var nibName: NSNib.Name { return NSNib.Name("ChronologyViewController") }

    @objc internal dynamic var _document: BartlebyDocument?

    @IBOutlet var tableView: BXTableView!

    @IBOutlet var searchField: NSSearchField!

    @IBOutlet var arrayController: NSArrayController!

    fileprivate var _lockFilterUpdate = false

    @IBOutlet var metricsViewController: MetricsDetailsViewController!

    // MARK: - DocumentDependent

    internal var documentProvider: DocumentProvider? {
        didSet {
            if let documentReference = self.documentProvider?.getDocument() {
                _document = documentReference
            }
        }
    }

    public func providerHasADocument() {}

    // MARK: life Cycle

    override func viewDidAppear() {
        super.viewDidAppear()
        _updateFilter()
    }

    // Present the metricsViewController
    @IBAction func doubleClick(_ sender: BXTableView) {
        if metricsViewController.presenting == nil {
            if let metrics = arrayController.arrangedObjects as? [Metrics] {
                let rows = sender.selectedRowIndexes
                if rows.count > 0 {
                    let frame = tableView.frameOfCell(atColumn: sender.clickedColumn, row: sender.clickedRow)
                    var selectedMetrics: [Metrics] = [Metrics]()
                    for idx in rows {
                        selectedMetrics.append(metrics[idx])
                    }
                    selectedMetrics = selectedMetrics.sorted(by: { (rMetrics, lMetrics) -> Bool in
                        rMetrics.counter > lMetrics.counter
                    })
                    metricsViewController.arrayOfmetrics = selectedMetrics
                    presentViewController(metricsViewController,
                                          asPopoverRelativeTo: frame,
                                          of: tableView,
                                          preferredEdge: NSRectEdge(rawValue: 2)!,
                                          behavior: NSPopover.Behavior.transient)
                }
            }
        }
    }

    @IBAction func copyToPasteBoard(_: AnyObject) {
        var stringifyedMetrics = Default.NO_MESSAGE
        if arrayController.selectedObjects.count > 0 {
            // Take the selection
            if let m = self.arrayController.selectedObjects as? [Metrics] {
                let data = try? JSON.prettyEncoder.encode(m)
                if let string = data?.optionalString(using: Default.STRING_ENCODING) {
                    stringifyedMetrics = string
                }
            }
        } else {
            // Take all the metricss
            if let m = self.arrayController.arrangedObjects as? [Metrics] {
                let data = try? JSON.prettyEncoder.encode(m)
                if let string = data?.optionalString(using: Default.STRING_ENCODING) {
                    stringifyedMetrics = string
                }
            }
        }
        NSPasteboard.general.clearContents()
        let ns: NSString = stringifyedMetrics as NSString
        NSPasteboard.general.writeObjects([ns])
    }

    // MARK: Filtering

    @IBAction func didChange(_: AnyObject) {
        _updateFilter()
    }

    fileprivate func _updateFilter() {
        if !_lockFilterUpdate {
            let predicate = NSPredicate { (object, _) -> Bool in
                if let entry = object as? Metrics {
                    let searched = PString.ltrim(self.searchField.stringValue)
                    if searched != "" {
                        return entry.operationName.contains(searched, compareOptions: [NSString.CompareOptions.caseInsensitive, NSString.CompareOptions.diacriticInsensitive])
                    }
                }
                return true
            }
            arrayController.filterPredicate = predicate
        }
    }
}
