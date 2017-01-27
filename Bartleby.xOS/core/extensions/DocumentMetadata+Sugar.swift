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


    /// Sugar one is Related to the master document (the document that creates sub-documents)
    /// == Part of The first 512 bytes of the sugar
    ///
    public var firstPieceOfSugar:String {
        get{
            return PString.substr(self.sugar, 0, 512)
        }
    }


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
    ///
    /// - Parameter superSugar: the super sugar is equal to firstPieceOfSugar
    public func cookThePie(superSugar:String="")throws{
        let _ = try FileManager.default.createDirectory(atPath: self._bowlPath, withIntermediateDirectories: true)
        if self.sugar == Default.VOID_STRING {
            do{
                try loadSugar()
            }catch{
                // Sugar not found or too salted
                // Let's generate a new one
                self.sugar=self._sweeten(superSugar)
            }
        }
        let cryptedSugar = try Bartleby.cryptoDelegate.encryptString(self.sugar, useKey: Bartleby.configuration.KEY)
        try cryptedSugar.write(toFile: self._bowlPath+"/"+self.persistentUID, atomically: true, encoding: String.Encoding.utf8)
    }



    /// Sugar pump
    ///
    /// - Parameter superSugar: the super sugar
    /// - Returns: return the sugar
    fileprivate func _sweeten(_ superSugar:String="")->String{
        // Sugar not found or too salted
        // Let's generate a new one
        var sweet=""
        /// Do we have a super sugar?
        if sweet.characters.count >= 512{
            sweet=PString.substr(superSugar, 0, 512)+Bartleby.randomStringWithLength(512)
        }else{
            sweet=Bartleby.randomStringWithLength(1024)
        }
        return sweet
    }


    /// Tries to put the sugar in the Bowl
    public func putSomeSugarInYourBowl() throws{
        // Create the bowl if necessary.
        let _ = try? FileManager.default.createDirectory(atPath: self._bowlPath, withIntermediateDirectories: true)
        // Before to put the sugar in your bowl
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

