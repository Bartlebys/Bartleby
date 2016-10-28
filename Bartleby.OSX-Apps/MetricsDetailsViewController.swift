//
//  MetricsDetailsViewController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 27/10/2016.
//
//

import Cocoa

open class MetricsDetailsViewController: NSViewController,Editor,Identifiable{


    public typealias EditorOf=Metrics

    public var UID:String=Bartleby.createUID()

    override open var nibName : String { return "MetricsDetailsViewController" }

    dynamic var responseString:String?

    dynamic var requestString:String?

    // Metrics are using Bindings
    dynamic open var metrics:Metrics?{
        didSet{
            if let r=metrics?.httpContext?.responseString{
                self.responseString=r.jsonPrettify()
            }else{
                self.responseString="no response"
            }
            if let request=metrics?.httpContext?.request{
                let formattedString=request.toJSONString(true)
                self.requestString=formattedString
            }else{
                self.requestString="no request"
            }
            let s=metrics?.toJSONString(true)
            Swift.print("\(s)")
        }
    }

    @IBOutlet var objectController: NSObjectController!

}
