//
//  BartlebyDocument+SecurityScopes.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 05/05/2016.
//
//

import Foundation

#if os(OSX)
    import AppKit
#else
    import UIKit
#endif

//
// Simplified persistent Security Scoped Bookmarks
// This extension allows to acquire , store and release securized URLs
//
// Usage :
//
// 1. Call acquireSecurizedURLFrom(...) - The first call must be consecutive to an explicit user Intent.
// 2. Call releaseSecurizedUrl(...) when you want to release the resource
//
// Multiple consecutive call to acquireSecurizedURLFrom(..) counts for one call.
//
// If you need more information refer to:
// https://developer.apple.com/library/mac/documentation/Security/Conceptual/AppSandboxDesignGuide/AppSandboxInDepth/AppSandboxInDepth.html#//apple_ref/doc/uid/TP40011183-CH3-SW16
//

public enum SecurityScopedBookMarkError: Error {
    // Bookmarking
    case bookMarkFailed(message:String)
    // Scoped URL
    case getScopedURLRessourceFailed(message:String)
    case bookMarkIsStale
}


extension BartlebyDocument {

    // MARK: - API Security-Scoped Bookmarks support

    ///
    ///Returns and acquires securized URL
    // If the Securirty scoped Bookmark do not exists, it creates one.
    ///
    /// **IMPORTANT**
    /// 1. You must call this method after a user explicit intent (NSOpenPanel ...)
    ///    You cannot get security scoped bookmark for an arbritrary URL.
    /// 2. Don't forget : Each call should be balanced with a `releaseSecurizedUrl(..) ` call
    ///
    /// - Parameters:
    ///   - url: the url to be accessed
    ///   - appScoped: is it an app scoped Bookmark?
    /// - Returns: the Securized URL
    /// - Throws: errors
    public func acquireSecurizedURLFrom(_ url: URL, appScoped: Bool=false) throws ->URL {
        if !self._securityScopedBookmarkExits(url, appScoped: false) {
            let bookmarked = try self._bookmarkURL(url, appScoped: false)
            //Start acessing
            self._startAccessingToSecurityScopedResourceAtURL(bookmarked)
            return bookmarked
        } else {
            return try self._getSecurityScopedURLFrom(url, appScoped: false)
        }
    }


