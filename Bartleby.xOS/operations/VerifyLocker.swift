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


open class VerifyLocker: BartlebyObject {

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
     - parameter documentUID:  the documentUID
     - parameter code:      the code
     - parameter success:   the sucess closure
     - parameter failure:   the failure closure
     */
    open static  func execute( _ lockerUID: String,
                               inDocumentWithUID documentUID: String,
                               code: String,
                               accessGranted success:@escaping (_ locker: Locker)->(),
                               accessRefused failure:@escaping (_ context: HTTPContext)->()) {

        if let document=Bartleby.sharedInstance.getDocumentByUID(documentUID){
            // Let's determine if we should verify locally or not.
            let lockerRef=ExternalReference(iUID: lockerUID, iTypeName: Locker.typeName())
            let verifyer=VerifyLocker()
            lockerRef.fetchInstance(Locker.self) { (instance) in
                if let _=instance {
                    verifyer._proceedToLocalVerification(lockerUID, inDocumentWithUID:document.UID, code: code, accessGranted: success, accessRefused: failure)
                } else {
                    verifyer._proceedToDistantVerification(lockerUID, inDocumentWithUID:document.UID, code: code, accessGranted: success, accessRefused: failure)
                }
            }
        }else{
            let context = HTTPContext( code: 1,
                                       caller: "VerifyLocker.execute",
                                       relatedURL:nil,
                                       httpStatusCode:417)
            context.responseString = "{\"message\":\"Attempt to verify a locker out of a document\"}"
            failure(context)

        }

    }

