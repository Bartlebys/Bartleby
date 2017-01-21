//
//  IdentitiesManager.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 29/12/2016.
//
//

import Foundation

/// We group the different Identities in the keyChain (Synchronized by iCloud )
/// It allows to patch the email, phone & password between multiple users in different DataSpaces.
///
/// Facts:
/// - One user operates in a unique DataSpace.
/// - A single user can be shared between multiple Document in the same DataSpace.
///
/// When various users share the the same phone or email in different dataspace
/// this class tries to synchronize the passwords, phone and email of matching users on all the registred collaborative servers.
public struct IdentitiesManager {


    /// Returns suggested profiles for the document.
    ///
    /// - Parameter document: the current document
    /// - Returns: the suggested profiles (can be used to propose a user account)
    public static func suggestedIdentifications(forDocument document:BartlebyDocument)->[Identification]{
        var identifications=[Identification]()
        let allProfiles=IdentitiesManager._suggestedProfiles(forDocument:document)
        for profile in allProfiles{
            if !identifications.contains(where: { (embeddedIdentification) -> Bool in
                let email = PString.trim(profile.user?.email ?? "")
                let phone = PString.trim(profile.user?.phoneNumber ?? "")
                if PString.trim(embeddedIdentification.email) == email &&
                    PString.trim(embeddedIdentification.phoneNumber) == phone {
                }
                return true
            }){
                var identification=Identification()
                identification.email=profile.user?.email ?? ""
                identification.phoneCountryCode=profile.user?.phoneCountryCode ?? ""
                identification.phoneNumber=profile.user?.phoneNumber ?? ""
                identification.password=profile.user?.password ?? Default.NO_PASSWORD
                identifications.append(identification)
            }
        }
        return identifications
    }


