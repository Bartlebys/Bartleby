//
//  DecryptorViewController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 29/10/2016.
//
//

import Cocoa
import BartlebyKit

class DecryptorViewController: NSViewController,AsyncDocumentProvider,PasterDelegate{

    override open var nibName : NSNib.Name { return NSNib.Name("DecryptorViewController") }

    @IBOutlet var cryptedTextView: NSTextView!

    var decryptView:DecryptView{
        get{
            return self.view as! DecryptView
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.decryptView.delegate=self
    }

    var decryptedString:String?

    // MARK: - AsyncDocumentProvider

    internal var _document=BartlebyDocument()

    internal var _consumers=[AsyncDocumentDependent]()

    func getDocument() -> BartlebyDocument?{
        return self._document
    }

    /// You can store document consumers
    /// To call `consumer.providerHasADocument()`
    /// - Parameter consumer: the document dependent consumer
    func addDocumentConsumer(consumer:AsyncDocumentDependent){
        _consumers.append(consumer)
    }

    // MARK: - PasterDelegate

    func pasted(){
        let p=NSPasteboard.general
        if let document = self.getDocument(){
            if let objects=p.readObjects(forClasses: [NSString.self], options: [:]) as? [String]{
                if let first=objects.first{
                    let c=first.components(separatedBy: AppHelper.copyFlag)
                    if c.count >= 3{
                        let crypted=c[1]
                        do {
                            // Let's decrypt the data
                            self.decryptedString = try Bartleby.cryptoDelegate.decryptString(crypted,useKey:Bartleby.configuration.KEY)
                            if let d=self.decryptedString?.data(using:.utf8){
                                let report:Report = try document.serializer.deserialize(d, register: false)
                                if let metadata=report.metadata{
                                    self._document.metadata=metadata
                                }
                                self._document.logs=report.logs
                                self._document.metrics=report.metrics
                                for c in self._consumers{
                                    c.providerHasADocument()
                                }
                                return // Everything seems ok

                            }
                        }catch{
                            glog("\(error)", file: #file, function: #function, line: #line, category: Default.LOG_SECURITY, decorative: false)
                        }
                    }
                }
            }
        }
        AppHelper.sharedInstance.unAvailableActionFeedBack()
    }
    
    
}
