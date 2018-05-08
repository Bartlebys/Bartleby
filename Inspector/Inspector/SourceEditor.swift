//
//  SourceEditor.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 18/07/2016.
//
//

import BartlebyKit
import Cocoa

class SourceEditor: NSViewController, Editor {
    typealias EditorOf = ManagedModel

    var UID: String = Bartleby.createUID()

    override var nibName: NSNib.Name { return NSNib.Name("SourceEditor") }

    override var representedObject: Any? {
        didSet {
            _selectedItem = representedObject as? Collectible
            if let collection = self._selectedItem as? CollectibleCollection {
                enableEdition = false
                textView.string = "{\"numberOfItems\":\(collection.count)}"
            } else if _selectedItem is ManagedModel {
                let selectedJSON = _selectedItem!.toJSONString(true)
                textView.string = selectedJSON
                enableEdition = true
            } else if let unManagedModel = representedObject as? UnManagedModel {
                let selectedJSON = unManagedModel.toJSONString(true)
                enableEdition = false
                textView.string = selectedJSON
            }
        }
    }

    fileprivate var _selectedItem: Collectible?

    // MARK: Textual Edition

    @IBOutlet var textView: NSTextView! {
        didSet {
            textView.textColor = NSColor.white
        }
    }

    @IBOutlet var applyChangesButton: NSButton!

    @IBOutlet var editionLabel: NSTextField!

    @IBOutlet var textEditionZoneConstraint: NSLayoutConstraint!

    @objc fileprivate dynamic var enableEdition: Bool = false {
        didSet {
            self.textView.enabledTextCheckingTypes = 0
            if enableEdition == true {
                self.editionLabel.stringValue = NSLocalizedString("You can edit directly the JSON representation", tableName: "system", comment: "You can edit directly the JSON representation")
                self._animateEditionConstraint(34)
            } else {
                self._animateEditionConstraint(0)
            }
        }
    }

    fileprivate func _animateEditionConstraint(_ value: CGFloat) {
        if textEditionZoneConstraint.constant != value {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.2
                self.textEditionZoneConstraint.animator().constant = value
            }, completionHandler: {
            })
        }
    }

    @IBAction func applyChanges(_: AnyObject) {
        let newJsonString = textView.string
        if let data = newJsonString.data(using: String.Encoding.utf8), let selectedItem = self._selectedItem {
            let previousData = selectedItem.serialize()
            do {
                _ = try selectedItem.updateData(data, provisionChanges: true)
            } catch {
                do {
                    _ = try selectedItem.updateData(previousData, provisionChanges: true)
                } catch {
                    //
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
}
