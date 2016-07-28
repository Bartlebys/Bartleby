//
//  LogsViewController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 15/07/2016.
//
//

import Cocoa

class LogsViewController: NSViewController,RegistryDependent{

    @IBOutlet weak var messageColumn: NSTableColumn!
    var font:NSFont=NSFont.systemFontOfSize(NSFont.smallSystemFontSize())

    private var _registry:BartlebyDocument?
    
    @IBOutlet weak var tableView: BXTableView!

    @IBOutlet weak var searchField: NSSearchField!

    @IBOutlet var arrayController: NSArrayController!

    @objc dynamic var entries=Bartleby.bprintCollection.entries

    private var _lockFilterUpdate=false


    // MARK: life Cycle

    internal var registryDelegate: RegistryDelegate?{
        didSet{
            if let registry=self.registryDelegate?.getRegistry(){
                self._registry=registry
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Bartleby.bPrintObservers.append(self)
        self.tableView.setDataSource(self)
        self.tableView.setDelegate(self)
    }


    override func viewDidAppear() {
        super.viewDidAppear()
        self._updateFilter()
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
    }

    deinit{
        if let idx=Bartleby.bPrintObservers.indexOf({ (observer) -> Bool in
            if let observer=observer as? LogsViewController{
                return observer == self
            }else{
                return false
            }
        }){
            Bartleby.bPrintObservers.removeAtIndex(idx)
        }
    }


    @IBAction func didChange(sender: AnyObject) {
        self._updateFilter()
    }
    
    // MARK: Filtering


    private func _updateFilter() -> () {
        if !self._lockFilterUpdate{
            let predicate=NSPredicate { (object, _) -> Bool in
                if let entry = object as? BprintEntry{
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

}

extension LogsViewController:BprintObserver{

    func acknowledge(entry:BprintEntry){
        dispatch_async(GlobalQueue.Main.get()) { 
            self.entries.insert(entry, atIndex: 0)
        }
    }
}


extension LogsViewController:NSTableViewDataSource{

    // MARK: NSTableViewDataSource

    func numberOfRowsInTableView(tableView: NSTableView) -> Int{
        return self.arrayController.arrangedObjects.count ?? 0
    }

    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject?{
        let item = self.arrayController.arrangedObjects.objectAtIndex(row)
        return item
    }


}

extension LogsViewController:NSTableViewDelegate{

    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {

        guard let item = self.arrayController.arrangedObjects.objectAtIndex(row) as? BprintEntry else {
            return 20
        }
        let width=self.messageColumn.width-80;
        let constraintRect = CGSize(width: width, height: CGFloat.max)
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByCharWrapping;
        let attributes = [NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle]
        let boundingBox = item.message.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: nil)
        return boundingBox.height + 20
    }
}




