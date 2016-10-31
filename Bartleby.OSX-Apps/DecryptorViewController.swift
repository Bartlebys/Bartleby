//
//  DecryptorViewController.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 29/10/2016.
//
//

import Cocoa
import ObjectMapper

class DecryptorViewController: NSViewController,AsyncDocumentProvider,PasterDelegate{

    override open var nibName : String { return "DecryptorViewController" }

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
        let p=NSPasteboard.general()
        if let objects=p.readObjects(forClasses: [NSString.self], options: [:]) as? [String]{
            if let first=objects.first{
                let c=first.components(separatedBy: AppHelper.copyFlag)
                if c.count >= 3{
                    let crypted=c[1]
                    // Let's decrypt the data
                    self.decryptedString = try? Bartleby.cryptoDelegate.decryptString(crypted)
                    if let d=self.decryptedString?.data(using:.utf8){
                        if let report:Report=JSerializer.deserialize(d) as? Report{
                            self._document.metadata=report.metadata
                            self._document.logs=report.logs
                            self._document.metrics=report.metrics
                            for c in self._consumers{
                                c.providerHasADocument()
                            }
                            return // Everything seems ok
                        }
                    }
                }
            }
        }
        NSSound(named:"Basso")?.play()
    }
    
    
}
