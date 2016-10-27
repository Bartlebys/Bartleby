//
//  MetricsDetailsViewController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 27/10/2016.
//
//

import Cocoa

class MetricsDetailsViewController: NSViewController,Editor,Identifiable{

    typealias EditorOf=Metrics

    var UID:String=Bartleby.createUID()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
