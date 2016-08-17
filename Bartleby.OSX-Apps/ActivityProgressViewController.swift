//
//  ActivityProgressViewController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 16/08/2016.
//
//

import Cocoa

class ActivityProgressViewController: NSViewController ,RegistryDependent,Identifiable {

    var UID:String=Bartleby.createUID()

    dynamic var registry:BartlebyDocument?

    var registryDelegate: RegistryDelegate?{
        didSet{
            self.registry=self.registryDelegate?.getRegistry()
        }
    }


    // The tableView content is bound on the ArrayController.
    @IBOutlet weak var tableView: BXTableView! {
        didSet{
            if let registry=self.registryDelegate?.getRegistry(){
                registry.tasksGroups.tableView=self.tableView
            }
        }
    }

    // The array controller is bound on self.registry.tasksGroups.items
    @IBOutlet var arrayController: NSArrayController!{
        didSet{
            if let registry=self.registryDelegate?.getRegistry(){
                // Each CollectionController can be backed by an ArrayController.
                // This this the one for the tasksGroups
                registry.tasksGroupsArrayController=self.arrayController
            }
        }
    }


    override  func viewDidLoad() {
        super.viewDidLoad()
    }

    override  var nibName: String?{
        return "ActivityProgressViewController"
    }

    //MARK: -


    @IBAction func reload(sender: AnyObject) {
        self.tableView.reloadData()
    }

    
    @IBAction func createATestGroup(sender: AnyObject) {
        if let registry=self.registryDelegate?.getRegistry(){
                do{
                    // We taskGroupFor the task
                    let group=try Bartleby.scheduler.getTaskGroupWithName("Created Group \(registry.tasksGroups.items.count)", inDocument: registry)
                    group.priority=TasksGroup.Priority.Default
                    // 1 to 10 tasks.
                    let nbOfSimulatedTask=arc4random_uniform(9)+1
                    for i in 1...nbOfSimulatedTask {
                        let task=SimulatedTask(arguments:JString(from:"Task \(i)/\(i)"))
                        try group.appendChainedTask(task)
                    }
                    try group.start()
                }catch{
                    Bartleby.sharedInstance.presentVolatileMessage("We have encountered an exception", body: "\(error)")
                }
        }

    }

    

    // MARK: Filtering

    @IBAction func deleteGroup(sender: AnyObject) {
        print("\(sender)")
    }


}


// MARK: NSTableViewDataSource

/*

extension ActivityProgressViewController:NSTableViewDataSource{


    func numberOfRowsInTableView(tableView: NSTableView) -> Int{
        let nb=self.arrayController.arrangedObjects.count ?? 0
        bprint("CounterProg \(nb)",file:#file,function:#function,line:#line,category:"progression",decorative:false)
        return nb
    }

    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject?{
        let item = self.arrayController.arrangedObjects.objectAtIndex(row)
        bprint("Progression \(item)",file:#file,function:#function,line:#line,category:"progression",decorative:false)
        return item
    }


}

// MARK: NSTableViewDelegate

extension ActivityProgressViewController:NSTableViewDelegate{
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 60
    }
}


*/