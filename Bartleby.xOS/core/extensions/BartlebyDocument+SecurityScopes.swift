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


public enum SecurityScopedBookMarkError: Error {
    // Bookmarking
    case bookMarkFailed(message:String)
    // Scoped URL
    case getScopedURLRessourceFailed(message:String)
    case bookMarkIsStale
}


extension BartlebyDocument {

    // MARK: - API Security-Scoped Bookmarks Support

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


    ///
    ///Returns and acquires securized URL
    // If the Securiry scoped Bookmark does not exist, it creates one.
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
    public func acquireSecurizedURLFrom(originalURL: URL, appScoped: Bool=false) throws ->URL {
        if self._securityScopedBookmarkExits(originalURL, appScoped: false) {
            // The bookmark data exists
            let key=self._getBookMarkKeyFor(originalURL, appScoped: appScoped)
            if let securizedURL=self._activeSecurityBookmarks[key]{
                // The Url has already been acquired
                return securizedURL
            }else{
                if let idx=self.metadata.URLBookmarkData.index(where:{$0.key == key}){
                    //  Acquire the securized URL
                    let data=self.metadata.URLBookmarkData[idx].data
                    let securizedURL = try self._getSecurityScopedURLFrom(data)
                    self._startAccessingToSecurityScopedResourceAtURL(key,securizedURL)
                    return securizedURL
                }else{
                    throw SecurityScopedBookMarkError.getScopedURLRessourceFailed(message: "Void data when attempting to acquire securized URL")
                }
            }
        }else{
            // try to create and acquire
            let r = try self._bookmarkURL(originalURL, appScoped: false)
            // Return the securized url
            return r.securizedURL
        }
    }


