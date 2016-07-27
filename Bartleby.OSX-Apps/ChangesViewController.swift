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

}

extension ChangesViewController:NSTableViewDataSource{

    // MARK: NSTableViewDataSource

    func numberOfRowsInTableView(tableView: NSTableView) -> Int{
        let nb = self._selectedItem?.changedKeys.count ?? 0
        return nb
    }

    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject?{
        return self._selectedItem?.changedKeys[row]
    }

}


extension ChangesViewController:NSTableViewDelegate{

    // MARK: NSTableViewDelegate

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView?{

        guard let item =  self._selectedItem?.changedKeys[row] else {
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
