//
//  VerifyLocker.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 25/03/2016.
//
//

import Foundation
#if !USE_EMBEDDED_MODULES
    import Alamofire
    import ObjectMapper
#endif


open class VerifyLocker: JObject {

    // Universal type support
    override open class func typeName() -> String {
        return "VerifyLocker"
    }


    /**
     Proceed to verification

     Local or distant
     If the Locker as been grabbed its verificationMethod is set Automatically.
     (!) A Local locker must be added to the local locker collection before to be verifyed.

     - parameter lockerUID: the locker UID
     - parameter registryUID:  the registryUID
     - parameter code:      the code
     - parameter success:   the sucess closure
     - parameter failure:   the failure closure
     */
    open static  func execute( _ lockerUID: String,
                               inRegistryWithUID registryUID: String,
                               code: String,
                               accessGranted success:@escaping (_ locker: Locker)->(),
                               accessRefused failure:@escaping (_ context: JHTTPResponse)->()) {

        if let document=Bartleby.sharedInstance.getDocumentByUID(registryUID){
            // Let's determine if we should verify locally or not.
            let lockerRef=ExternalReference(iUID: lockerUID, iTypeName: Locker.typeName())
            let verifyer=VerifyLocker()
            lockerRef.fetchInstance(Locker.self) { (instance) in
                if let _=instance {
                    verifyer._proceedToLocalVerification(lockerUID, inRegistryWithUID:document.UID, code: code, accessGranted: success, accessRefused: failure)
                } else {
                    verifyer._proceedToDistantVerification(lockerUID, inRegistryWithUID:document.UID, code: code, accessGranted: success, accessRefused: failure)
                }
            }
        }else{
            let context = JHTTPResponse( code: 1,
                                         caller: "VerifyLocker.execute",
                                         relatedURL:nil,
                                         httpStatusCode:417,
                                         response:nil,
                                         result:"{\"message\":\"Attempt to verify a locker out of a document\"}")
            failure(context)

        }

    }

    /**
     Local verification

     - parameter lockerUID: lockerUID
     - parameter registryUID:  the UID of the space
     - parameter code:      code
     - parameter success:   success
     - parameter failure:   failure
     */
    fileprivate  func _proceedToLocalVerification(  _ lockerUID: String,
                                                    inRegistryWithUID registryUID: String,
                                                    code: String,
                                                    accessGranted success:@escaping (_ locker: Locker)->(),
                                                    accessRefused failure:@escaping (_ context: JHTTPResponse)->()) {

        let context = JHTTPResponse( code: 900,
                                     caller: "VerifyLocker.proceedToLocalVerification",
                                     relatedURL:nil,
                                     httpStatusCode: 0,
                                     response: nil,
                                     result:nil)

        let lockerRef=ExternalReference(iUID: lockerUID, iTypeName: Locker.typeName())

        lockerRef.fetchInstance(Locker.self) { (instance) in
            if let locker=instance {
                locker.verificationMethod=Locker.VerificationMethod.offline
                if locker.code==code {
                    self._verifyLockerBusinessLogic(locker, accessGranted: success, accessRefused: failure)
                } else {
                    context.code = 1
                    context.result="bad code"
                    failure(context)
                }

            } else {
                context.code = 2
                context.result="The locker do not exists locally"
                failure(context)
            }
        }
    }



