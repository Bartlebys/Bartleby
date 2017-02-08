//
//  BartlebyDocument+LifeCycle.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 08/02/2017.
//
//

import Foundation

/// This extension expose a comprehensive set of Document Notifications 
//  to adpat the behavior of your app to the document life cycle
/// You can observe those event in your controller to offer a consistent experience.
/// Normally your UI should be inactive until `Notification.Name.BartlebyDocument.isReady` has been posted.
/// BartlebyUI integrates a BaseViewController with notification relays.


public extension Notification.Name {

    public struct BartlebyDocument {

        /// The document current user has been created
        public static let currentUserHasBeenCreated = Notification.Name(rawValue: "org.bartlebys.notification.BartlebyDocument.currentUserHasBeenCreated")

        /// The user password has succeeded
        public static let passwordControlHasSucceed = Notification.Name(rawValue: "org.bartlebys.notification.BartlebyDocument.passwordControlHasSucceed")

        /// The user password has succeeded
        public static let passwordControlHasFailed = Notification.Name(rawValue: "org.bartlebys.notification.BartlebyDocument.passwordControlHasFailed")

        /// Data has been decrypted
        public static let dataDecryptionHasSucceed = Notification.Name(rawValue: "org.bartlebys.notification.BartlebyDocument.dataDecryptionHasSucceed")

        /// Data has not been decrypted
        public static let dataDecryptionHasFailed = Notification.Name(rawValue: "org.bartlebys.notification.BartlebyDocument.dataDecryptionHasFailed")

        /// The business logic is ready
        public static let isReady = Notification.Name(rawValue: "org.bartlebys.notification.BartlebyDocument.isReady")

    }

}


extension BartlebyDocument{


    public func notifyCurrentUserHasBeenCreated(){
        NotificationCenter.default.post(name:Notification.Name.BartlebyDocument.currentUserHasBeenCreated, object: self)
    }

    public func notifyPasswordControlHasSucceed(){
        NotificationCenter.default.post(name:Notification.Name.BartlebyDocument.passwordControlHasSucceed, object: self)
    }

    public func notifyPasswordControlHasFailed(){
        NotificationCenter.default.post(name:Notification.Name.BartlebyDocument.passwordControlHasSucceed, object: self)
    }

    public func notifyDataDecryptionHasSucceed(){
        NotificationCenter.default.post(name:Notification.Name.BartlebyDocument.dataDecryptionHasSucceed, object: self)
    }

    public func notifyDataDecryptionHasFailed(){
        NotificationCenter.default.post(name:Notification.Name.BartlebyDocument.dataDecryptionHasFailed, object: self)
    }

    public func notifyDocumentIsReady(){
        NotificationCenter.default.post(name:Notification.Name.BartlebyDocument.isReady, object: self)
    }

}
