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


extension BartlebyDocument {

    public enum SecurityScopedBookMarkError: Error {
        // Bookmarking
        case bookMarkFailed(message:String)
        // Scoped URL
        case getScopedURLRessourceFailed(message:String)
        case bookMarkIsStale
    }
    // MARK: Security-Scoped Bookmarks support


    // https://developer.apple.com/library/mac/documentation/Security/Conceptual/AppSandboxDesignGuide/AppSandboxInDepth/AppSandboxInDepth.html#//apple_ref/doc/uid/TP40011183-CH3-SW16

    // After an explicit user intent
    // #1 scopedURL=getSecurizedURL(url, ... )
    // #2 startAccessingToSecurityScopedResourceAtURL(scopedURL)
    // ... use the resource
    // #3 stopAccessingToSecurityScopedResourceAtURL(scopedURL)


    /**

     Returns the securized URL
     If the Securirty scoped Bookmark do not exists, it creates one.
     You must call this method after a user explicit intent (NSOpenPanel ...)
     You cannot get security scoped bookmark for an arbritrary URL.

     NOTE : Don't forget that you must call startAccessingToSecurityScopedResourceAtURL(scopedURL) as soon as you use the URL, and stopAccessingToSecurityScopedResourceAtURL(scopedURL) as soon as you can release the resource.



     - parameter url:             the URL to be accessed
     - parameter appScoped:       appScoped description
     - parameter documentfileURL: documentfileURL description

     - throws: throws various exception (on creation, and or resolution)

     - returns: the securized URL
     */
    public func getSecurizedURL(_ url: URL, appScoped: Bool=false, documentfileURL: URL?=nil) throws ->URL {
        if self.securityScopedBookmarkExits(url, appScoped: false, documentfileURL:nil)==false {
            return try self.bookmarkURL(url, appScoped: false, documentfileURL:nil)
        } else {
            return try self.getSecurityScopedURLFrom(url, appScoped: false, documentfileURL:nil)
        }
    }

    /**
     Deletes a security scoped bookmark (e.g : when you delete a resource)

     - parameter url:             url description
     - parameter appScoped:       appScoped description
     - parameter documentfileURL: documentfileURL description
     */
    public func deleteSecurityScopedBookmark(_ url: URL, appScoped: Bool=false, documentfileURL: URL?=nil) {
        let key=_getBookMarkKeyFor(url, appScoped: appScoped, documentfileURL: documentfileURL)
        self.metadata.URLBookmarkData.removeValue(forKey: key)

    }

    /**
     Starts acessing to the securityScopedResource

     - parameter scopedUrl: the scopedUrl
     */
    public func startAccessingToSecurityScopedResourceAtURL(_ scopedUrl: URL) {
        let _ = scopedUrl.startAccessingSecurityScopedResource()
        if _activeSecurityBookmarks.index(of: scopedUrl)==nil {
            _activeSecurityBookmarks.append(scopedUrl)
        }
    }


    /**
     Stops to access to securityScopedResource

     - parameter url: the url
     */
    public func stopAccessingToSecurityScopedResourceAtURL(_ scopedUrl: URL) {
        scopedUrl.stopAccessingSecurityScopedResource()
        if let idx=_activeSecurityBookmarks.index(of: scopedUrl) {
            _activeSecurityBookmarks.remove(at: idx)
        }

    }



    /**
     Stops to access to all the security Scoped Resources
     */
    public func stopAccessingAllSecurityScopedResources() {
        while  let key = _activeSecurityBookmarks.first {
            stopAccessingToSecurityScopedResourceAtURL(key as URL)
        }
    }


    //MARK: Advanced interface (can be used in special context)

    /**
     Creates and store for future usage a security scoped bookmark.

     - parameter url:       the url
     - parameter appScoped: if set to true it is an app-scoped bookmark else a document-scoped bookmark
     - parameter documentfileURL :  the document file URL if not app scoped (you can create a bookmark for another document)

     - returns: return the security scoped resource URL
     */
    public func bookmarkURL(_ url: URL, appScoped: Bool=false, documentfileURL: URL?=nil) throws -> URL {
        var shareData = try self._createDataFromBookmarkForURL(url, appScoped:appScoped, documentfileURL:documentfileURL)
        // Encode the bookmark data as a Base64 string.
        shareData=shareData.base64EncodedData(options: .endLineWithCarriageReturn)
        let stringifyedData=String(data: shareData, encoding: Default.STRING_ENCODING)
        let key=_getBookMarkKeyFor(url, appScoped: appScoped, documentfileURL: documentfileURL)
        self.metadata.URLBookmarkData[key]=stringifyedData as AnyObject?
        self.hasChanged()
        return try getSecurityScopedURLFrom(url)

    }

    fileprivate func _getBookMarkKeyFor(_ url: URL, appScoped: Bool=false, documentfileURL: URL?=nil) -> String {
        let path=url.path
        return CryptoHelper.hashString("\(path)-\((appScoped ? "YES" : "NO" ))-\(documentfileURL?.path ?? Default.NO_PATH ))")
    }

    /**
     Returns the URL on success

     - parameter url:             the url
     - parameter appScoped:       is it appScoped?
     - parameter documentfileURL: the document file URL if not app scoped

     - throws: throws value description

     - returns: the securized URL
     */
    public func getSecurityScopedURLFrom(_ url: URL, appScoped: Bool=false, documentfileURL: URL?=nil)throws -> URL {
        let key=_getBookMarkKeyFor(url, appScoped: appScoped, documentfileURL: documentfileURL)
        if let stringifyedData=self.metadata.URLBookmarkData[key] as? String {
            if let base64EncodedData=stringifyedData.data(using: Default.STRING_ENCODING) {
                if let data=Data(base64Encoded: base64EncodedData, options: [.ignoreUnknownCharacters]) {
                    var bookmarkIsStale: Bool = false
                    do {
                        #if os(OSX)
                            let securizedURL = try URL(resolvingBookmarkData: data,
                                                          options: URL.BookmarkResolutionOptions.withSecurityScope, relativeTo:  appScoped ? nil : (documentfileURL ?? self.fileURL),
                                                          bookmarkDataIsStale: &bookmarkIsStale)
                        #else
                            let securizedURL = try URL(resolvingBookmarkData: data,
                                                         options: URL.BookmarkResolutionOptions.withoutUI, relativeTo:  appScoped ? nil : (documentfileURL ?? self.fileURL),
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


    public func securityScopedBookmarkExits(_ url: URL, appScoped: Bool=false, documentfileURL: URL?=nil) -> Bool {
        let key=_getBookMarkKeyFor(url, appScoped: appScoped, documentfileURL: documentfileURL)
        let result=self.metadata.URLBookmarkData.keys.contains(key)
        return result

    }



    fileprivate func _createDataFromBookmarkForURL(_ fileURL: URL, appScoped: Bool=false, documentfileURL: URL?) throws -> Data {
        do {
            #if os(OSX)
                let data = try (fileURL as URL).bookmarkData(options: URL.BookmarkCreationOptions.withSecurityScope,
                                                               includingResourceValuesForKeys:nil,
                                                               relativeTo: appScoped ? nil : ( documentfileURL ?? self.fileURL ) )
            #else
                let data =   try fileURL.bookmarkData(options: URL.BookmarkCreationOptions.suitableForBookmarkFile,
                                                      includingResourceValuesForKeys: nil,
                                                      relativeTo: appScoped ? nil : ( documentfileURL ?? self.fileURL ))

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
    
    
}
