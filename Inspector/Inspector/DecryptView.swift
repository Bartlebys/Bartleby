//
//  DecryptView.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 31/10/2016.
//
//

import BartlebyKit
import Cocoa

protocol PasterDelegate {
    func pasted()
}

class DecryptView: NSView {
    var delegate: PasterDelegate?

    // MARK: - First Responder

    override var acceptsFirstResponder: Bool { return true }

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

    @IBAction func cut(_: Any?) {
    }

    @IBAction func copy(_: Any?) {
    }

    @IBAction func paste(_: Any?) {
        delegate?.pasted()
    }
}
