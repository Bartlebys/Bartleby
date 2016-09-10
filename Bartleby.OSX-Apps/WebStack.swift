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

    fileprivate var URL:Foundation.URL?

    fileprivate var _loadingAttempted:Bool=false

    var registryDelegate: RegistryDelegate?{
        didSet{
            if let document=self.registryDelegate?.getRegistry(){
                if let currentUser=document.registryMetadata.currentUser{
                    let cryptoPassword:String = (try? Bartleby.cryptoDelegate.encryptString(currentUser.password)) ?? currentUser.password
                    self.URL=Foundation.URL(string: document.baseURL.absoluteString?.replacingOccurrences(of: "/api/v1", with: "")+"/signIn?spaceUID=\(document.spaceUID)&userUID=\(document.registryMetadata.currentUser!.UID)&password=\(cryptoPassword)");
                }
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
                let r=URLRequest(url:URL)
                self.webView.mainFrame.load(r)
                self._loadingAttempted=true
            }
        }
    }

    // Mark: WebFrameLoadDelegate
    
    func webView(_ sender: WebView!, didFailLoadWithError error: Error!, for frame: WebFrame!){
        self._loadingAttempted=false
    }

}
