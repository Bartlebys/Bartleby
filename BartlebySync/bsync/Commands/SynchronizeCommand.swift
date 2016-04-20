//
//  SynchronizeCommand.swift
//  Bartleby's Sync client aka "bsync"
//
//  Created by Benoit Pereira da Silva on 06/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license

import Foundation

public class SynchronizeCommand:CommandBase{
    
    func executeCMD() {

        // Base options 
        
        let sourceURLString = StringOption(shortFlag: "s", longFlag: "source", required: true,
            helpMessage: "URL of the source folder")
        
        let destinationURLString = StringOption(shortFlag: "d", longFlag: "destination", required: true,
            helpMessage: "URL of the destination folder")
        
        let hashMapViewName = StringOption(shortFlag: "m", longFlag: "hashMapViewName",required: false,
            helpMessage: "The name of the optionnal hashMapView")
        
        let automaticTreesCreation = BoolOption(shortFlag: "a", longFlag: "automatic-trees-creation",required: false,
            helpMessage: "Creates automatically distant trees")
        
        // Help and verbosity
        
        let help = BoolOption(shortFlag: "h", longFlag: "help",required: false,
            helpMessage: "Prints a help message.")
        
        let verbosity = BoolOption(shortFlag: "v", longFlag: "verbose",required: false,
            helpMessage: "Print verbose messages.")
        
        // Barleby Authentication group of arguments
        // You can login and synchronize in one call.
        
        let email = StringOption(shortFlag: "e", longFlag: "email",required: false,
            helpMessage: "An email may be required for authentication.")
        let phoneNumber = StringOption(shortFlag: "n", longFlag: "phoneNumber",required: false,
                                 helpMessage: "An phoneNumber may be required for authentication.")
        let password = StringOption(shortFlag: "p", longFlag: "password",required: false,
            helpMessage: "An password may be required for authentication")
        let spaceUID = StringOption(shortFlag: "i", longFlag: "spaceUID",required: false,
            helpMessage: "A spaceUID may be required for authentication.")
        let sharedSalt = StringOption(shortFlag: "t", longFlag: "salt",required: false,
            helpMessage: "The salt used for authentication.")
        
        
        cli.addOptions( sourceURLString,
                        destinationURLString,
                        hashMapViewName,
                        automaticTreesCreation,
                        help,
                        verbosity,
                        email,
                        phoneNumber,
                        password,
                        spaceUID,
                        sharedSalt )
        
        do {
            try cli.parse()
            
            self.isVerbose=verbosity.value
            
            if email.wasSet || phoneNumber.wasSet || password.wasSet || spaceUID.wasSet || sharedSalt.wasSet {
                if (!email.wasSet  && !phoneNumber.wasSet) || !password.wasSet || !spaceUID.wasSet || !sharedSalt.wasSet{
                    print("")
                    print("When you setup an identifier email or phone number. You must setup a, password, spaceUID and a salt.")
                    print("Before to proceeding to synchronization \"bsync\" will proceed to authentication")
                    print("")
                    print("\temail was set = \(email.wasSet)")
                     print("\tphoneNumber was set = \(phoneNumber.wasSet)")
                    print("\tpassword was set = \(password.wasSet)")
                    print("\tspaceUID was set = \(spaceUID.wasSet)")
                    print("\tsharedSalt was set = \(sharedSalt.wasSet)")
                    print("")
                    exit(EX__BASE)
                }
            }
            
            guard let source=sourceURLString.value else{
                print("Nil source URL")
                exit(EX__BASE)
            }
            guard let sourceURL=NSURL(string: source) else{
                print("Invalid source URL \(source)")
                exit(EX__BASE)
            }
            guard  let destination=destinationURLString.value else{
                print("Nil destination URL")
                exit(EX__BASE)
            }
            
            guard let destinationURL=NSURL(string: destination) else{
                print("Invalid destination URL \(destination)")
                exit(EX__BASE)
            }
            
            self.synchronize( sourceURL,
                                            destinationURL: destinationURL,
                                            hashMapViewName: hashMapViewName.value,
                                            email: email.value,
                                            phoneNumber: phoneNumber.value,
                                            password: password.value,
                                            spaceUID: spaceUID.value,
                                            sharedSalt: sharedSalt.value,
                                            verbose:verbosity.value,
                                            autoCreateTrees:automaticTreesCreation.wasSet)
            
            
            
        } catch {
            cli.printUsage(error)
            exit(EX_USAGE)
        }
    }
    
