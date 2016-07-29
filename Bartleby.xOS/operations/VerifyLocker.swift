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


public class VerifyLocker: JObject {

    // Universal type support
    override public class func typeName() -> String {
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
    public static  func execute( lockerUID: String,
                                inRegistry registryUID: String,
                                code: String,
                                accessGranted success:(locker: Locker)->(),
                                accessRefused failure:(context: JHTTPResponse)->()) {

        if let document=Bartleby.sharedInstance.getDocumentByUID(registryUID){
            // Let's determine if we should verify locally or not.
            let lockerRef=ExternalReference(iUID: lockerUID, iTypeName: Locker.typeName())
            let verifyer=VerifyLocker()
            lockerRef.fetchInstance(Locker.self) { (instance) in
                if let _=instance {
                    verifyer._proceedToLocalVerification(lockerUID, inRegistry:document.UID, code: code, accessGranted: success, accessRefused: failure)
                } else {
                    verifyer._proceedToDistantVerification(lockerUID, inRegistry:document.UID, code: code, accessGranted: success, accessRefused: failure)
                }
            }
        }else{
            let context = JHTTPResponse( code: 1,
                                         caller: "VerifyLocker.execute",
                                         relatedURL:NSURL(),
                                         httpStatusCode:417,
                                         response:nil,
                                         result:"{\"message\":\"Attempt to verify a locker out of a document\"}")
            failure(context:context)

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
    private  func _proceedToLocalVerification(  lockerUID: String,
                                                inRegistry registryUID: String,
                                                           code: String,
                                                           accessGranted success:(locker: Locker)->(),
                                                                         accessRefused failure:(context: JHTTPResponse)->()) {

        let context = JHTTPResponse( code: 900,
                                     caller: "VerifyLocker.proceedToLocalVerification",
                                     relatedURL:nil,
                                     httpStatusCode: 0,
                                     response: nil,
                                     result:nil)

        let lockerRef=ExternalReference(iUID: lockerUID, iTypeName: Locker.typeName())

        lockerRef.fetchInstance(Locker.self) { (instance) in
            if let locker=instance {
                locker.verificationMethod=Locker.VerificationMethod.Offline
                if locker.code==code {
                    self._verifyLockerBusinessLogic(locker, accessGranted: success, accessRefused: failure)
                } else {
                    context.code = 1
                    context.result="bad code"
                    failure(context:context)
                }

            } else {
                context.code = 2
                context.result="The locker do not exists locally"
                failure(context:context)
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
    private  func _proceedToDistantVerification( lockerUID: String,
                                                 inRegistry registryUID: String,
                                                            code: String,
                                                            accessGranted success:(locker: Locker)->(),
                                                                          accessRefused failure:(context: JHTTPResponse)->()) {

        if let document=Bartleby.sharedInstance.getDocumentByUID(registryUID){
            let pathURL=document.baseURL.URLByAppendingPathComponent("locker/verify")
            let dictionary: Dictionary<String, AnyObject>?=["lockerUID":lockerUID, "code":code]
            let urlRequest=HTTPManager.mutableRequestWithToken(inRegistry:document.UID, withActionName:"VerifyLocker", forMethod:"POST", and: pathURL)
            let r: Request=request(ParameterEncoding.JSON.encode(urlRequest, parameters: dictionary).0)
            r.responseString { response in

                let request=response.request
                let result=response.result
                let response=response.response

                // Bartleby consignation

                let context = JHTTPResponse( code: 901,
                    caller: "VerifyLocker.execute",
                    relatedURL:request?.URL,
                    httpStatusCode: response?.statusCode ?? 0,
                    response: response,
                    result:result.value)

                // React according to the situation
                var reactions = Array<Bartleby.Reaction> ()
                reactions.append(Bartleby.Reaction.Track(result: nil, context: context)) // Tracking

                if result.isFailure {
                    let m = NSLocalizedString("locker verification",
                        comment: "locker verification failure description")
                    let failureReaction =  Bartleby.Reaction.DispatchAdaptiveMessage(
                        context: context,
                        title: NSLocalizedString("Unsuccessfull attempt result.isFailure is true",
                            comment: "Unsuccessfull attempt"),
                        body:"\(m) httpStatus code = \(response?.statusCode ?? 0 ) | \(result.value)" ,
                        transmit: { (selectedIndex) -> () in
                    })
                    reactions.append(failureReaction)
                    failure(context:context)
                } else {
                    if let statusCode=response?.statusCode {
                        if 200...299 ~= statusCode {
                            if let instance = Mapper <Locker>().map(result.value) {
                                instance.verificationMethod=Locker.VerificationMethod.Online
                                self._verifyLockerBusinessLogic(instance, accessGranted: success, accessRefused: failure)
                            } else {
                                let failureReaction =  Bartleby.Reaction.DispatchAdaptiveMessage(
                                    context: context,
                                    title: NSLocalizedString("Deserialization issue",
                                        comment: "Deserialization issue"),
                                    body:"(result.value)",
                                    transmit: { (selectedIndex) -> () in
                                })
                                reactions.append(failureReaction)
                                failure(context:context)
                            }
                        } else {
                            // Bartlby does not currenlty discriminate status codes 100 & 101
                            // and treats any status code >= 300 the same way
                            // because we consider that failures differentiations could be done by the caller.
                            let m = NSLocalizedString("locker verification",
                                comment: "locker verification failure description")
                            let failureReaction =  Bartleby.Reaction.DispatchAdaptiveMessage(
                                context: context,
                                title: NSLocalizedString("Unsuccessfull attempt",
                                    comment: "Unsuccessfull attempt"),
                                body:"\(m) httpStatus code = \(statusCode) | \(result.value)" ,
                                transmit: { (selectedIndex) -> () in
                            })
                            reactions.append(failureReaction)
                            failure(context:context)
                        }
                    }
                }
                //Let's react according to the context.
                Bartleby.sharedInstance.perform(reactions, forContext: context)

            }

        }else{

            let context = JHTTPResponse( code: 1,
                                         caller: "VerifyLocker._proceedToDistantVerification",
                                         relatedURL:NSURL(),
                                         httpStatusCode:417,
                                         response:nil,
                                         result:"{\"message\":\"Attempt to verify a locker out of a document\"}")
            failure(context:context)
        }
    }


    private func _verifyLockerBusinessLogic( locker: Locker,
                                             accessGranted success:(locker: Locker)->(),
                                                           accessRefused failure:(context: JHTTPResponse)->()) {


        let context = JHTTPResponse( code: 902,
                                     caller: "VerifyLocker._verifyLockerBusinessLogic",
                                     relatedURL:nil,
                                     httpStatusCode: 0,
                                     response: nil,
                                     result:nil)



        if locker.verificationMethod==Locker.VerificationMethod.Offline {
            // Let find the current user
            if let spaceUID=locker.spaceUID {
                // 1. Verify the data space consistency
                if let registry=Bartleby.sharedInstance.getDocumentByUID(spaceUID) {
                    // 2. Verify the current user iUD
                    if let user=registry.registryMetadata.currentUser {
                        if user.UID == locker.userUID {
                            // 3. Verify the date
                            let referenceDate=NSDate()
                            if locker.startDate.compare(referenceDate)==NSComparisonResult.OrderedAscending
                                && locker.endDate.compare(referenceDate)==NSComparisonResult.OrderedDescending {
                                success(locker: locker)
                                return
                            } else {
                                context.result="The Date is not valid"
                                failure(context: context)
                                return
                            }

                        } else {
                            context.result="The current user is the natural recipient of locker"
                            failure(context: context)
                            return
                        }
                    } else {
                        context.result="There is no root user in the registry"
                        failure(context: context)
                        return
                    }
                } else {
                    context.result="SpaceUID is not valid"
                    failure(context: context)
                    return
                }
            } else {
                context.result="SpaceUID is not valid"
                failure(context: context)
                return
            }
        } else {
            //
        }
        context.result="Undefined failure"
        failure(context: context)
        return
        
        
        
    }
    
}
