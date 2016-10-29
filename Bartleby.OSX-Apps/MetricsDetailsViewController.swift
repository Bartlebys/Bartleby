//
//  MetricsDetailsViewController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 27/10/2016.
//
//

import Cocoa

open class MetricsDetailsViewController: NSViewController,Editor,Identifiable,NSSharingServiceDelegate{


    public typealias EditorOf=Metrics

    public var UID:String=Bartleby.createUID()

    override open var nibName : String { return "MetricsDetailsViewController" }

    dynamic var responseString:String?

    dynamic var requestString:String?

    open var arrayOfmetrics:[Metrics]=[Metrics](){
        didSet{
            if let m=arrayOfmetrics.last{
                self.metrics=m
                _metricsIndex=arrayOfmetrics.count-1
            }
        }
    }

    internal func _checkButtonAvailability(){
        if arrayOfmetrics.count > 0{
            if _metricsIndex <= 0 {
                self.previousButton.isEnabled=false
            }else{
                self.previousButton.isEnabled=true
            }
            if _metricsIndex > arrayOfmetrics.count-1 {
                self.nextButton.isEnabled=false
            }else{
                self.nextButton.isEnabled=true
            }
        }else{
            previousButton.isEnabled=false
            nextButton.isEnabled=false
        }

    }

    internal var _metricsIndex:Int = -1{
        didSet{
            if _metricsIndex >= 0{
                self.metrics=self.arrayOfmetrics[_metricsIndex]
                self.displayedIndex="\(_metricsIndex+1)"
            }
        }
    }

    public dynamic var displayedIndex:String=""



    // The Selected Metrics
    // We are using using Bindings
    dynamic internal var metrics:Metrics?{
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
        }
    }
    @IBOutlet weak var previousButton: NSButton!

    @IBOutlet weak var nextButton: NSButton!


    open override func  viewDidAppear() {
        super.viewDidAppear()
        self._checkButtonAvailability()
    }

    @IBAction func goPrevious(_ sender: AnyObject) {
        let nextIndex=_metricsIndex-1
        if nextIndex >= 0{
            _metricsIndex=nextIndex
            self.metrics=self.arrayOfmetrics[nextIndex]
        }
        self._checkButtonAvailability()
    }

    @IBAction func goNext(_ sender: AnyObject) {
        let nextIndex=_metricsIndex+1
        if nextIndex <= self.arrayOfmetrics.count-1{
            self._metricsIndex=nextIndex
            self.metrics=self.arrayOfmetrics[nextIndex]
        }
        self._checkButtonAvailability()
    }


    @IBOutlet var objectController: NSObjectController!

    @IBAction func copyAllToPasteBoard(_ sender: Any) {
        if let c=metrics?.toJSONString(true){
            NSPasteboard.general().clearContents()
            let ns:NSString=c as NSString
            NSPasteboard.general().writeObjects([ns])
        }
    }



    @IBAction func copyToPasteBoard(_ sender: AnyObject) {
        if let c=arrayOfmetrics.toJSONString(prettyPrint: true){
            NSPasteboard.general().clearContents()
            let ns:NSString=c as NSString
            NSPasteboard.general().writeObjects([ns])
        }
    }

    @IBAction func sendAReportByMail(_ sender: Any) {
        self._sendReport(crypted: false)
    }


    @IBAction func sendCryptedReportByEmail(_ sender: Any) {
        self._sendReport(crypted: true)
    }


    func _sendReport(crypted:Bool){
        if let document=self.metrics?.document{
            var json = "{\"logs\":\"\(document.logs.toJSONString() ?? "")\",\"metadata\":\"\(document.metadata.toJSONString() ?? "")\",\"metrics\":\"\(document.metrics.toJSONString() ?? "")\"}"
            if crypted{
                if let cryptedJson = try? Bartleby.cryptoDelegate.encryptString(json){
                    json=cryptedJson
                }
            }
            json="\n\n---------\n\(json)\n------"
            if let sharingService=NSSharingService.init(named: NSSharingServiceNameComposeEmail) {
                sharingService.delegate=self
                sharingService.recipients=["bpds@me.com"]
                sharingService.perform(withItems: [json])
            } else {
                return
            }
        }
    }



    // MARK: OSX - NSSharingServiceDelegate
    func sharingService(_ sharingService: NSSharingService, didShareItems items: [AnyObject]) {
    }

    func sharingService(_ sharingService: NSSharingService, didFailToShareItems items: [AnyObject], error: NSError) {
    }


}