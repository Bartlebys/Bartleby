//
//  ColoredView.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 28/07/2016.
//
//

import Cocoa

@IBDesignable
open class ColoredView: NSView {


    @IBInspectable open  var backgroundColor: NSColor? {
        get {
            if let colorRef = self.layer?.backgroundColor {
                return NSColor(cgColor: colorRef)
            } else {
                return nil
            }
        }
        set {
            self.wantsLayer = true
            self.layer?.backgroundColor = newValue?.cgColor
        }
    }

    override open func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
}

