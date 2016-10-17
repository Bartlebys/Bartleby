//
//  LogsViewController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 15/07/2016.
//
//

import Cocoa

class LogsViewController: NSViewController,RegistryDependent{

    override var nibName : String { return "LogsViewController" }

    @IBOutlet weak var messageColumn: NSTableColumn!
    var font:NSFont=NSFont.systemFont(ofSize: NSFont.smallSystemFontSize())

    fileprivate var _registry:BartlebyDocument?
    
    @IBOutlet weak var tableView: BXTableView!

    @IBOutlet weak var searchField: NSSearchField!

    @IBOutlet var arrayController: NSArrayController!

    dynamic var entries=[PrintEntry]()

    fileprivate var _lockFilterUpdate=false


    // MARK: life Cycle

    internal var registryDelegate: RegistryDelegate?{
        didSet{
            if let registry=self.registryDelegate?.getRegistry(){
                self._registry=registry
                self.entries=Bartleby.bprintCollection.entries
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Bartleby.bPrintObservers.append(self)
        //self.tableView.setDataSource(self)
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
        if let idx=Bartleby.bPrintObservers.index(where: { (observer) -> Bool in
            if let observer=observer as? LogsViewController{
                return observer == self
            }else{
                return false
            }
        }){
            Bartleby.bPrintObservers.remove(at: idx)
        }
    }


    @IBAction func didChange(_ sender: AnyObject) {
        self._updateFilter()
    }
    
    // MARK: Filtering


    fileprivate func _updateFilter() -> () {
        if !self._lockFilterUpdate{
            let predicate=NSPredicate { (object, _) -> Bool in
                if let entry = object as? PrintEntry{
                    let searched=PString.ltrim(self.searchField.stringValue)
                    if searched != ""{
                        return entry.message.contains(searched)
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
        self.entries=Bartleby.bprintCollection.entries
    }

    @IBAction func sendAReport(_ sender: AnyObject) {
    }
}

extension LogsViewController:PrintEntriesObserver{

    func receive(_ entry:PrintEntry){
        GlobalQueue.main.get().async { 
            self.entries.insert(entry, at: 0)
        }
    }
}

extension LogsViewController:NSTableViewDelegate{

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        guard let item = (self.arrayController.arrangedObjects as? NSArray)?.object(at:row) as? PrintEntry else {
            return 20
        }
        let width=self.messageColumn.width-80;
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.byCharWrapping;
        let attributes = [NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle] as [String : Any]
        let boundingBox = item.message.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        return boundingBox.height + 20
    }
}
