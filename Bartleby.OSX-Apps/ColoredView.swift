//
//  ColoredView.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 28/07/2016.
//
//

import Cocoa

@IBDesignable
public class ColoredView: NSView {


    @IBInspectable public  var backgroundColor: NSColor? {
        get {
            if let colorRef = self.layer?.backgroundColor {
                return NSColor(CGColor: colorRef)
            } else {
                return nil
            }
        }
        set {
            self.wantsLayer = true
            self.layer?.backgroundColor = newValue?.CGColor
        }
    }

    override public func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
    }
    
}

