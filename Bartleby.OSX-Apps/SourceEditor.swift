//
//  SourceEditor.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 18/07/2016.
//
//

import Cocoa

class SourceEditor: NSViewController,Editor {

    typealias EditorOf=JObject

    var UID:String=Bartleby.createUID()

    override var representedObject: AnyObject?{
        didSet{
            self._selectedItem=representedObject as? Collectible
            if let collection = self._selectedItem as? CollectibleCollection{
                self.enableEdition=false
                self.textView.string="{\"numberOfItems\":\(collection.count)}"
            }else{
                self.enableEdition=true
                let selectedJSON=self._selectedItem!.toJSONString(true)
                self.textView.string=selectedJSON
            }
        }
    }

    fileprivate var _selectedItem:Collectible?

    //MARK: Textual Edition

    @IBOutlet var textView: NSTextView!{
        didSet{
            textView.textColor=NSColor.white
        }
    }

    @IBOutlet weak var applyChangesButton: NSButton!

    @IBOutlet weak var editionLabel: NSTextField!

    @IBOutlet weak var textEditionZoneConstraint: NSLayoutConstraint!


    fileprivate dynamic var enableEdition:Bool=false{
        didSet{
            self.textView.enabledTextCheckingTypes=0
            if enableEdition==true{
                self.editionLabel.stringValue=NSLocalizedString("You can edit directly the JSON representation", tableName:"system", comment: "You can edit directly the JSON representation")
                self._animateEditionConstraint(34)
            }else{
                self._animateEditionConstraint(0)
            }
        }
    }

    fileprivate func _animateEditionConstraint(_ value:CGFloat){
        if self.textEditionZoneConstraint.constant != value {
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration=0.2
                self.textEditionZoneConstraint.animator().constant=value
                }, completionHandler: {
            })
        }
    }

    @IBAction func applyChanges(_ sender: AnyObject) {
        let newJsonString=self.textView.string
        if let data=newJsonString?.data(using: String.Encoding.utf8), let selectedItem=self._selectedItem{
            let previousData=selectedItem.serialize()
            do{
                try selectedItem.updateData(data,provisionChanges: true)
            }catch{
                do {
                    try selectedItem.updateData(previousData,provisionChanges: true)
                }catch{
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

}
