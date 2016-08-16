//
//  ProgressWindowController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 09/08/2016.
//
//

import Cocoa


public class ProgressWindowController: NSWindowController,RegistryDependent {

    @IBOutlet weak var tableView: NSTableView!

    override public func windowDidLoad() {
        super.windowDidLoad()
        self.window?.title=NSLocalizedString("Progress", tableName:"system", comment: "Progress window title")
        self.tableView.setDataSource(self)
        self.tableView.setDelegate(self)
    }

    override public var windowNibName: String?{
        return "ProgressWindowController"
    }

    //MARK: -

    @IBOutlet var arrayController: NSArrayController!

    dynamic var registry:BartlebyDocument?

    public var registryDelegate: RegistryDelegate?{
        didSet{
            self.registry=self.registryDelegate?.getRegistry()
            self.registry?.tasksArrayController=self.arrayController
        }
    }


    // MARK: Filtering

    private var _lockFilterUpdate=false

    @IBAction func didChange(sender: AnyObject) {
        self._updateFilter()
    }

    private func _updateFilter() -> () {
        if !self._lockFilterUpdate{
            let predicate=NSPredicate { (object, _) -> Bool in
                if let _ = object as? TasksGroup{
                }
                return true
            }
            self.arrayController.filterPredicate=predicate
        }
    }
}


// MARK: NSTableViewDataSource

extension ProgressWindowController:NSTableViewDataSource{

    public func numberOfRowsInTableView(tableView: NSTableView) -> Int{
        let nb=self.arrayController.arrangedObjects.count ?? 0
        return nb
    }

    public func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject?{
        let item = self.arrayController.arrangedObjects.objectAtIndex(row)
        return item
    }


}

// MARK: NSTableViewDelegate

extension ProgressWindowController:NSTableViewDelegate{

    public func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 60
    }
}