    /// Dumps the Identities founds in the key Chain
    public static func dumpKeyChainedProfiles(){
        if Bartleby.configuration.DEVELOPER_MODE{
            do{
                let identities=try Identities.loadFromKeyChain()
                for profile in identities.profiles{
                    glog("\(profile.toJSONString() ?? "NO PROFILE" )", file: #file, function: #function, line: #line, category: Default.LOG_SECURITY, decorative: false)
                }
            }catch{
                glog("\(error)", file: #file, function: #function, line: #line, category: Default.LOG_SECURITY, decorative: false)
            }
        }else{
            glog("Bartleby.configuration.DEVELOPER_MODE must be set to true to be able to dumpKeyChainedProfiles", file: #file, function: #function, line: #line, category: Default.LOG_SECURITY, decorative: false)
        }
    }



    /// - Parameter document: the document


    /// Take the information from the Document Current User
    /// and synchronizes the identification and associated profiles.
    /// the Completion status is success if the main user has been updated (there is no guarantee for the other profiles)
    /// each stored profile.user is modified in the key chain on success only.
    /// - Parameters:
    ///   - document: the concerned document
    ///   - completed: this closure is called when all the syndicable update has been executed.
    ///
    public static func synchronize(_ document:BartlebyDocument,completed:@escaping (Completion)->()){
        document.currentUser.login(sucessHandler: {
            UpdateUser.execute(document.currentUser, in: document.UID,
                               sucessHandler: { (context) in
                                // Mark as committed to prevent from re-upserting
                                document.currentUser.hasBeenCommitted()
                                do{
                                    try IdentitiesManager._syndicateProfiles(document)
                                    completed(Completion.successStateFromHTTPContext(context))
                                }catch{
                                    completed(Completion.failureStateFromError(error))
                                }
            }, failureHandler: { (context) in
                completed(Completion.failureStateFromHTTPContext(context))
            })

        }, failureHandler: { (context) in
            completed(Completion.failureStateFromHTTPContext(context))
        })
    }


    public static func profileMatching(identification:Identification, inDocument document:BartlebyDocument)->Profile?{
        let identities=try? Identities.loadFromKeyChain()
        if let profiles=identities?.profiles{
            for profile in profiles{
                if let user=profile.user{
                    if IdentitiesManager._matching(user,identification){
                        return profile
                    }
                }
            }
        }
        return nil
    }


    // MARK: - Suggestions


    /// Returns suggested profiles for the document.
    ///
    /// - Parameter document: the current document
    /// - Returns: the suggested profiles (can be used to propose a user account)
    fileprivate static func _suggestedProfiles(forDocument document:BartlebyDocument)->[Profile]{
        var profiles=[Profile]()
        do{
            let identities = try Identities.loadFromKeyChain()
            /// Try to find the better profile

            // Do we have already profiles with the same currentUser UID
            for profile in identities.profiles{
                if profile.user?.UID==document.currentUser.UID{
                    profiles.append(profile)
                }
            }
            if profiles.count>0{
                return profiles
            }

            // Do we have already profiles for this document
            for profile in identities.profiles{
                if profile.documentUID==document.UID{
                    profiles.append(profile)
                }
            }
            if profiles.count>0{
                return profiles
            }

            // Do we have already profiles in this dataspace
            for profile in identities.profiles{
                if profile.documentSpaceUID==document.spaceUID{
                    profiles.append(profile)
                }
            }
            if profiles.count>0{
                return profiles
            }

            // Do we have already a profiles on this server
            for profile in identities.profiles{
                if profile.url==document.baseURL{
                    profiles.append(profile)
                }
            }
            if profiles.count>0{
                return profiles
            }

            // Return all the profiles
            if identities.profiles.count>0{
                return identities.profiles
            }

        }catch{
            glog("\(error)", file: #file, function: #function, line: #line, category: Default.LOG_SECURITY, decorative: false)
        }
        return profiles
    }


    // MARK: - Syndication

    fileprivate static func _syndicateProfiles(_ document:BartlebyDocument) throws{
        var identities=try Identities.loadFromKeyChain()

        /// Update the Masters users.
        var newUser=true
        let currentUser=document.currentUser
        let n=identities.identifications.count
        var identification=Identification()
        for i in 0..<n {
            identification=identities.identifications[i]
            if IdentitiesManager._matching(currentUser, identification){
                if identification.supportsPasswordSyndication{
                    identification.email=currentUser.email ?? ""
                    identification.phoneCountryCode=currentUser.phoneCountryCode ?? ""
                    identification.phoneNumber=currentUser.phoneNumber ?? ""
                    identification.password=currentUser.password ?? Default.NO_PASSWORD
                    identification.externalID=currentUser.externalID ?? Default.NO_UID
                }
                newUser=false
            }
        }

        if newUser{
            identities.identifications.append(Identification.identificationFrom(user: currentUser))
        }

        if identities.profiles.contains(where: { (profile) -> Bool in
            return profile.user?.UID==currentUser.UID
        }){
            // We already have this user.
            // This is the current User
            // It will be Upserted normally.
        }else{
            // Add the user to the stored profiles.
            var profile=Profile()
            profile.documentUID=document.UID
            profile.documentSpaceUID=document.spaceUID
            profile.user=document.currentUser
            profile.url=document.baseURL
            identities.profiles.append(profile)
        }

        let currentUserIdentification=Identification.identificationFrom(user: currentUser)

        let relatedProfiles=identities.profiles.filter({ (profile) -> Bool in
            return _matching(currentUser, profile)
        })

        for profile in relatedProfiles{
            if profile.user?.email != currentUserIdentification.email
                || profile.user?.phoneNumber != currentUserIdentification.phoneNumber
                || profile.user?.password != currentUserIdentification.password{
                if let idx=identities.profiles.index(where: { (p) -> Bool in
                    return p.user?.UID == profile.user?.UID
                }){
                    identities.profiles[idx].requiresPatch=true
                }
            }
        }



        /// Intents to patch the associatied identification with the new password
        /// There is no guarantee it will work as we may refer to various servers.
        for profile in identities.profiles {
            if profile.requiresPatch{
                // We patch syndicated profiles only the document user has already been Updated.
                IdentitiesManager._patch(profile, with: currentUserIdentification,from:document)
            }
        }
    }


    fileprivate static func _patch(_ profile:Profile, with identification:Identification, from document:BartlebyDocument){
        var supportsPasswordSyndication=false
        if let user=profile.user{
            supportsPasswordSyndication=user.supportsPasswordSyndication
        }

        // We do patch user that explicitly accepts syndication
        if supportsPasswordSyndication == true && profile.user?.UID != document.currentUser.UID{

            func __patchHasSucceededOn(_ profile:Profile, with identification:Identification){
                // Recover the identification and profile.
                var profile = profile
                profile.user?.email=identification.email
                profile.user?.phoneNumber=identification.phoneNumber
                profile.user?.password=identification.password
                profile.user?.externalID=identification.externalID
                profile.requiresPatch=false
                do{
                    var identities=try Identities.loadFromKeyChain()
                    if let idx=identities.profiles.index(where: { (p) -> Bool in
                        return p.user?.UID == profile.user?.UID
                    }){
                        identities.profiles[idx]=profile
                    }
                    try identities.saveToKeyChain()
                }catch{
                    glog("\(error)", file: #file, function: #function, line: #line, category: Default.LOG_SECURITY, decorative: false)
                }

                if let user=profile.user{
                    if user.UID != document.currentUser.UID{
                        user.logout(sucessHandler: {
                        }, failureHandler: { (context) in
                            glog("Error on syndicaton logout \(context)", file: #file, function: #function, line: #line, category: Default.LOG_SECURITY, decorative: false)
                        })
                    }
                }

            }

            // STORE the password in  associated.lastPassword on success
            // Login then call PatchUser with the CryptoPassword, Email and PhoneNumber
            if let user=profile.user{
                user.referentDocument=document
                // Login with the previous credentials.
                user.login(sucessHandler: {
                    PatchUser.execute(baseURL: profile.url,
                                      documentUID: profile.documentUID,
                                      userUID: user.UID,
                                      cryptoPassword: user.cryptoPassword,
                                      sucessHandler:{ (context) in
                                        Async.main{
                                            __patchHasSucceededOn(profile, with: identification)
                                        }
                    }, failureHandler: { (context) in
                        // This may be normal if user.supportsPasswordSyndication == false
                        glog("User patch has failed \(context)", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
                    })
                }, failureHandler: { (context) in
                    glog("Not able to patch the user because the Login has failed \(context)", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
                })
            }
        }
    }



    // MARK: - Matchs finding


    fileprivate static func _matching(_ user:User,_ identification:Identification)->Bool{
        if let email=user.email{
            if PString.trim(email,characters:" \n-.")==PString.trim(identification.email,characters:" \n-."){
                return true
            }
        }
        if let phone=user.phoneNumber{
            if PString.trim(phone,characters:" \n-.")==PString.trim(identification.phoneNumber,characters:" \n-."){
                return true
            }
        }
        return false
    }

    fileprivate static func _matching(_ user:User,_ profile:Profile)->Bool{
        if user.UID == profile.user?.UID{
            return true
        }
        if let email=user.email, let profileEmail=profile.user?.email{
            if PString.trim(email,characters:" \n-.")==PString.trim(profileEmail,characters:" \n-."){
                return true
            }
        }
        if let phone=user.phoneNumber,let profilePhoneNumber=profile.user?.email{
            if PString.trim(phone,characters:" \n-.")==PString.trim(profilePhoneNumber,characters:" \n-."){
                return true
            }
        }
        return false
    }
    
    
    
    
}
