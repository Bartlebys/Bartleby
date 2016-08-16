//
//  ActivityProgressViewController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 16/08/2016.
//
//

import Cocoa

public class ActivityProgressViewController: NSViewController ,RegistryDependent {

    @IBOutlet weak var tableView: NSTableView!

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.setDataSource(self)
        self.tableView.setDelegate(self)
    }

    override public var nibName: String?{
        return "ActivityProgressViewController"
    }

    //MARK: -

    @IBOutlet var arrayController: NSArrayController!

    dynamic var registry:BartlebyDocument?

    public var registryDelegate: RegistryDelegate?{
        didSet{
            if let registry=self.registryDelegate?.getRegistry(){
                self.registry=registry
                registry.tasksArrayController=self.arrayController
            }
        }
    }


    private var _createdTasksGroups=[TasksGroup]()

    @IBAction func createATestGroup(sender: AnyObject) {
        if let registry=self.registryDelegate?.getRegistry(){
            do{
                // We use the encapsulated SpaceUID
                let UID=registry.UID
                // We taskGroupFor the task
                let group=try Bartleby.scheduler.getTaskGroupWithName("Created Group \(_createdTasksGroups.count)", inDocument: registry)
                group.priority=TasksGroup.Priority.Default

                let nbOfSimulatedTask=arc4random_uniform(20)
                for i in 0...nbOfSimulatedTask {
                    let task=SimulatedTask(arguments:JString(from:"Task \(i)/\(_createdTasksGroups.count)"))
                    try group.appendChainedTask(task)
                }
                try group.start()
            }catch{
                // Silent catch
            }

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

extension ActivityProgressViewController:NSTableViewDataSource{

    public func numberOfRowsInTableView(tableView: NSTableView) -> Int{
        let nb=self.arrayController.arrangedObjects.count ?? 0
        bprint("CounterProg \(nb)",file:#file,function:#function,line:#line,category:"progression",decorative:false)
        return nb
    }

    public func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject?{
        let item = self.arrayController.arrangedObjects.objectAtIndex(row)
        bprint("Progression \(item)",file:#file,function:#function,line:#line,category:"progression",decorative:false)
        return item
    }


}

// MARK: NSTableViewDelegate

extension ActivityProgressViewController:NSTableViewDelegate{
    
    public func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 60
    }
}


