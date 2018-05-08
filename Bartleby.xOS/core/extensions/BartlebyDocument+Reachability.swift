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

extension BartlebyDocument {
    /// Invokes The reachability endpoint
    ///
    /// - parameter callBack: transmits the async response
    func isReachable(_ callBack: @escaping (Bool) -> Void) {
        HTTPManager.apiIsReachable(baseURL, successHandler: {
            callBack(true)
        }) { _ in
            callBack(false)
        }
    }

    // Bartleby's Reachability url
    var reachabilityURL: URL { return baseURL.appendingPathComponent("/Reachable") }

    // Starts the reachability manager monitoring
    func startListeningReachability() {
        if let r = self._reachabilityManager {
            r.stopListening()
        } else {
            _reachabilityManager = NetworkReachabilityManager(host: reachabilityURL.host!)
        }
        _reachabilityManager?.listener = { status in

            Swift.print("Network Status Changed: \(status) \(#file)")
            // let reachable=self._reachabilityManager!.isReachable

            if self.online {
                // What is the current transition state?
                switch self.metadata.transition {
                case .none:
                    break
                case .offToOn:
                    break
                case .onToOff:
                    break
                }
            } else {
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
        _reachabilityManager?.startListening()
    }

    // Stops and destroys the reachability manager monitoring
    func stopListeningReachability() {
        _reachabilityManager?.stopListening()
        _reachabilityManager = nil
    }

    func transition(_ to: DocumentMetadata.Transition) {
        if metadata.transition != to {
            metadata.transition = to
            switch to {
            case .none:
                // Final state.
                break
            case .offToOn:
                _transitionFromOffToOn()
                break
            case .onToOff:
                _transitionFromOnToOff()
                break
            }
        }
    }

    fileprivate func _transitionFromOffToOn() {
        online = true
        startPushLoopIfNecessary()
    }

    fileprivate func _transitionFromOnToOff() {
        online = false
        destroyThePushLoop()
    }
}
