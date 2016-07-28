//
//  ChangesViewController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 18/07/2016.
//
//

import Cocoa

@objc class ChangesViewController: NSViewController,Editor,Identifiable{

    typealias EditorOf=JObject

    var UID:String=Bartleby.createUID()


    @IBOutlet weak var tableView: NSTableView!
    
    override var representedObject: AnyObject?{
        willSet{
            if let _=self._selectedItem{
                self._selectedItem?.removeChangesObserver(self)
            }
        }
        didSet{
            self._selectedItem=representedObject as? EditorOf
            self._selectedItem?.addChangesObserver(self, closure: { (key, oldValue, newValue) in
                    self.tableView.reloadData()
            })
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
    }

    private dynamic var _selectedItem:EditorOf?

    override func viewDidLoad() {
        super.viewDidLoad()
    }


    override func viewDidAppear() {
        super.viewDidAppear()
        NSNotificationCenter.defaultCenter().addObserverForName(RegistryInspector.CHANGES_HAS_BEEN_RESET_NOTIFICATION, object: nil, queue: nil) { (notification) in
            self.tableView.reloadData()
        }
    }

    override func viewWillDisappear() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


}

extension ChangesViewController:NSTableViewDataSource{

    // MARK: NSTableViewDataSource

    func numberOfRowsInTableView(tableView: NSTableView) -> Int{
        let nb = self._selectedItem?.changedKeys.count ?? 0
        return nb
    }

    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        guard let item =  self._selectedItem?.changedKeys.reverse()[row] else {
            return 20
        }
        if item.changes.characters.count > 200 {
            return 100
        }
        return 20
    }
}


extension ChangesViewController:NSTableViewDelegate{

    // MARK: NSTableViewDelegate

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView?{

        guard let item =  self._selectedItem?.changedKeys.reverse()[row] else {
            return nil
        }
        var image:NSImage?
        var text:String = ""
        var cellIdentifier: String = ""

        if tableColumn == tableView.tableColumns[0] {
            text = "\(floor(item.elapsed)) s"
            cellIdentifier = "ElapsedCell"
        } else if tableColumn == tableView.tableColumns[1] {
            text = item.key
            cellIdentifier = "KeyCell"
        } else if tableColumn == tableView.tableColumns[2] {
            text = item.changes.stringByReplacingOccurrencesOfString("\n", withString: "")
            cellIdentifier = "ChangesCell"
        }
        if let cell = tableView.makeViewWithIdentifier(cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            cell.imageView?.image = image ?? nil
            return cell
        }
        return nil
    }

}
