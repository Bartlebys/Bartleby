//
//  ProgressWindowController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 09/08/2016.
//
//

import Cocoa


public class ProgressWindowController: NSWindowController,RegistryDependent {


    //MARK : Window

    override public func windowDidLoad() {
        super.windowDidLoad()
    }

    override public var windowNibName: String?{
        return "ProgressWindowController"
    }

    @IBOutlet var arrayController: NSArrayController!

    dynamic var tasksGroups:[TasksGroup]?

    public var registryDelegate: RegistryDelegate?{
        didSet{
            if let registry=self.registryDelegate?.getRegistry(){
                self.tasksGroups=registry.tasksGroups.items
            }
        }
    }
    
    
}