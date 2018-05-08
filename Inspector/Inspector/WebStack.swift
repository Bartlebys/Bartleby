//
//  WebStack.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 28/07/2016.
//
//

import BartlebyKit
import Cocoa
import WebKit

class WebStack: NSViewController, DocumentDependent, WebFrameLoadDelegate {
    override var nibName: NSNib.Name { return NSNib.Name("WebStack") }

    @IBOutlet var webView: WebView! {
        didSet {
            webView.frameLoadDelegate = self
        }
    }

    fileprivate var URL: Foundation.URL?

    fileprivate var _loadingAttempted: Bool = false

    // MARK: - DocumentDependent

    var documentProvider: DocumentProvider? {
        didSet {
            if let document = self.documentProvider?.getDocument() {
                if let currentUser = document.metadata.currentUser {
                    URL = currentUser.signInURL(for: document)
                }
            }
        }
    }

    public func providerHasADocument() {}

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        if !_loadingAttempted {
            if let URL = self.URL {
                let r = URLRequest(url: URL)
                webView.mainFrame.load(r)
                _loadingAttempted = true
            }
        }
    }

    // Mark: - WebFrameLoadDelegate

    func webView(_: WebView!, didFailLoadWithError _: Error!, for _: WebFrame!) {
        _loadingAttempted = false
    }
}
