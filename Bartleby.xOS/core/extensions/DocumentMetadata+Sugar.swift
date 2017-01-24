//
//  DocumentMetadata+Sugar.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 03/01/2017.
//
//

import Foundation

public enum SugarError:Error{
    case thereIsNoSugarInYouBowl
    case salted
}

public extension DocumentMetadata{

    /// Loads the sugar String and save it to self.sugar
    public func loadSugar()throws{
        // We gonna try to load
        if let data=FileManager.default.contents(atPath: self._bowlPath+"/"+self.persistentUID){
            if let cryptedSugar = String.init(data: data, encoding: String.Encoding.utf8){
                self.sugar = try Bartleby.cryptoDelegate.decryptString(cryptedSugar, useKey: Bartleby.configuration.KEY)
            }else{
                throw SugarError.salted
            }
        }else{
            throw SugarError.thereIsNoSugarInYouBowl
        }
    }

    /// Cooks a good pie
    public func cookThePie()throws{
        let _ = try FileManager.default.createDirectory(atPath: self._bowlPath, withIntermediateDirectories: true)
        if self.sugar == Default.NO_UID {
            do{
                try loadSugar()
            }catch{
                // Sugar not found or too salted
                // Let's generate a new one
                self.sugar=Bartleby.randomStringWithLength(1024)
            }
        }
        let cryptedSugar = try Bartleby.cryptoDelegate.encryptString(self.sugar, useKey: Bartleby.configuration.KEY)
        try cryptedSugar.write(toFile: self._bowlPath+"/"+self.persistentUID, atomically: true, encoding: String.Encoding.utf8)
    }

    /// Tries to put the sugar in the Bowl
    public func putSomeSugarInYourBowl() throws{
        let cryptedSugar = try Bartleby.cryptoDelegate.encryptString(self.sugar, useKey: Bartleby.configuration.KEY)
        try cryptedSugar.write(toFile: self._bowlPath+"/"+self.persistentUID, atomically: true, encoding: String.Encoding.utf8)
    }


    // The sugar path
    fileprivate var _bowlPath:String{
        get{
            if self.appGroup != ""{
                if let url=FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: self.appGroup){
                    return url.path+"/bowl"
                }
            }
            return Bartleby.getSearchPath(.documentDirectory)!+"/bowl"
        }
    }
}

