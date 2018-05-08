//
//  LogsViewController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 15/07/2016.
//
//

import BartlebyKit
import BartlebysUI
import Cocoa

class LogsViewController: NSViewController, DocumentDependent {
    override var nibName: NSNib.Name { return NSNib.Name("LogsViewController") }

    @IBOutlet var messageColumn: NSTableColumn!
    @objc dynamic var font: NSFont = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)

    fileprivate var _document: BartlebyDocument?

    @IBOutlet var tableView: BXTableView!

    @IBOutlet var searchField: NSSearchField!

    @IBOutlet var arrayController: NSArrayController!

    @objc dynamic var entries = [LogEntry]()

    fileprivate var _lockFilterUpdate = false

    // MARK: - DocumentDependent

    internal var documentProvider: DocumentProvider? {
        didSet {
            if let documentReference = self.documentProvider?.getDocument() {
                _document = documentReference
                _document?.logsObservers.append(self)
                entries = _document!.logs
            }
        }
    }

    func providerHasADocument() {}

    // MARK: - life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        _updateFilter()
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
    }

    deinit {
        if let idx = self._document?.logsObservers.index(where: { (observer) -> Bool in
            if let observer = observer as? LogsViewController {
                return observer == self
            } else {
                return false
            }
        }) {
            self._document?.logsObservers.remove(at: idx)
        }
    }

    @IBAction func didChange(_: AnyObject) {
        _updateFilter()
    }

    // MARK: Filtering

    fileprivate func _updateFilter() {
        if !_lockFilterUpdate {
            let predicate = NSPredicate { (object, _) -> Bool in
                if let entry = object as? LogEntry {
                    let searched = PString.ltrim(self.searchField.stringValue)
                    if searched != "" {
                        return entry.message.contains(searched, compareOptions: [NSString.CompareOptions.caseInsensitive, NSString.CompareOptions.diacriticInsensitive])
                    }
                }
                return true
            }
            arrayController.filterPredicate = predicate
        }
    }

    @IBAction func removeAll(_: AnyObject) {
        entries.removeAll()
    }

    @IBAction func refreshLogs(_: AnyObject) {
        if let logs = self._document?.logs {
            entries = logs
        }
    }

    @IBAction func sendAReport(_: AnyObject) {
    }

    @IBAction func copyToPasteBoard(_: AnyObject) {
        var stringifyedMetrics = Default.NO_MESSAGE
        // Take all the Log entries
        if let m = self.arrayController.arrangedObjects as? [LogEntry] {
            let data = try? JSON.prettyEncoder.encode(m)
            if let string = data?.optionalString(using: Default.STRING_ENCODING) {
                stringifyedMetrics = string
            } else {
                stringifyedMetrics = "decoding issue"
            }
        }
        NSPasteboard.general.clearContents()
        let ns: NSString = stringifyedMetrics as NSString
        NSPasteboard.general.writeObjects([ns])
    }
}

extension LogsViewController: LogEntriesObserver {
    func receive(_ entry: LogEntry) {
        syncOnMain {
            self.entries.insert(entry, at: 0)
        }
    }
}

extension LogsViewController: NSTableViewDelegate {
    func tableView(_: NSTableView, heightOfRow row: Int) -> CGFloat {
        guard let item = (self.arrayController.arrangedObjects as? NSArray)?.object(at: row) as? LogEntry else {
            return 20
        }
        let width = messageColumn.width - 80
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byCharWrapping
        let attributes = [NSAttributedStringKey.font: self.font, NSAttributedStringKey.paragraphStyle: paragraphStyle] as [NSAttributedStringKey: Any]
        let boundingBox = item.message.boundingRect(with: constraintRect, options: NSString.DrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        return boundingBox.height + 20
    }
}
