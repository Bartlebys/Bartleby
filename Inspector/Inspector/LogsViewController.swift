//
//  LogsViewController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 15/07/2016.
//
//

import Cocoa
import BartlebyKit
import BartlebysUI

class LogsViewController: NSViewController,DocumentDependent{

    override var nibName : NSNib.Name { return NSNib.Name("LogsViewController")}

    @IBOutlet weak var messageColumn: NSTableColumn!
    var font:NSFont=NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)

    fileprivate var _document:BartlebyDocument?

    @IBOutlet weak var tableView: BXTableView!

    @IBOutlet weak var searchField: NSSearchField!

    @IBOutlet var arrayController: NSArrayController!

    @objc dynamic var entries=[LogEntry]()

    fileprivate var _lockFilterUpdate=false


    // MARK: - DocumentDependent

    internal var documentProvider: DocumentProvider?{
        didSet{
            if let documentReference=self.documentProvider?.getDocument(){
                self._document=documentReference
                self._document?.logsObservers.append(self)
                self.entries=self._document!.logs
            }
        }
    }

    func providerHasADocument() {}

    // MARK: - life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
    }


    override func viewDidAppear() {
        super.viewDidAppear()
        self._updateFilter()
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
    }

    deinit{
        if let idx=self._document?.logsObservers.index(where: { (observer) -> Bool in
            if let observer=observer as? LogsViewController{
                return observer == self
            }else{
                return false
            }
        }){
            self._document?.logsObservers.remove(at: idx)
        }
    }


    @IBAction func didChange(_ sender: AnyObject) {
        self._updateFilter()
    }

    // MARK: Filtering


    fileprivate func _updateFilter() -> () {
        if !self._lockFilterUpdate{
            let predicate=NSPredicate { (object, _) -> Bool in
                if let entry = object as? LogEntry{
                    let searched=PString.ltrim(self.searchField.stringValue)
                    if searched != ""{
                        return entry.message.contains(searched, compareOptions: [NSString.CompareOptions.caseInsensitive,NSString.CompareOptions.diacriticInsensitive])
                    }
                }
                return true
            }
            self.arrayController.filterPredicate=predicate
        }
    }


    @IBAction func removeAll(_ sender: AnyObject) {
        self.entries.removeAll()
    }


    @IBAction func reload(_ sender: AnyObject) {
        if let logs=self._document?.logs{
            self.entries=logs
        }
    }

    @IBAction func sendAReport(_ sender: AnyObject) {
    }

    @IBAction func copyToPasteBoard(_ sender: AnyObject) {
        var stringifyedMetrics=Default.NO_MESSAGE
        // Take all the Log entries
        if let m=self.arrayController.arrangedObjects as? [LogEntry]{
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try? encoder.encode(m)
            if let string = data?.optionalString(using:Default.STRING_ENCODING){
                stringifyedMetrics = string
            }else{
                stringifyedMetrics = "decoding issue"
            }
        }
        NSPasteboard.general.clearContents()
        let ns:NSString=stringifyedMetrics as NSString
        NSPasteboard.general.writeObjects([ns])
    }


}

extension LogsViewController:LogEntriesObserver{

    func receive(_ entry:LogEntry){
        Bartleby.syncOnMain {
            self.entries.insert(entry, at: 0)
        }
    }
}

extension LogsViewController:NSTableViewDelegate{

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        guard let item = (self.arrayController.arrangedObjects as? NSArray)?.object(at:row) as? LogEntry else {
            return 20
        }
        let width=self.messageColumn.width-80;
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSParagraphStyle.LineBreakMode.byCharWrapping;
        let attributes = [NSAttributedStringKey.font.rawValue:font, NSAttributedStringKey.paragraphStyle:paragraphStyle] as! [NSAttributedStringKey : Any]
        let boundingBox = item.message.boundingRect(with: constraintRect, options: NSString.DrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        return boundingBox.height + 20
    }
}
