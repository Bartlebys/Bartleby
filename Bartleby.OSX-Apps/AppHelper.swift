//
//  Helper.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 28/10/2016.
//
//

import Foundation
import Cocoa


public struct AppHelper {


    public static var copyFlag="---------INCLUDE_THIS_LINE--------"


    /// Returns a configured MetricsDetailsViewController
    ///
    /// - parameter metrics: the array of metrics to use (we take the last one first)
    ///
    /// - returns: the MetricsDetailsViewController
    public static func getMetricsDetailsViewController(for metrics:[Metrics])->MetricsDetailsViewController{
        let metricsViewController=MetricsDetailsViewController(nibName: "MetricsDetailsViewController", bundle:  Bundle(for: MetricsDetailsViewController.self))!
        metricsViewController.arrayOfmetrics=metrics
        return metricsViewController
    }


    /// Presents a popover with the last Metrics
    ///
    /// - parameter presenter: the presenter
    /// - parameter sender:    the sender for example a button
    /// - parameter document:  the document reference.
    public static func displayLastMetrics(presenter:NSViewController,sender:NSView,document:BartlebyDocument){
        let metrics=document.metrics
        let metricsViewController=AppHelper.getMetricsDetailsViewController(for: metrics)
        let frame = sender.frame
        presenter.presentViewController( metricsViewController,
                                         asPopoverRelativeTo: frame,
                                         of: sender,
                                         preferredEdge:NSRectEdge(rawValue: 2)!,
                                         behavior: NSPopoverBehavior.transient)

    }

}
