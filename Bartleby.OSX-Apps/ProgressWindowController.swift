//
//  ProgressWindowController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 03/08/2016.
//
//

import Cocoa

class ProgressWindowController: NSWindowController,RegistryDependent {


    override func windowDidLoad() {
        super.windowDidLoad()
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }


    dynamic var tasksGroups:[TasksGroup]?

    internal var registryDelegate: RegistryDelegate?{
        didSet{
            if let registry=self.registryDelegate?.getRegistry(){
                self.tasksGroups=registry.tasksGroups.items
            }
        }
    }

    
}
