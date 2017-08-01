//
//  ChangesViewController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 18/07/2016.
//
//

import Cocoa
import BartlebyKit

class ChangesViewController: NSViewController,Editor,Identifiable{

    typealias EditorOf=ManagedModel

    var UID:String=Bartleby.createUID()

    override var nibName : NSNib.Name { return NSNib.Name("ChangesViewController") }

    @IBOutlet weak var tableView: NSTableView!
    
    override var representedObject: Any?{
        willSet{
            if let _=self._selectedItem{
                self._selectedItem?.removeChangesSuperviser(self)
            }
        }
        didSet{
            self._selectedItem=representedObject as? EditorOf
            self._selectedItem?.addChangesSuperviser(self, closure: { (key, oldValue, newValue) in
                    self.tableView.reloadData()
            })
            Bartleby.syncOnMain{
                self.tableView.reloadData()
            }
        }
    }

    @objc fileprivate dynamic var _selectedItem:EditorOf?

    override func viewDidLoad() {
        super.viewDidLoad()
    }


    override func viewDidAppear() {
        super.viewDidAppear()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: DocumentInspector.CHANGES_HAS_BEEN_RESET_NOTIFICATION), object: nil, queue: nil) { (notification) in
            self.tableView.reloadData()
        }
    }

    override func viewWillDisappear() {
        NotificationCenter.default.removeObserver(self)
    }

    func itemForRow(_ row:Int)->KeyedChanges?{
        if let r:[KeyedChanges]=self._selectedItem?.changedKeys.reversed(){
            if r.count>row{
                return r[row]
            }
        }
        return nil
    }


}

extension ChangesViewController:NSTableViewDataSource{

    // MARK: NSTableViewDataSource

    func numberOfRows(in tableView: NSTableView) -> Int{
        let nb = self._selectedItem?.changedKeys.count ?? 0
        return nb
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        guard let item =  self.itemForRow(row) else {
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

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?{

        guard let item = self.itemForRow(row) else {
            return nil
        }
        var text:String = ""
        var cellIdentifier: String = ""

        if tableColumn == tableView.tableColumns[0] {
            text = "\(floor(item.elapsed)) s"
            cellIdentifier = "ElapsedCell"
        } else if tableColumn == tableView.tableColumns[1] {
            text = item.key
            cellIdentifier = "KeyCell"
        } else if tableColumn == tableView.tableColumns[2] {
            text = item.changes.replacingOccurrences(of: "\n", with: "")
            cellIdentifier = "ChangesCell"
        }
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            //cell.imageView?.image = image ?? nil
            return cell
        }
        return nil
    }

}
