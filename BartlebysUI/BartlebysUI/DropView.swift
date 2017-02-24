//
//  DropView.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 02/11/2016.
//


import Foundation
import Cocoa

extension Notification.Name {
    public struct DropView {
        /// Posted on dropped url if there not dropDelegate set
        /// The urls are passed in userInfos["urls"]
        public static let droppedUrls = Notification.Name(rawValue: "org.bartlebys.notification.DropView.droppedUrls")
    }
}



// The delegate that handles the droppedURLs
public protocol DropDelegate {

    /// Passes the validated URLs
    ///
    /// - Parameter urls: the URLs
    func droppedURLs(urls:[URL],dropZoneIdentifier:String)
}



// An View with Delegated Drop support
// You should setup dropDelegate,supportedUTTypes, and optionaly dropZoneIdentifier/Users/bpds/Desktop/Un gros insecte.mov
open class DropView:NSView{

    // MARK: Properties

    @IBInspectable
    open var backgroundColor: NSColor? {
        didSet {
            self.needsDisplay = true
        }
    }

    // MARK: Drawings

    open override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard let color = self.backgroundColor else {return}
        color.setFill()
        NSRectFill(self.bounds)
    }


    // You can specify a zone identifier
    public var dropZoneIdentifier:String=""

    // Should return for example: [kUTTypeMovie as String,kUTTypeVideo as String]
    public var supportedUTTypes:[String]?

    //If set to true the paths that are not matching the supportedUTTypes are excluded
    //else in case of unsupported UTTypes all the drop is cancelled
    public var filterIrreleventUTTypes:Bool=true

    // You setup the drop Delegate that will handle the URLs
    public var dropDelegate:DropDelegate?

    // Temp alpha storage
    private var _alphas=[Int:CGFloat]()

    // Active zone
    private var _active:Bool=false{
        didSet {
            //needsDisplay = true
            if _active==true{
                self.subviews.forEach({ (view) in
                    self._alphas[view.hashValue]=view.alphaValue
                    view.alphaValue=0.30
                })
            }else{
                self.subviews.forEach({ (view) in
                    view.alphaValue = self._alphas[view.hashValue] ?? 1.0
                })
                self._alphas.removeAll()
            }
        }
    }


    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.register(forDraggedTypes: [NSFilenamesPboardType, NSURLPboardType])
    }



    internal var _fileTypeAreOk = false

    internal var _droppedFilesPaths: [String]?{
        didSet{
            if let paths=_droppedFilesPaths{
                var urls=[URL]()
                for path in paths{
                    let url=URL(fileURLWithPath: path)
                    urls.append(url)
                }
                if let delegate=self.dropDelegate{
                    delegate.droppedURLs(urls: urls,dropZoneIdentifier:dropZoneIdentifier)
                }else{
                    let notification=Notification(name: Notification.Name.DropView.droppedUrls, object: nil, userInfo: ["urls":urls,"identifier":dropZoneIdentifier])
                    NotificationCenter.default.post(notification)
                }
            }
        }
    }

    override open func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if self._checkValidity(drag: sender) {
            self._fileTypeAreOk = true
            self._active = true
            return .copy
        } else {
            self._fileTypeAreOk = false
            self._active = false
            return []
        }
    }

    override open func draggingExited(_ sender: NSDraggingInfo?) {
        self._active = false
    }

    override open func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        if self._fileTypeAreOk {
            return .copy
        } else {
            return []
        }
    }

    override open func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if let paths = sender.draggingPasteboard().propertyList(forType: NSFilenamesPboardType) as? [String]{
            if self.filterIrreleventUTTypes==false{
                self._droppedFilesPaths = paths
            }else{
                // Filter the irrelevent paths
                var validPaths=[String]()
                for path in paths{
                    let url=URL(fileURLWithPath: path)
                    if self._isSupported(url){
                        validPaths.append(path)
                    }
                }
                self._droppedFilesPaths = validPaths
            }
            self._active = false
            return true
        }
        return false
    }


    private func _checkValidity(drag: NSDraggingInfo) -> Bool {
        if let paths = drag.draggingPasteboard().propertyList(forType: NSFilenamesPboardType) as? [String]{
            var isValid = (self.filterIrreleventUTTypes==true) ? false : true
            for path in paths{
                let url=URL(fileURLWithPath: path)
                if self.filterIrreleventUTTypes{
                    // Inclusive logic if there at least one valid element when consider the drop valid
                    isValid = isValid || self._isSupported(url)
                }else{
                    // Exclusive logic
                    isValid = isValid && self._isSupported(url)
                }
            }
            return isValid
        }
        return false
    }


    private func _isSupported(_ url:URL)->Bool{
        if let supportedUTTypes=self.supportedUTTypes{
            let pathExtension:CFString = url.pathExtension as CFString
            let unmanagedFileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, nil);
            if let fileUTI = unmanagedFileUTI?.takeRetainedValue(){
                for t in supportedUTTypes{
                    let cft:CFString = t as CFString
                    if UTTypeConformsTo(fileUTI,cft){
                        return true
                    }
                }
            }
        }
        return false
    }


}
