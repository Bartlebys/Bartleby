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
    public static func suggestedProfiles(forDocument document:BartlebyDocument)->[Profile]{
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


    /// Take the information from the Document Current User 
    /// and synchronizes the identification and associated profiles.
    ///
    /// - Parameter document: the document
    public static func synchronize(_ document:BartlebyDocument){
        do{
            var identities=try Identities.loadFromKeyChain()
            /// Update the Masters users.
            var newUser=true
            let currentUser=document.currentUser
            let n=identities.identifications.count
            var identification:Identification?
            for i in 0..<n {
                identification=identities.identifications[i]
                if IdentitiesManager._matching(currentUser, identification!){
                    identification!.email=currentUser.email ?? ""
                    identification!.phoneNumber=currentUser.phoneNumber ?? ""
                    identification!.password=currentUser.password ?? Default.NO_PASSWORD
                    newUser=false
                }
            }

            if newUser{
                // Add the new identification
                identification=Identification()
                identification!.email=currentUser.email ?? ""
                identification!.phoneNumber=currentUser.phoneNumber ?? ""
                identification!.password=currentUser.password ?? Default.NO_PASSWORD
                identities.identifications.append(identification!)
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

            let relatedProfiles=identities.profiles.filter({ (profile) -> Bool in
                return _matching(currentUser, profile)
            })

            for profile in relatedProfiles{
                if profile.user?.email != identification!.email
                    || profile.user?.phoneNumber != identification!.phoneNumber
                    || profile.user?.password != identification!.password{
                    if let idx=identities.profiles.index(where: { (p) -> Bool in
                        return p.user?.UID == profile.user?.UID
                    }){
                        identities.profiles[idx].requiresSynchronization=true
                    }
                }
            }
            try identities.saveToKeyChain()
            IdentitiesManager._synchronize(identities: identities,with:currentUser,from:document)
        }catch{
            glog("\(error)", file: #file, function: #function, line: #line, category: Default.LOG_SECURITY, decorative: false)
        }
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

    // MARK: - Implementation


    /// Intents to patch the associatied identification with the new password
    /// There is no guarantee it will work as we may refer to various servers.
    fileprivate static func _synchronize(identities:Identities, with user:User,from document:BartlebyDocument){
        for profile in identities.profiles {
            if profile.requiresSynchronization{
                if let identification=identities.identifications.first(where: { (identification) -> Bool in
                    return IdentitiesManager._matching(user, identification)
                }){
                    IdentitiesManager._patch(profile, with: identification,from:document)
                }else{
                    glog("Matching Identification not found \(profile))", file: #file, function: #function, line: #line, category: Default.LOG_FAULT, decorative: false)
                }
            }
        }
    }


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

    fileprivate static func _patch(_ profile:Profile, with identification:Identification, from document:BartlebyDocument){

        func __cryptoPassword(_ identification:Identification )->String{
            let p=identification.password
            do{
                let encrypted=try Bartleby.cryptoDelegate.encryptString(p,useKey:Bartleby.configuration.KEY)
                return encrypted
            }catch{
                return  "CRYPTO_ERROR"
            }
        }

        func __patchHasSucceededOn(_ profile:Profile, with identification:Identification){
            // Recover the identification and profile.
            var profile = profile
            profile.user?.email=identification.email
            profile.user?.phoneNumber=identification.phoneNumber
            profile.user?.password=identification.password
            profile.user?.externalID=identification.externalID
            profile.requiresSynchronization=false
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
        }

        // STORE the password in  associated.lastPassword on success
        // Login then call PatchUser with the CryptoPassword, Email and PhoneNumber
        if let user=profile.user{
            user.referentDocument=document
            // Login with the previous credentials.
            user.login(sucessHandler: {
                // On success patch the user
                let cryptoPassword=__cryptoPassword(identification)
                PatchUser.execute(baseURL: profile.url,
                                  documentUID: profile.documentUID,
                                  userUID: profile.documentUID,
                                  cryptoPassword: cryptoPassword,
                                  email:identification.email ,
                                  phoneNumber: identification.phoneNumber,
                                  externalID: identification.externalID,
                                  sucessHandler:{ (context) in
                                    __patchHasSucceededOn(profile, with: identification)
                }, failureHandler: { (context) in
                    glog("User patch has failed \(context)", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
                })
            }, failureHandler: { (context) in
                glog("Not able to patch the user because the Login has failed \(context)", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
            })
        }
    }
    
}
