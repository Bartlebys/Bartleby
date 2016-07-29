//
//  TriggersViewController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 15/07/2016.
//
//

import Cocoa

class TriggersViewController: NSViewController,RegistryDependent {

    internal var registryDelegate: RegistryDelegate?{
        didSet{
            if let document=self.registryDelegate?.getRegistry(){
               Bartleby.todo("...", message: document.UID)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
