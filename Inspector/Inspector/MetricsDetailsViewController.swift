//
//  MetricsDetailsViewController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 27/10/2016.
//
//

import BartlebyKit
import Cocoa

open class MetricsDetailsViewController: NSViewController, Editor, Identifiable, NSSharingServiceDelegate {
    public typealias EditorOf = Metrics

    public var UID: String = Bartleby.createUID()

    open override var nibName: NSNib.Name { return NSNib.Name("MetricsDetailsViewController") }

    @objc dynamic var responseString: String?

    @objc dynamic var requestString: String?

    @objc open dynamic var arrayOfmetrics: [Metrics] = [Metrics]() {
        didSet {
            if let m = arrayOfmetrics.last {
                self.metrics = m
                _metricsIndex = arrayOfmetrics.count - 1
            }
        }
    }

    internal func _checkButtonAvailability() {
        if arrayOfmetrics.count > 0 {
            if _metricsIndex <= 0 {
                previousButton.isEnabled = false
            } else {
                previousButton.isEnabled = true
            }
            if _metricsIndex > arrayOfmetrics.count - 1 {
                nextButton.isEnabled = false
            } else {
                nextButton.isEnabled = true
            }
        } else {
            previousButton.isEnabled = false
            nextButton.isEnabled = false
        }
    }

    internal var _metricsIndex: Int = -1 {
        didSet {
            if _metricsIndex >= 0 {
                self.metrics = self.arrayOfmetrics[_metricsIndex]
                self.displayedIndex = "\(_metricsIndex + 1)"
            }
        }
    }

    @objc public dynamic var displayedIndex: String = "0"

    // The Selected Metrics
    // We are using using Bindings
    @objc internal dynamic var metrics: Metrics? {
        didSet {
            if let r = metrics?.httpContext?.responseString {
                responseString = r.jsonPrettify()
            } else {
                responseString = "no response"
            }
            if let request = metrics?.httpContext?.request {
                let data = try? JSON.prettyEncoder.encode(request)
                if let string = data?.optionalString(using: Default.STRING_ENCODING) {
                    requestString = string
                } else {
                    requestString = "decoding issue"
                }
            } else {
                requestString = "no request"
            }
        }
    }
    @IBOutlet var previousButton: NSButton!

    @IBOutlet var nextButton: NSButton!

    open override func viewDidAppear() {
        super.viewDidAppear()
        _checkButtonAvailability()
    }

    @IBAction func goPrevious(_: AnyObject) {
        let nextIndex = _metricsIndex - 1
        if nextIndex >= 0 {
            _metricsIndex = nextIndex
            metrics = arrayOfmetrics[nextIndex]
        }
        _checkButtonAvailability()
    }

    @IBAction func goNext(_: AnyObject) {
        let nextIndex = _metricsIndex + 1
        if nextIndex <= arrayOfmetrics.count - 1 {
            _metricsIndex = nextIndex
            metrics = arrayOfmetrics[nextIndex]
        }
        _checkButtonAvailability()
    }

    @IBOutlet var objectController: NSObjectController!

    @IBAction func copyAllToPasteBoard(_: Any) {
        var stringifyedMetrics = Default.NO_MESSAGE
        let data = try? JSON.prettyEncoder.encode(metrics)
        if let string = data?.optionalString(using: Default.STRING_ENCODING) {
            stringifyedMetrics = string
        }
        if stringifyedMetrics != Default.NO_MESSAGE {
            NSPasteboard.general.clearContents()
            let ns: NSString = stringifyedMetrics as NSString
            NSPasteboard.general.writeObjects([ns])
        }
    }

    @IBAction func copyToPasteBoard(_: AnyObject) {
        var stringifyedMetrics = Default.NO_MESSAGE
        let data = try? JSON.prettyEncoder.encode(arrayOfmetrics)
        if let string = data?.optionalString(using: Default.STRING_ENCODING) {
            stringifyedMetrics = string
        }
        if stringifyedMetrics != Default.NO_MESSAGE {
            NSPasteboard.general.clearContents()
            let ns: NSString = stringifyedMetrics as NSString
            NSPasteboard.general.writeObjects([ns])
        }
    }
}
