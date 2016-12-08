//
//  Helper.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 28/10/2016.
//
//

import Foundation
import Cocoa
import BartlebyKit


public class AppHelper:NSObject,NSSharingServiceDelegate {

    open static let sharedInstance: AppHelper = {
        let instance = AppHelper()
        return instance
    }()


    public static var copyFlag="---------INCLUDE_THIS_LINE--------"


    /// Returns a configured MetricsDetailsViewController
    ///
    /// - parameter metrics: the array of metrics to use (we take the last one first)
    ///
    /// - returns: the MetricsDetailsViewController
    public func getMetricsDetailsViewController(for metrics:[Metrics])->MetricsDetailsViewController{
        let metricsViewController=MetricsDetailsViewController(nibName: "MetricsDetailsViewController", bundle:  Bundle(for: MetricsDetailsViewController.self))!
        metricsViewController.arrayOfmetrics=metrics
        return metricsViewController
    }


    /// Presents a popover with the last Metrics
    ///
    /// - parameter presenter: the presenter
    /// - parameter sender:    the sender for example a button
    /// - parameter document:  the document reference.
    public func displayLastMetrics(presenter:NSViewController,sender:NSView,document:BartlebyDocument){
        let metrics=document.metrics
        let metricsViewController=self.getMetricsDetailsViewController(for: metrics)
        let frame = sender.frame
        presenter.presentViewController( metricsViewController,
                                         asPopoverRelativeTo: frame,
                                         of: sender,
                                         preferredEdge:NSRectEdge(rawValue: 2)!,
                                         behavior: NSPopoverBehavior.transient)

    }



    /// Sends a report by Email
    ///
    /// - Parameters:
    ///   - document: the document to synthesize
    ///   - crypted: should the report be crypted?
    ///   - title: the title of the message
    ///   - body: the body (before the report)
    ///   - recipients: the recipient (comma separated emails)
    public func sendReport(document:BartlebyDocument,crypted:Bool=true,title:String="Report",body:String="", recipients:String=""){
        let report=Report()
        report.metadata=document.metadata
        report.logs=document.logs
        report.metrics=document.metrics
        let recipientsList=recipients.components(separatedBy: ",")
        if let  json = report.toJSONString(){
            if crypted{
                if let cryptedJson = try? Bartleby.cryptoDelegate.encryptString(json){
                    let string="\(body)\n\n\(AppHelper.copyFlag)\(cryptedJson)\(AppHelper.copyFlag)\n"
                    if let sharingService=NSSharingService.init(named: NSSharingServiceNameComposeEmail) {
                        sharingService.delegate=self
                        sharingService.subject=title
                        sharingService.recipients=recipientsList
                        sharingService.perform(withItems: [string])
                    } else {
                        return
                    }
                }
            }

        }

    }

    public func unAcceptableActionFeedBack(){
        NSSound(named:"Basso")?.play()
    }


    public func unAvailableActionFeedBack(){
        NSSound(named:"Basso")?.play()
    }


}