    /// Release the access to the sandboxed securized URL
    /// Each acquireSecurizedURLFrom(...) must be balanced by releaseSecurizedUrl(...)
    ///
    /// - Parameters:
    ///   - originalURL: the original URL
    ///   - appScoped: is it an app scoped Bookmark?
    public func releaseSecurizedUrl(originalURL:URL,appScoped: Bool=false){
        if self._securityScopedBookmarkExits(originalURL,appScoped:appScoped ){
            let key=self._getBookMarkKeyFor(originalURL, appScoped: appScoped)
            self._stopAccessingToResourceIdentifiedBy(key)
        }else{
            self.log("Unable to release Bookmark for \(originalURL) appScoped: \(appScoped)", file: #file, function: #function, line: #line, category: Default.LOG_DEVELOPER_CATEGORY, decorative: false)
        }
    }


    //Stops to access to all the resources
    public func releaseAllSecurizedURLS() {
        for (key,_) in self._activeSecurityBookmarks{
            self._stopAccessingToResourceIdentifiedBy(key)
        }
    }

    /// Deletes a security scoped bookmark (e.g : when you delete a resource)
    /// And Release the resource.
    /// You do not need to call releaseSecurizedUrl(...)
    ///
    /// - Parameters:
    ///   - originalURL: the original URL
    ///   - appScoped: is it an app scoped Bookmark?
    public func deleteSecurityScopedBookmark(originalURL: URL, appScoped: Bool=false) {
        let key=self._getBookMarkKeyFor(originalURL, appScoped: appScoped)
        // Preventive stop
        self._stopAccessingToResourceIdentifiedBy(key)

        if let idx=self.metadata.URLBookmarkData.index(where:{ $0.key == key }){
            self.metadata.URLBookmarkData.remove(at: idx)
        }else{
            self.log("Unable to delete Bookmark for \(originalURL)", file: #file, function: #function, line: #line, category: Default.LOG_DEVELOPER_CATEGORY, decorative: false)
        }
    }

    /// Deletes all the bookmark data and releases all the accesses.
    public func deleteAllSecurityScopedBookmars() {
        self.metadata.URLBookmarkData=[KeyedData]()
        self.releaseAllSecurizedURLS()
    }


    /// Returns a description of the current bookmark
    public var bookmarksDescription:String{
        var description=""
        for keyedData in self.metadata.URLBookmarkData{
            if let s=String.init(data: keyedData.data, encoding: String.Encoding.utf8){
                description += "\(keyedData.key)=" + s + "\n"
            }
        }
        return description
    }


    //MARK: - Implementation


    ///   Creates and store for future usage a security scoped bookmark.
    ///
    /// - Parameters:
    ///   - url: the url to securize
    ///   - appScoped: if set to true it is an app-scoped bookmark else a document-scoped bookmark
    /// - Returns: a tupple with the key of the bookmark and the securized URL
    /// - Throws: SecurityScopedBookMarkError
    fileprivate func _bookmarkURL(_ url: URL, appScoped: Bool=false) throws ->(key:String,securizedURL:URL) {
        // Create the key
        let key = self._getBookMarkKeyFor(url, appScoped: appScoped)
        var data:Data?
        do {

            // The URL that the bookmark data will be relative to.
            // If you are creating a security-scoped bookmark to support App Sandbox, use this parameter as follows:
            //To create an app-scoped bookmark, use a value of nil.
            // To create a document-scoped bookmark, use the absolute path (despite this parameter’s name) to the document file that is to own the new security-scoped bookmark.

            #if os(OSX)
                data = try (url as URL).bookmarkData(options: URL.BookmarkCreationOptions.withSecurityScope,
                                                         includingResourceValuesForKeys:nil,
                                                         relativeTo: appScoped ? nil : ( self.fileURL ) )
            #else
                data = try url.bookmarkData(options: URL.BookmarkCreationOptions.suitableForBookmarkFile,
                                                includingResourceValuesForKeys: nil,
                                                relativeTo: appScoped ? nil : ( self.fileURL ))
                
            #endif

        } catch {
            throw SecurityScopedBookMarkError.bookMarkFailed(message: "\(error)")
        }

        if let data = data {

            // Store the keyedData
            let keyedData=KeyedData(key:key,data:data)
            self.metadata.URLBookmarkData.append(keyedData)

            // Prepare to return the key and the securized URL
            let securizedURL = try self._getSecurityScopedURLFrom(data)
            self._startAccessingToSecurityScopedResourceAtURL(key,securizedURL)
            self.hasChanged()

            // Return the tupple
            return (key, securizedURL)

        }else{
            throw SecurityScopedBookMarkError.bookMarkFailed(message: "Void data")
        }
    }



    fileprivate func _getBookMarkKeyFor(_ url: URL, appScoped: Bool=false) -> String {
        let path=url.path
        return"\(path)-\((appScoped ? "YES" : "NO" ))-\(self.UID)".sha1
    }


    /// Return the securizedURL from the data
    ///
    /// - Parameters:
    ///   - data: the bookMark data
    ///   - appScoped: if set to true it is an app-scoped bookmark else a document-scoped bookmark
    /// - Returns: the securizedURL
    /// - Throws: SecurityScopedBookMarkError
    internal func _getSecurityScopedURLFrom(_ data: Data, appScoped: Bool=false)throws -> URL {
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
    }


    internal func _securityScopedBookmarkExits(_ url: URL, appScoped: Bool=false) -> Bool {
        let key=self._getBookMarkKeyFor(url, appScoped: appScoped)
        let result=self.metadata.URLBookmarkData.contains(where:{$0.key == key})
        return result
    }


    /**
     Starts acessing to the securityScopedResource

     - parameter scopedUrl: the scopedUrl
     */
    fileprivate func _startAccessingToSecurityScopedResourceAtURL(_ key:String,_ scopedUrl: URL) {
        if !self._activeSecurityBookmarks.keys.contains(key){
            let _ = scopedUrl.startAccessingSecurityScopedResource()
            self._activeSecurityBookmarks[key]=scopedUrl
        }
    }


    /**
     Stops to access to securityScopedResource

     - parameter url: the url
     */

    fileprivate func _stopAccessingToResourceIdentifiedBy(_ key:String) {
        if self._activeSecurityBookmarks.keys.contains(key) {
            let scopedUrl=self._activeSecurityBookmarks[key]!
            scopedUrl.stopAccessingSecurityScopedResource()
            self._activeSecurityBookmarks.removeValue(forKey: key)
        }
    }
}