    /// Release the access to the sandboxed securized URL
    /// Each acquireSecurizedURLFrom(...) must be balanced by releaseSecurizedUrl(...)
    ///
    /// - Parameters:
    ///   - originalURL: the original URL
    ///   - appScoped: is it an app scoped Bookmark?
    public func releaseSecurizedUrl(_ originalURL:URL,appScoped: Bool=false){
        do {
            let securizedURL = try self._bookmarkURL(originalURL, appScoped: false)
            self._stopAccessingToSecurityScopedResourceAtURL(securizedURL)
        }catch{
            self.log("Unable to release Bookmark for \(error)", file: #file, function: #function, line: #line, category: Default.LOG_CATEGORY, decorative: false)
        }
    }


    /**
     Stops to access to all the security Scoped Resources
     */
    public func releaseAllSecurizedURLS() {
        while  let url = self._activeSecurityBookmarks.first {
            self._stopAccessingToSecurityScopedResourceAtURL(url as URL)
        }
    }

    ///  Deletes a security scoped bookmark (e.g : when you delete a resource)
    ///
    /// - Parameters:
    ///   - originalURL: the original URL
    ///   - appScoped: is it an app scoped Bookmark?
    public func deleteSecurityScopedBookmark(_ originalURL: URL, appScoped: Bool=false) {
        let key=_getBookMarkKeyFor(originalURL, appScoped: appScoped)
        if self.metadata.URLBookmarkData.keys.contains(key){
            self.metadata.URLBookmarkData.removeValue(forKey: key)
        }else{
            self.log("Unable to delete Bookmark for \(originalURL)", file: #file, function: #function, line: #line, category: Default.LOG_CATEGORY, decorative: false)
        }
    }


    //MARK: - Implementation


    /**
     Creates and store for future usage a security scoped bookmark.

     - parameter url:       the url
     - parameter appScoped: if set to true it is an app-scoped bookmark else a document-scoped bookmark

     - returns: return the security scoped resource URL
     */
    fileprivate func _bookmarkURL(_ url: URL, appScoped: Bool=false) throws -> URL {
        var shareData = try self._createDataFromBookmarkForURL(url, appScoped:appScoped)
        // Encode the bookmark data as a Base64 string.
        shareData=shareData.base64EncodedData(options: .endLineWithCarriageReturn)
        let stringifyedData=String(data: shareData, encoding: Default.STRING_ENCODING)
        let key=_getBookMarkKeyFor(url, appScoped: appScoped)
        self.metadata.URLBookmarkData[key]=stringifyedData as AnyObject?
        self.hasChanged()
        return try self._getSecurityScopedURLFrom(url)

    }

    fileprivate func _getBookMarkKeyFor(_ url: URL, appScoped: Bool=false) -> String {
        let path=url.path
        return"\(path)-\((appScoped ? "YES" : "NO" ))-\(self.UID)".sha1
    }

    /**
     Returns the URL on success

     - parameter url:             the url
     - parameter appScoped:       is it appScoped?

     - throws: throws value description

     - returns: the securized URL
     */
    internal func _getSecurityScopedURLFrom(_ url: URL, appScoped: Bool=false)throws -> URL {
        let key=self._getBookMarkKeyFor(url, appScoped: appScoped)
        if let stringifyedData=self.metadata.URLBookmarkData[key] as? String {
            if let base64EncodedData=stringifyedData.data(using: Default.STRING_ENCODING) {
                if let data=Data(base64Encoded: base64EncodedData, options: [.ignoreUnknownCharacters]) {
                    var bookmarkIsStale: Bool = false
                    do {
                        #if os(OSX)
                            let securizedURL = try URL(resolvingBookmarkData: data,
                                                          options: URL.BookmarkResolutionOptions.withSecurityScope, relativeTo:  appScoped ? nil : self.fileURL,
                                                          bookmarkDataIsStale: &bookmarkIsStale)
                        #else
                            let securizedURL = try URL(resolvingBookmarkData: data,
                                                         options: URL.BookmarkResolutionOptions.withoutUI, relativeTo:  appScoped ? nil : self.fileURL,
                                                         bookmarkDataIsStale: &bookmarkIsStale)
                        #endif
                        if (!bookmarkIsStale) {
                            return securizedURL!
                        } else {
                            throw SecurityScopedBookMarkError.bookMarkIsStale
                        }
                    } catch {
                        throw SecurityScopedBookMarkError.getScopedURLRessourceFailed(message: "Error \(error)")
                    }
                } else {
                    throw SecurityScopedBookMarkError.getScopedURLRessourceFailed(message:"Bookmark data Base64 decoding error")
                }
            } else {
                throw SecurityScopedBookMarkError.getScopedURLRessourceFailed(message:"Bookmark data deserialization error")
            }
        } else {
            throw SecurityScopedBookMarkError.getScopedURLRessourceFailed(message:"Unable to resolve bookmark for \(url) Did you bookmark that url?")
        }

    }


    internal func _securityScopedBookmarkExits(_ url: URL, appScoped: Bool=false) -> Bool {
        let key=_getBookMarkKeyFor(url, appScoped: appScoped)
        let result=self.metadata.URLBookmarkData.keys.contains(key)
        return result
    }



    fileprivate func _createDataFromBookmarkForURL(_ fileURL: URL, appScoped: Bool=false) throws -> Data {
        do {
            #if os(OSX)
                let data = try (fileURL as URL).bookmarkData(options: URL.BookmarkCreationOptions.withSecurityScope,
                                                               includingResourceValuesForKeys:nil,
                                                               relativeTo: appScoped ? nil : ( self.fileURL ) )
            #else
                let data =   try fileURL.bookmarkData(options: URL.BookmarkCreationOptions.suitableForBookmarkFile,
                                                      includingResourceValuesForKeys: nil,
                                                      relativeTo: appScoped ? nil : ( self.fileURL ))

            #endif
            // Extract of : https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/URL_Class/index.html#//apple_ref/occ/instm/URL/bookmarkDataWithOptions:includingResourceValuesForKeys:relativeToURL:error:
            // The URL that the bookmark data will be relative to.
            // If you are creating a security-scoped bookmark to support App Sandbox, use this parameter as follows:
            //To create an app-scoped bookmark, use a value of nil.
            // To create a document-scoped bookmark, use the absolute path (despite this parameter’s name) to the document file that is to own the new security-scoped bookmark.
            return data
        } catch {
            throw SecurityScopedBookMarkError.bookMarkFailed(message: "\(error)")
        }
    }

    /**
     Starts acessing to the securityScopedResource

     - parameter scopedUrl: the scopedUrl
     */
    fileprivate func _startAccessingToSecurityScopedResourceAtURL(_ scopedUrl: URL) {
        if self._activeSecurityBookmarks.index(of: scopedUrl)==nil {
            let _ = scopedUrl.startAccessingSecurityScopedResource()
            self._activeSecurityBookmarks.append(scopedUrl)
        }
    }


    /**
     Stops to access to securityScopedResource

     - parameter url: the url
     */
    fileprivate func _stopAccessingToSecurityScopedResourceAtURL(_ scopedUrl: URL) {
        if let idx=self._activeSecurityBookmarks.index(of: scopedUrl) {
            scopedUrl.stopAccessingSecurityScopedResource()
            self._activeSecurityBookmarks.remove(at: idx)
        }

    }
}