    /**
     Local verification

     - parameter lockerUID: lockerUID
     - parameter documentUID:  the UID of the space
     - parameter code:      code
     - parameter success:   success
     - parameter failure:   failure
     */
    fileprivate  func _proceedToLocalVerification(  _ lockerUID: String,
                                                    inDocumentWithUID documentUID: String,
                                                    code: String,
                                                    accessGranted success:@escaping (_ locker: Locker)->(),
                                                    accessRefused failure:@escaping (_ context: HTTPContext)->()) {

        let context = HTTPContext( code: 900,
                                   caller: "VerifyLocker.proceedToLocalVerification",
                                   relatedURL:nil,
                                   httpStatusCode: 0)

        let lockerRef=ExternalReference(iUID: lockerUID, iTypeName: Locker.typeName())

        lockerRef.fetchInstance(Locker.self) { (instance) in
            if let locker=instance {
                locker.verificationMethod=Locker.VerificationMethod.offline
                if locker.code==code {
                    self._verifyLockerBusinessLogic(locker, accessGranted: success, accessRefused: failure)
                } else {
                    context.code = 1
                    context.responseString = "bad code"
                    failure(context)
                }

            } else {
                context.code = 2
                context.responseString = "The locker do not exists locally"
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
                                                     inDocumentWithUID documentUID: String,
                                                     code: String,
                                                     accessGranted success:@escaping (_ locker: Locker)->(),
                                                     accessRefused failure:@escaping (_ context: HTTPContext)->()) {

        if let document=Bartleby.sharedInstance.getDocumentByUID(documentUID){
            let pathURL=document.baseURL.appendingPathComponent("locker/verify")
            let dictionary: Dictionary<String, AnyObject>?=["lockerUID":lockerUID as AnyObject, "code":code as AnyObject]
            let urlRequest=HTTPManager.requestWithToken(inDocumentWithUID:document.UID, withActionName:"VerifyLocker", forMethod:"POST", and: pathURL)
            do {
                let r=try JSONEncoding().encode(urlRequest,with:dictionary)
                request(r).validate().responseString(completionHandler: { (response) in

                    let request=response.request
                    let result=response.result
                    let timeline=response.timeline
                    let statusCode=response.response?.statusCode ?? 0

                    let metrics=Metrics()
                    metrics.operationName="VerifyLocker"
                    metrics.latency=timeline.latency
                    metrics.requestDuration=timeline.requestDuration
                    metrics.serializationDuration=timeline.serializationDuration
                    metrics.totalDuration=timeline.totalDuration
                    document.report(metrics)

                    let context = HTTPContext( code: 901,
                                               caller: "VerifyLocker.execute",
                                               relatedURL:request?.url,
                                               httpStatusCode: statusCode)
                    if let request=request{
                        context.request=HTTPRequest(urlRequest: request)
                    }

                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                        context.responseString=utf8Text
                    }

                    var reactions = Array<Reaction> ()
                    reactions.append(Reaction.track(result: nil, context: context)) // Tracking

                    if result.isFailure {
                        let m = NSLocalizedString("locker verification",
                                                  comment: "locker verification failure description")
                        let failureReaction =  Reaction.dispatchAdaptiveMessage(
                            context: context,
                            title: NSLocalizedString("Unsuccessfull attempt result.isFailure is true",
                                                     comment: "Unsuccessfull attempt"),
                            body:"\(m) httpStatus code = \(statusCode) | \(result.value)" ,
                            transmit: { (selectedIndex) -> () in
                        })
                        reactions.append(failureReaction)
                        failure(context)
                    } else {
                        if 200...299 ~= statusCode {
                            if let string=result.value{
                                if let instance = Mapper <Locker>().map(JSONString:string){
                                    success(instance)
                                }else{
                                    let failureReaction =  Reaction.dispatchAdaptiveMessage(
                                        context: context,
                                        title: NSLocalizedString("Deserialization issue",
                                                                 comment: "Deserialization issue"),
                                        body:"(result.value)",
                                        transmit:{ (selectedIndex) -> () in
                                    })
                                    reactions.append(failureReaction)
                                    failure(context)
                                }
                            }else{
                                let failureReaction =  Reaction.dispatchAdaptiveMessage(
                                    context: context,
                                    title: NSLocalizedString("No String Deserialization issue",
                                                             comment: "No String Deserialization issue"),
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
                            let failureReaction =  Reaction.dispatchAdaptiveMessage(
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

                    //Let's react according to the context.
                    document.perform(reactions, forContext: context)

                })
            }catch{
                let context = HTTPContext( code:2 ,
                                           caller: "VerifyLocker._proceedToDistantVerification",
                                           relatedURL:nil,
                                           httpStatusCode:500)
                context.responseString="{\"message\":\"\(error)}"
                failure(context)
            }

        }else{

            let context = HTTPContext( code: 1,
                                       caller: "VerifyLocker._proceedToDistantVerification",
                                       relatedURL:nil,
                                       httpStatusCode:417)
            context.responseString = "{\"message\":\"Attempt to verify a locker out of a document\"}"
            failure(context)
        }
    }


    fileprivate func _verifyLockerBusinessLogic( _ locker: Locker,
                                                 accessGranted success:(_ locker: Locker)->(),
                                                 accessRefused failure:(_ context: HTTPContext)->()) {


        let context = HTTPContext( code: 902,
                                   caller: "VerifyLocker._verifyLockerBusinessLogic",
                                   relatedURL:nil,
                                   httpStatusCode: 0)
        context.responseString = ""



        if locker.verificationMethod==Locker.VerificationMethod.offline {
            // Let find the current user
            if let documentUID=locker.documentUID {
                // 1. Verify the data space consistency
                if let document=Bartleby.sharedInstance.getDocumentByUID(documentUID) {
                    // 2. Verify the current user iUD
                    if let user=document.metadata.currentUser {
                        if user.UID == locker.userUID {
                            // 3. Verify the date
                            let referenceDate=Date()
                            if locker.startDate.compare(referenceDate)==ComparisonResult.orderedAscending
                                && locker.endDate.compare(referenceDate)==ComparisonResult.orderedDescending {
                                success(locker)
                                return
                            } else {
                                context.responseString="The Date is not valid"
                                failure(context)
                                return
                            }

                        } else {
                            context.responseString="The current user is the natural recipient of locker"
                            failure(context)
                            return
                        }
                    } else {
                        context.responseString="There is no root user in the document"
                        failure(context)
                        return
                    }
                } else {
                    context.responseString="documentUID is not valid"
                    failure(context)
                    return
                }
            } else {
                context.responseString="documentUID is not valid"
                failure(context)
                return
            }
        } else {
            //
        }
        context.responseString="Undefined failure"
        failure(context)
        return
        
    }
    
}