    /**
     The synchronization implementation
     
     - parameter sourceURL:       the sourceURL
     - parameter destinationURL:  the destinationURL
     - parameter hashMapViewName: hashMapViewName
     - parameter email:           email
     - parameter phoneNumber      phoneNumber
     - parameter password:        password
     - parameter spaceUID:      spaceUID
     - parameter sharedSalt:      sharedSalt
     - parameter creativeKey :    creativeKey
     - parameter verbose :        verbose or not
     - parameter verbose :        autoCreateTrees or not
    
     
     */
    public func synchronize( sourceURL:NSURL,
                                destinationURL:NSURL,
                                hashMapViewName:String?,
                                email:String?,
                                phoneNumber:String?,
                                password:String?,
                                spaceUID:String?,
                                sharedSalt:String?,
                                verbose:Bool=true,
                                autoCreateTrees:Bool=false
        
        ){
                                        
        // Syncronization context
                                        
        let context=BsyncContext(   sourceURL: sourceURL,
                                    andDestinationUrl: destinationURL,
                                    restrictedTo: hashMapViewName,
                                    autoCreateTrees:autoCreateTrees
                                )
        
        context.credentials=BsyncCredentials()
        context.credentials?.spaceUID=spaceUID
        context.credentials?.salt=sharedSalt
        context.credentials?.email=email
        context.credentials?.phoneNumber=phoneNumber
        context.credentials?.password=password
            
        var url:NSURL?
        switch context.mode(){
        case BsyncMode.SourceIsDistantDestinationIsLocal:
            url=sourceURL
        case BsyncMode.SourceIsLocalDestinationIsDistant:
            url=destinationURL
        default:
            url=nil
        }
        // If there is an url let's determine the API base url.
        // it should be before baseAPI_URL/BartlebySync/tree/...
        // eg.: http://yd.local/api/v1/BartlebySync/tree/nameOfTree/
        
        if var stringURL=url?.absoluteString{
            let r=stringURL.rangeOfString("/BartlebySync")
            if let foundIndex=r?.startIndex{
                // extract the base URL
                url=NSURL(string: stringURL.substringToIndex(foundIndex))
            }
        }
    
        // Synchronization handler
        func doSync(){
            
                do {
                    let admin:BsyncAdmin=BsyncAdmin(context:context)
                    if self.progressBlock == nil {
                         self.addProgressBlock({ (taskIndex, totalTaskCount, taskProgress, message,nil) -> () in
                            if let m=message {
                                self.printVerbose(m)
                            }else{
                                self.printVerbose("\(taskIndex)/\(totalTaskCount) \(taskProgress)")
                            }
                         })
                    }
                    
                    if self.completionBlock == nil {
                        self.addcompletionBlock({ (success, message) -> () in
                            if success==true {
                                self.completion_EXIT(EX_OK,message:nil)
                                return
                            }else{
                                self.completion_EXIT(EX__BASE,message:message)
                                return
                            }
                        })
                    }
                    try admin.synchronizeWithprogressBlock(self.progressBlock!, completionBlock:self.completionBlock!)
                }catch{
                    self.completion_EXIT(EX__BASE,message:"An error has occured during synchronization: \(error)")
                    return
                }
            
        }
        
        if ((email != nil || phoneNumber != nil) && password != nil && spaceUID != nil && sharedSalt != nil) {
            
            if let apiBaseURL=url{
                
                // Bartleby should have be configured before.
                // We setup the default base url.
                
                Bartleby.configuration.API_BASE_URL=apiBaseURL
                Bartleby.sharedInstance.configureWith(Bartleby.configuration)
                let user=User()
                user.spaceUID=spaceUID!
                if let email=email{
                    user.email=email
                    user.verificationMethod = .ByEmail
                }
                else if let phoneNumber=phoneNumber{
                    user.phoneNumber=phoneNumber
                    user.verificationMethod = .ByPhoneNumber
                }
            
                LoginUser.execute(user, withPassword: password!, sucessHandler: {
                    print ("Successful login")
                    doSync()
                    }, failureHandler: { (context) in
                        // Print a JSON failure description
                        self.completion_EXIT(EX__BASE,message:"An error has occured during login: \(context.description)\n")
                        return
                })

            }else{
                doSync()
            }
            
        }else{
            doSync()
        }
    }
    
}