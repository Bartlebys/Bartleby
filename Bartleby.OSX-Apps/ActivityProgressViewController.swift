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

    @IBOutlet weak var tableView: NSTableView!

    override  func viewDidLoad() {
        super.viewDidLoad()
    }

    override  var nibName: String?{
        return "ActivityProgressViewController"
    }

    //MARK: -

    @IBOutlet var arrayController: NSArrayController!{
        didSet{
            if let registry=self.registryDelegate?.getRegistry(){
                registry.tasksArrayController=self.arrayController
            }
        }
    }

    var registry:BartlebyDocument?

    var registryDelegate: RegistryDelegate?{
        didSet{
            if let registry=self.registryDelegate?.getRegistry(){
                self.registry=registry
                registry.tasksArrayController=self.arrayController
                /*
                self.registry?.tasksGroups.addChangesObserver(self, closure: { (key, oldValue, newValue) in
                    if let tableView = self.tableView{
                        tableView.reloadData()
                    }
                })*/
            }
        }
    }

    @IBAction func reload(sender: AnyObject) {
        self.tableView.reloadData()
    }

    // MARK: Filtering

    @IBAction func deleteGroup(sender: AnyObject) {
        print("\(sender)")
    }


}


// MARK: NSTableViewDataSource

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


