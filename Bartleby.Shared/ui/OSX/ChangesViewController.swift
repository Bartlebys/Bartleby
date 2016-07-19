//
//  ChangesViewController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 18/07/2016.
//
//

import Cocoa

class ChangesViewController: NSViewController,Editor,NSTableViewDataSource,NSTableViewDelegate,Identifiable{

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
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            })
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })

        }
    }

    private var _selectedItem:EditorOf?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.setDataSource(self)
       //self.tableView.setDelegate(self)
    }


    // MARK: NSTableViewDataSource

    func numberOfRowsInTableView(tableView: NSTableView) -> Int{
        return self._selectedItem?.changedKeys.count ?? 0
    }

    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject?{
        return self._selectedItem?.changedKeys[row]
    }

    /*

    // MARK: NSTableViewDelegate

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView?{

        guard let item =  self._selectedItem?.changedKeys[row] else {
            return nil
        }

        var image:NSImage?
        var text:String = ""
        var cellIdentifier: String = ""

        if tableColumn == tableView.tableColumns[0] {
            text = "\(floor(item.elapsed*1000)) ms"
            cellIdentifier = "ElapsedCell"
        } else if tableColumn == tableView.tableColumns[1] {
            text = item.key
            cellIdentifier = "KeyCell"
        } else if tableColumn == tableView.tableColumns[2] {
            text = item.changes
            cellIdentifier = "ChangesCell"
        }
        if let cell = tableView.makeViewWithIdentifier(cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            cell.imageView?.image = image ?? nil
            return cell
        }
        return nil
    }
*/


}
