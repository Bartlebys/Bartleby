//
//  Registry+SecurityScopes.swift
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


extension Registry {

    public enum SecurityScopedBookMarkError: ErrorType {
        // Bookmarking
        case BookMarkFailed(message:String)
        // Scoped URL
        case GetScopedURLRessourceFailed(message:String)
        case BookMarkIsStale
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
     You cannot get security scoped bookmark for an arbritrary NSURL.

     NOTE : Don't forget that you must call startAccessingToSecurityScopedResourceAtURL(scopedURL) as soon as you use the URL, and stopAccessingToSecurityScopedResourceAtURL(scopedURL) as soon as you can release the resource.



     - parameter url:             the URL to be accessed
     - parameter appScoped:       appScoped description
     - parameter documentfileURL: documentfileURL description

     - throws: throws various exception (on creation, and or resolution)

     - returns: the securized URL
     */
    public func getSecurizedURL(url: NSURL, appScoped: Bool=false, documentfileURL: NSURL?=nil) throws ->NSURL {
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
    public func deleteSecurityScopedBookmark(url: NSURL, appScoped: Bool=false, documentfileURL: NSURL?=nil) {
        if let _=url.path {
            let key=_getBookMarkKeyFor(url, appScoped: appScoped, documentfileURL: documentfileURL)
            self.registryMetadata.URLBookmarkData.removeValueForKey(key)
        }
    }

    /**
     Starts acessing to the securityScopedResource

     - parameter scopedUrl: the scopedUrl
     */
    public func startAccessingToSecurityScopedResourceAtURL(scopedUrl: NSURL) {
        scopedUrl.startAccessingSecurityScopedResource()
        if _activeSecurityBookmarks.indexOf(scopedUrl)==nil {
            _activeSecurityBookmarks.append(scopedUrl)
        }
    }


    /**
     Stops to access to securityScopedResource

     - parameter url: the url
     */
    public func stopAccessingToSecurityScopedResourceAtURL(scopedUrl: NSURL) {
        scopedUrl.stopAccessingSecurityScopedResource()
        if let idx=_activeSecurityBookmarks.indexOf(scopedUrl) {
            _activeSecurityBookmarks.removeAtIndex(idx)
        }

    }



    /**
     Stops to access to all the security Scoped Resources
     */
    public func stopAccessingAllSecurityScopedResources() {
        while  let key = _activeSecurityBookmarks.first {
            stopAccessingToSecurityScopedResourceAtURL(key)
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
    public func bookmarkURL(url: NSURL, appScoped: Bool=false, documentfileURL: NSURL?=nil) throws -> NSURL {
        if let _=url.path {
            var shareData = try self._createDataFromBookmarkForURL(url, appScoped:appScoped, documentfileURL:documentfileURL)
            // Encode the bookmark data as a Base64 string.
            shareData=shareData.base64EncodedDataWithOptions(.EncodingEndLineWithCarriageReturn)
            let stringifyedData=String(data: shareData, encoding: Default.TEXT_ENCODING)
            let key=_getBookMarkKeyFor(url, appScoped: appScoped, documentfileURL: documentfileURL)
            self.registryMetadata.URLBookmarkData[key]=stringifyedData

            #if os(OSX)
                self.updateChangeCount(NSDocumentChangeType.ChangeDone)
            #else
                self.updateChangeCount(UIDocumentChangeKind.Done)
            #endif
            return try getSecurityScopedURLFrom(url)
        }
        throw SecurityScopedBookMarkError.BookMarkFailed(message: "Invalid path Error for \(url)")
    }

    private func _getBookMarkKeyFor(url: NSURL, appScoped: Bool=false, documentfileURL: NSURL?=nil) -> String {
        if let path=url.path {
            return "\(path)-\((appScoped ? "YES" : "NO" ))-\(documentfileURL?.path ?? Default.NO_PATH ))"
        } else {
            return Default.NO_KEY
        }
    }


    /**
     Returns the URL on success

     - parameter url:             the url
     - parameter appScoped:       is it appScoped?
     - parameter documentfileURL: the document file URL if not app scoped

     - throws: throws value description

     - returns: the securized URL
     */
    public func getSecurityScopedURLFrom(url: NSURL, appScoped: Bool=false, documentfileURL: NSURL?=nil)throws -> NSURL {
        if let _=url.path {
            let key=_getBookMarkKeyFor(url, appScoped: appScoped, documentfileURL: documentfileURL)
            if let stringifyedData=self.registryMetadata.URLBookmarkData[key] as? String {
                if let base64EncodedData=stringifyedData.dataUsingEncoding(Default.TEXT_ENCODING) {
                    if let data=NSData(base64EncodedData: base64EncodedData, options: [.IgnoreUnknownCharacters]) {
                        var bookmarkIsStale: ObjCBool = false
                        do {
                            #if os(OSX)
                                let securizedURL = try NSURL(byResolvingBookmarkData: data,
                                                             options: NSURLBookmarkResolutionOptions.WithSecurityScope, relativeToURL:  appScoped ? nil : (documentfileURL ?? self.fileURL),
                                                             bookmarkDataIsStale: &bookmarkIsStale)
                            #else
                                //@bpds(#IOS) to be verified
                                let securizedURL = try NSURL(byResolvingBookmarkData: data,
                                                             options: NSURLBookmarkResolutionOptions.WithoutUI, relativeToURL:  appScoped ? nil : (documentfileURL ?? self.fileURL),
                                                             bookmarkDataIsStale: &bookmarkIsStale)
                            #endif
                            if (!bookmarkIsStale) {
                                return securizedURL
                            } else {
                                throw SecurityScopedBookMarkError.BookMarkIsStale
                            }
                        } catch {
                            throw SecurityScopedBookMarkError.GetScopedURLRessourceFailed(message: "Error \(error)")
                        }
                    } else {
                        throw SecurityScopedBookMarkError.GetScopedURLRessourceFailed(message:"Bookmark data Base64 decoding error")
                    }
                } else {
                    throw SecurityScopedBookMarkError.GetScopedURLRessourceFailed(message:"Bookmark data deserialization error")
                }
            } else {
                throw SecurityScopedBookMarkError.GetScopedURLRessourceFailed(message:"Unable to resolve bookmark for \(url) Did you bookmark that url?")
            }
        } else {
            throw SecurityScopedBookMarkError.GetScopedURLRessourceFailed(message:"Invalid path Error for \(url)")
        }
    }


    public func securityScopedBookmarkExits(url: NSURL, appScoped: Bool=false, documentfileURL: NSURL?=nil) -> Bool {
        if let _=url.path {
            let key=_getBookMarkKeyFor(url, appScoped: appScoped, documentfileURL: documentfileURL)
            let result=self.registryMetadata.URLBookmarkData.keys.contains(key)
            return result
        }
        return false

    }



    private func _createDataFromBookmarkForURL(fileURL: NSURL, appScoped: Bool=false, documentfileURL: NSURL?) throws -> NSData {
        do {
            #if os(OSX)
                let data = try fileURL.bookmarkDataWithOptions(NSURLBookmarkCreationOptions.WithSecurityScope,
                                                               includingResourceValuesForKeys:nil,
                                                               relativeToURL: appScoped ? nil : ( documentfileURL ?? self.fileURL ) )
            #else
                //@bpds(#IOS) to be verified
                let data = try fileURL.bookmarkDataWithOptions(NSURLBookmarkCreationOptions.SuitableForBookmarkFile,
                                                               includingResourceValuesForKeys: nil,
                                                               relativeToURL: appScoped ? nil : ( documentfileURL ?? self.fileURL ) )

            #endif
            // Extract of : https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSURL_Class/index.html#//apple_ref/occ/instm/NSURL/bookmarkDataWithOptions:includingResourceValuesForKeys:relativeToURL:error:
            // The URL that the bookmark data will be relative to.
            // If you are creating a security-scoped bookmark to support App Sandbox, use this parameter as follows:
            //To create an app-scoped bookmark, use a value of nil.
            // To create a document-scoped bookmark, use the absolute path (despite this parameter’s name) to the document file that is to own the new security-scoped bookmark.
            return data
        } catch {
            throw SecurityScopedBookMarkError.BookMarkFailed(message: "\(error)")
        }
    }


}
