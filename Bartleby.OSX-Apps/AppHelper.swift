//
//  Helper.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 28/10/2016.
//
//

import Foundation


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

}
