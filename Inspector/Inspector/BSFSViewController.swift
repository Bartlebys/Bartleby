//
//  BSFSViewController.swift
//  BartlebysInspector
//
//  Created by Benoit Pereira da silva on 31/01/2017.
//  Copyright © 2017 Bartlebys. All rights reserved.
//

import BartlebyKit
import Cocoa

class BSFSViewController: NSViewController, DocumentDependent, NSOutlineViewDelegate, NSOutlineViewDataSource {
    override var nibName: NSNib.Name { return NSNib.Name("BSFSViewController") }

    fileprivate var _document: BartlebyDocument?

    // MARK: - DocumentDependent

    internal var documentProvider: DocumentProvider? {
        didSet {
            if let documentReference = self.documentProvider?.getDocument() {
                _document = documentReference
            }
        }
    }

    func providerHasADocument() {}

    @IBOutlet var outlineView: NSOutlineView!

    // MARK: - life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        outlineView.delegate = self
        outlineView.dataSource = self
    }

    override func viewDidAppear() {
        super.viewDidAppear()
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
    }

    /// MARK : NSOutlineViewDelegate

    public func outlineView(_ outlineView: NSOutlineView, viewFor _: NSTableColumn?, item: Any) -> NSView? {
        if let document = self._document {
            if let object = item as? ManagedModel {
                if let casted = object as? Box {
                    let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "BoxCell"), owner: self) as! NSTableCellView
                    if let textField = view.textField {
                        textField.stringValue = "Box \(casted.UID) | Mounted:\(casted.isMounted)"
                    }
                    _configureInlineButton(view, object: casted)
                    return view
                } else if let casted = object as? Node {
                    let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NodeCell"), owner: self) as! NSTableCellView

                    if let textField = view.textField {
                        textField.stringValue = "\"\(casted.type)\" node \(casted.UID) | \(casted.relativePath) | \(casted.size / 1024)kB"

                        var exists = true
                        for block in casted.blocks {
                            if !document.blocksWrapper!.fileWrappers!.keys.contains(block.digest) {
                                exists = false
                                break
                            }
                        }
                        if exists {
                            textField.alphaValue = 1
                        } else {
                            textField.alphaValue = 0.3
                        }
                    }
                    _configureInlineButton(view, object: casted)
                    return view
                } else if let casted = object as? Block {
                    let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "BlockCell"), owner: self) as! NSTableCellView
                    if let textField = view.textField {
                        if let exists = document.blocksWrapper?.fileWrappers?.keys.contains(casted.digest) {
                            if exists {
                                textField.alphaValue = 1
                            } else {
                                textField.alphaValue = 0.3
                            }
                        }
                        textField.stringValue = "Block \(casted.UID) | \(casted.digest) | \(casted.size / 1024)kB"
                    }
                    _configureInlineButton(view, object: casted)
                    return view
                } else {
                    let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ObjectCell"), owner: self) as! NSTableCellView
                    if let textField = view.textField {
                        if let s = item as? String {
                            textField.stringValue = s
                        } else {
                            textField.stringValue = "Anomaly"
                        }
                    }
                    _configureInlineButton(view, object: item)
                    return view
                }
            }
        }
        return nil
    }

    fileprivate func _configureInlineButton(_ view: NSView, object: Any) {
        if let inlineButton = view.viewWithTag(2) as? NSButton {
            if let casted = object as? Box {
                let counter = casted.nodes.count
                inlineButton.isHidden = (counter == 0)
                inlineButton.title = "\(counter)"
                return
            } else if let casted = object as? Node {
                let counter = casted.blocks.count
                inlineButton.isHidden = (counter == 0)
                inlineButton.title = "\(counter)"
                return
            }

            inlineButton.isHidden = true
        }
    }

    /// MARK : NSOutlineViewDataSource

    public func outlineView(_: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let document = self._document {
            if item == nil {
                return document.boxes.count
            } else if let box = item as? Box {
                return box.nodes.count
            } else if let node = item as? Node {
                return node.blocks.count
            }
        }
        return 0
    }

    public func outlineView(_: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            if let document = self._document {
                return document.boxes[index]
            }
        } else if let box = item as? Box {
            return box.nodes[index]
        } else if let node = item as? Node {
            return node.blocks[index]
        }
        return "ERROR #\(index)"
    }

    public func outlineView(_: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let _ = item as? Block {
            return false
        }
        return true
    }
}
