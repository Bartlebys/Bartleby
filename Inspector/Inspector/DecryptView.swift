//
//  DecryptView.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 31/10/2016.
//
//

import Cocoa

import BartlebyKit

protocol PasterDelegate {
    func pasted()
}

class DecryptView: NSView {

    var delegate:PasterDelegate?

    // MARK: - First Responder

    override var acceptsFirstResponder: Bool { return true  }

    override func becomeFirstResponder() -> Bool {
        return true
    }

    override func resignFirstResponder() -> Bool {
        return true
    }

    override var focusRingMaskBounds: NSRect {
        return bounds
    }


    // MARK: - Pasteboard

    @IBAction func cut(_ sender: Any?) {
    }

    @IBAction func copy(_ sender: Any?) {
    }

    @IBAction func paste(_ sender:Any?){
        delegate?.pasted()
    }

}
