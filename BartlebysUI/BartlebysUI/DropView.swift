//
//  DropView.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 02/11/2016.
//

import AppKit
import Foundation

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
    func droppedURLs(urls: [URL], dropZoneIdentifier: String)
}

// An View with Delegated Drop support
// You should setup dropDelegate,supportedUTTypes, and optionaly dropZoneIdentifier/Users/bpds/Desktop/Un gros insecte.mov
open class DropView: NSView {

    // MARK: Properties

    @IBInspectable
    open var backgroundColor: NSColor? {
        didSet {
            needsDisplay = true
        }
    }

    @IBInspectable
    open var highLightOnRollOver: Bool = true

    // MARK: Drawings

    open override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard let color = self.backgroundColor else { return }
        color.setFill()
        __NSRectFill(bounds)
    }

    // You can specify a zone identifier
    public var dropZoneIdentifier: String = ""

    // Should return for example: [kUTTypeMovie as String,kUTTypeVideo as String]
    public var supportedUTTypes: [String]?

    // If set to true the paths that are not matching the supportedUTTypes are excluded
    // else in case of unsupported UTTypes all the drop is cancelled
    public var filterIrreleventUTTypes: Bool = true

    // You setup the drop Delegate that will handle the URLs
    public var dropDelegate: DropDelegate?

    // Temp alpha storage
    private var _alphas = [Int: CGFloat]()

    // Active zone
    private var _active: Bool = false {
        didSet {
            if self.highLightOnRollOver {
                // needsDisplay = true
                if _active == true {
                    self.subviews.forEach({ view in
                        self._alphas[view.hashValue] = view.alphaValue
                        view.alphaValue = 0.30
                    })
                } else {
                    self.subviews.forEach({ view in
                        view.alphaValue = self._alphas[view.hashValue] ?? 1.0
                    })
                    self._alphas.removeAll()
                }
            }
        }
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([NSPasteboard.PasteboardType("NSFilenamesPboardType"), NSPasteboard.PasteboardType("NSFontPboardType")])
    }

    internal var _fileTypeAreOk = false

    internal var _droppedFilesPaths: [String]? {
        didSet {
            if let paths = _droppedFilesPaths {
                var urls = [URL]()
                for path in paths {
                    let url = URL(fileURLWithPath: path)
                    urls.append(url)
                }
                if let delegate = self.dropDelegate {
                    delegate.droppedURLs(urls: urls, dropZoneIdentifier: dropZoneIdentifier)
                } else {
                    let notification = Notification(name: Notification.Name.DropView.droppedUrls, object: self.window, userInfo: ["urls": urls, "identifier": dropZoneIdentifier])
                    NotificationCenter.default.post(notification)
                }
            }
        }
    }

    open override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if _checkValidity(drag: sender) {
            _fileTypeAreOk = true
            _active = true
            return .copy
        } else {
            _fileTypeAreOk = false
            _active = false
            return []
        }
    }

    open override func draggingExited(_: NSDraggingInfo?) {
        _active = false
    }

    open override func draggingUpdated(_: NSDraggingInfo) -> NSDragOperation {
        if _fileTypeAreOk {
            return .copy
        } else {
            return []
        }
    }

    open override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if let paths = sender.draggingPasteboard().propertyList(forType: NSPasteboard.PasteboardType("NSFilenamesPboardType")) as? [String] {
            if filterIrreleventUTTypes == false {
                _droppedFilesPaths = paths
            } else {
                // Filter the irrelevent paths
                var validPaths = [String]()
                for path in paths {
                    let url = URL(fileURLWithPath: path)
                    if _isSupported(url) {
                        validPaths.append(path)
                    }
                }
                _droppedFilesPaths = validPaths
            }
            _active = false
            return true
        }
        return false
    }

    private func _checkValidity(drag: NSDraggingInfo) -> Bool {
        if let paths = drag.draggingPasteboard().propertyList(forType: NSPasteboard.PasteboardType("NSFilenamesPboardType")) as? [String] {
            var isValid = (filterIrreleventUTTypes == true) ? false : true
            for path in paths {
                let url = URL(fileURLWithPath: path)
                if filterIrreleventUTTypes {
                    // Inclusive logic if there at least one valid element when consider the drop valid
                    isValid = isValid || _isSupported(url)
                } else {
                    // Exclusive logic
                    isValid = isValid && _isSupported(url)
                }
            }
            return isValid
        }
        return false
    }

    private func _isSupported(_ url: URL) -> Bool {
        if let supportedUTTypes = self.supportedUTTypes {
            let pathExtension: CFString = url.pathExtension as CFString
            let unmanagedFileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, nil)
            if let fileUTI = unmanagedFileUTI?.takeRetainedValue() {
                for t in supportedUTTypes {
                    let cft: CFString = t as CFString
                    if UTTypeConformsTo(fileUTI, cft) {
                        return true
                    }
                }
            }
        }
        return false
    }
}
