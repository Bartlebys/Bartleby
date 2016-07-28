//
//  WebStack.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 28/07/2016.
//
//

import Cocoa
import WebKit

class WebStack: NSViewController,RegistryDependent,WebFrameLoadDelegate {

    @IBOutlet weak var webView: WebView!{
        didSet{
            webView.frameLoadDelegate=self
        }
    }

    private var URL:NSURL?

    private var _loadingAttempted:Bool=false

    var registryDelegate: RegistryDelegate?{
        didSet{
            if let document=self.registryDelegate?.getRegistry(){
                self.URL=NSURL(string: document.baseURL.absoluteString.stringByReplacingOccurrencesOfString("/api/v1", withString: "")+"/signIn?spaceUID=\(document.spaceUID)&userUID=\(document.registryMetadata.currentUser!.UID)&password=\(document.registryMetadata.currentUser!.password)");
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }


    override func viewDidAppear() {
        super.viewDidAppear()
        if !self._loadingAttempted {
            if let URL=self.URL {
                let r=NSURLRequest(URL:URL)
                self.webView.mainFrame.loadRequest(r)
                self._loadingAttempted=true
            }
        }
    }

    // Mark: WebFrameLoadDelegate
    
    public func webView(sender: WebView!, didFailLoadWithError error: NSError!, forFrame frame: WebFrame!){
        self._loadingAttempted=false
    }

}
