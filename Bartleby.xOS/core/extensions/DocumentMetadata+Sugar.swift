//
//  DocumentMetadata+Sugar.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 03/01/2017.
//
//

import Foundation

public enum SugarError: Error {
    case thereIsNoSugarInYouBowl
    case salted
}

public extension DocumentMetadata {
    /// Sugar one is Related to the master document (the document that creates sub-documents)
    /// == Part of The first 512 bytes of the sugar
    ///
    public var firstPieceOfSugar: String {
        return PString.substr(sugar, 0, 512)
    }

    /// Loads the sugar String and save it to self.sugar
    public func loadSugar() throws {
        // We gonna try to load
        if let data = FileManager.default.contents(atPath: self._bowlPath + "/" + self.persistentUID) {
            if let cryptedSugar = String(data: data, encoding: String.Encoding.utf8) {
                sugar = try Bartleby.cryptoDelegate.decryptString(cryptedSugar, useKey: Bartleby.configuration.KEY)
            } else {
                throw SugarError.salted
            }
        } else {
            throw SugarError.thereIsNoSugarInYouBowl
        }
    }

    /// Cooks a good pie
    ///
    /// - Parameter superSugar: the super sugar is equal to firstPieceOfSugar
    public func cookThePie(superSugar: String = "") throws {
        _ = try FileManager.default.createDirectory(atPath: _bowlPath, withIntermediateDirectories: true)
        if sugar == Default.NO_SUGAR {
            do {
                try loadSugar()
            } catch {
                // Sugar not found or too salted
                // Let's generate a new one
                sugar = _sweeten(superSugar)
            }
        }
        let cryptedSugar = try Bartleby.cryptoDelegate.encryptString(sugar, useKey: Bartleby.configuration.KEY)
        try cryptedSugar.write(toFile: _bowlPath + "/" + persistentUID, atomically: true, encoding: String.Encoding.utf8)
    }

    /// Sugar pump
    ///
    /// - Parameter superSugar: the super sugar
    /// - Returns: return the sugar
    fileprivate func _sweeten(_ superSugar: String = "") -> String {
        // Sugar not found or too salted
        // Let's generate a new one
        var sweet = ""
        /// Do we have a super sugar?
        if sweet.count >= 512 {
            sweet = PString.substr(superSugar, 0, 512) + Bartleby.randomStringWithLength(512)
        } else {
            sweet = Bartleby.randomStringWithLength(1024)
        }
        return sweet
    }

    /// Tries to put the sugar in the Bowl
    public func putSomeSugarInYourBowl() throws {
        // Create the bowl if necessary.
        _ = try? FileManager.default.createDirectory(atPath: _bowlPath, withIntermediateDirectories: true)
        // Before to put the sugar in your bowl
        let cryptedSugar = try Bartleby.cryptoDelegate.encryptString(sugar, useKey: Bartleby.configuration.KEY)
        try cryptedSugar.write(toFile: _bowlPath + "/" + persistentUID, atomically: true, encoding: String.Encoding.utf8)
    }

    // The sugar path
    fileprivate var _bowlPath: String {
        if appGroup != "" {
            if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: self.appGroup) {
                return url.path + "/bowl"
            }
        }
        if let document = self.document {
            return document.bsfs.baseFolderPath + "/bowl"
        }
        return "ERROR"
    }
}
