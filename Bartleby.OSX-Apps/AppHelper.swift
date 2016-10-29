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


    /// Returns a configured MetricsDetailsViewController
    ///
    /// - parameter metrics: the metrics to use.
    ///
    /// - returns: the MetricsDetailsViewController
    public static func getMetricsDetailsViewController(for metrics:Metrics)->MetricsDetailsViewController{
        let metricsViewController=MetricsDetailsViewController(nibName: "MetricsDetailsViewController", bundle:  Bundle(for: MetricsDetailsViewController.self))!
        metricsViewController.metrics=metrics
        return metricsViewController
    }


    /// Presents a popover with the last Metrics
    ///
    /// - parameter presenter: the presenter
    /// - parameter sender:    the sender for example a button
    /// - parameter document:  the document reference.
    public static func displayLastMetrics(presenter:NSViewController,sender:NSView,document:BartlebyDocument){
        let metrics=document.metrics
            if let lastMetrics=metrics.last{
                let metricsViewController=AppHelper.getMetricsDetailsViewController(for: lastMetrics)
                let frame = sender.frame
                presenter.presentViewController( metricsViewController,
                                            asPopoverRelativeTo: frame,
                                            of: presenter.view,
                                            preferredEdge:NSRectEdge(rawValue: 2)!,
                                            behavior: NSPopoverBehavior.transient)
            }
    }

}