    /**
     Server side (== distant) verification

     - parameter spaceUID:  spaceUID
     - parameter lockerUID: lockerUID
     - parameter code:      code
     - parameter success:   success
     - parameter failure:   failure
     */
    fileprivate  func _proceedToDistantVerification( _ lockerUID: String,
                                                     inRegistryWithUID registryUID: String,
                                                     code: String,
                                                     accessGranted success:@escaping (_ locker: Locker)->(),
                                                     accessRefused failure:@escaping (_ context: JHTTPResponse)->()) {

        if let document=Bartleby.sharedInstance.getDocumentByUID(registryUID){
            let pathURL=document.baseURL.appendingPathComponent("locker/verify")
            let dictionary: Dictionary<String, AnyObject>?=["lockerUID":lockerUID as AnyObject, "code":code as AnyObject]
            let urlRequest=HTTPManager.mutableRequestWithToken(inRegistryWithUID:document.UID, withActionName:"VerifyLocker", forMethod:"POST", and: pathURL)
            do {
                let r=try JSONEncoding().encode(urlRequest,with:dictionary) // ??? TO BE VALIDATED
                request(resource:r).validate().responseJSON(completionHandler: { (response) in


                    let request=response.request
                    let result=response.result
                    let response=response.response

                    // Bartleby consignation

                    let context = JHTTPResponse( code: 901,
                                                 caller: "VerifyLocker.execute",
                                                 relatedURL:request?.url,
                                                 httpStatusCode: response?.statusCode ?? 0,
                                                 response: response,
                                                 result:result.value)

                    // React according to the situation
                    var reactions = Array<Bartleby.Reaction> ()
                    reactions.append(Bartleby.Reaction.track(result: nil, context: context)) // Tracking

                    if result.isFailure {
                        let m = NSLocalizedString("locker verification",
                                                  comment: "locker verification failure description")
                        let failureReaction =  Bartleby.Reaction.dispatchAdaptiveMessage(
                            context: context,
                            title: NSLocalizedString("Unsuccessfull attempt result.isFailure is true",
                                                     comment: "Unsuccessfull attempt"),
                            body:"\(m) httpStatus code = \(response?.statusCode ?? 0 ) | \(result.value)" ,
                            transmit: { (selectedIndex) -> () in
                        })
                        reactions.append(failureReaction)
                        failure(context)
                    } else {
                        if let statusCode=response?.statusCode {
                            if 200...299 ~= statusCode {
                                if let instance = Mapper <Locker>().map(result.value) {
                                    instance.verificationMethod=Locker.VerificationMethod.online
                                    self._verifyLockerBusinessLogic(instance, accessGranted: success, accessRefused: failure)
                                } else {
                                    let failureReaction =  Bartleby.Reaction.dispatchAdaptiveMessage(
                                        context: context,
                                        title: NSLocalizedString("Deserialization issue",
                                                                 comment: "Deserialization issue"),
                                        body:"(result.value)",
                                        transmit: { (selectedIndex) -> () in
                                    })
                                    reactions.append(failureReaction)
                                    failure(context)
                                }
                            } else {
                                // Bartlby does not currenlty discriminate status codes 100 & 101
                                // and treats any status code >= 300 the same way
                                // because we consider that failures differentiations could be done by the caller.
                                let m = NSLocalizedString("locker verification",
                                                          comment: "locker verification failure description")
                                let failureReaction =  Bartleby.Reaction.dispatchAdaptiveMessage(
                                    context: context,
                                    title: NSLocalizedString("Unsuccessfull attempt",
                                                             comment: "Unsuccessfull attempt"),
                                    body:"\(m) httpStatus code = \(statusCode) | \(result.value)" ,
                                    transmit: { (selectedIndex) -> () in
                                })
                                reactions.append(failureReaction)
                                failure(context)
                            }
                        }
                    }
                    //Let's react according to the context.
                    Bartleby.sharedInstance.perform(reactions, forContext: context)

                })
            }catch{
                let context = JHTTPResponse( code:2 ,
                                             caller: "VerifyLocker._proceedToDistantVerification",
                                             relatedURL:nil,
                                             httpStatusCode:500,
                                             response:nil,
                                             result:"{\"message\":\"\(error)}")
                failure(context)
            }

        }else{

            let context = JHTTPResponse( code: 1,
                                         caller: "VerifyLocker._proceedToDistantVerification",
                                         relatedURL:nil,
                                         httpStatusCode:417,
                                         response:nil,
                                         result:"{\"message\":\"Attempt to verify a locker out of a document\"}")
            failure(context)
        }
    }


    fileprivate func _verifyLockerBusinessLogic( _ locker: Locker,
                                                 accessGranted success:(_ locker: Locker)->(),
                                                 accessRefused failure:(_ context: JHTTPResponse)->()) {


        let context = JHTTPResponse( code: 902,
                                     caller: "VerifyLocker._verifyLockerBusinessLogic",
                                     relatedURL:nil,
                                     httpStatusCode: 0,
                                     response: nil,
                                     result:nil)



        if locker.verificationMethod==Locker.VerificationMethod.offline {
            // Let find the current user
            if let registryUID=locker.registryUID {
                // 1. Verify the data space consistency
                if let registry=Bartleby.sharedInstance.getDocumentByUID(registryUID) {
                    // 2. Verify the current user iUD
                    if let user=registry.registryMetadata.currentUser {
                        if user.UID == locker.userUID {
                            // 3. Verify the date
                            let referenceDate=Date()
                            if locker.startDate.compare(referenceDate)==ComparisonResult.orderedAscending
                                && locker.endDate.compare(referenceDate)==ComparisonResult.orderedDescending {
                                success(locker)
                                return
                            } else {
                                context.result="The Date is not valid" as AnyObject?
                                failure(context)
                                return
                            }

                        } else {
                            context.result="The current user is the natural recipient of locker" as AnyObject?
                            failure(context)
                            return
                        }
                    } else {
                        context.result="There is no root user in the registry" as AnyObject?
                        failure(context)
                        return
                    }
                } else {
                    context.result="registryUID is not valid" as AnyObject?
                    failure(context)
                    return
                }
            } else {
                context.result="registryUID is not valid" as AnyObject?
                failure(context)
                return
            }
        } else {
            //
        }
        context.result="Undefined failure" as AnyObject?
        failure(context)
        return
        
        
        
    }
    
}
