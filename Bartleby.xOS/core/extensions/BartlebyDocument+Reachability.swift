//
//  BartlebyDocument+Reachability.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 25/10/2016.
//
//

import Foundation
#if !USE_EMBEDDED_MODULES
    import Alamofire
#endif

extension BartlebyDocument{


    /// Invokes The reachability endpoint
    ///
    /// - parameter callBack: transmits the async response
    func isReachable(_ callBack:@escaping (Bool)->()){
        HTTPManager.apiIsReachable(self.baseURL, successHandler: {
            callBack(true)
        }) { (r) in
            callBack(false)
        }
    }

    // Bartleby's Reachability url
    var reachabilityURL:URL{return self.baseURL.appendingPathComponent("/Reachable")}

    // Starts the reachability manager monitoring
    func startListeningReachability(){
        if let r=self._reachabilityManager{
            r.stopListening()
        }else{
             self._reachabilityManager=NetworkReachabilityManager(host: self.reachabilityURL.host!)
        }
        self._reachabilityManager?.listener = { status in

            Swift.print("Network Status Changed: \(status)")
            //let reachable=self._reachabilityManager!.isReachable

            if self.online{
                // What is the current transition state?
                switch self.metadata.transition {
                case .none:
                    break
                case .offToOn:
                    break
                case .onToOff:
                    break
                }
            }else{
                switch self.metadata.transition {
                case .none:
                    break
                case .offToOn:
                    break
                case .onToOff:
                    break
                }
            }
        }
        self._reachabilityManager?.startListening()
    }


    // Stops and destroys the reachability manager monitoring
    func stopListeningReachability(){
        self._reachabilityManager?.stopListening()
        self._reachabilityManager=nil
    }


    func transition(_ to:DocumentMetadata.Transition){
        if self.metadata.transition != to{
            self.metadata.transition=to
            switch to {
            case .none:
                // Final state.
                break
            case .offToOn:
                self._transitionFromOffToOn()
                break
            case .onToOff:
                 self._transitionFromOnToOff()
                break
            }
        }
    }

    fileprivate func _transitionFromOffToOn(){
        self.online=true
        self.startPushLoopIfNecessary()
    }

    fileprivate func _transitionFromOnToOff(){
        self.online=false
        self.destroyThePushLoop()
    }

}
