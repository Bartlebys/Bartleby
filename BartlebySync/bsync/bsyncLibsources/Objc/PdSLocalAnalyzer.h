//
//  PdSLocalAnalyzer.h
//  PdSSync
//
//  Created by Benoit Pereira da Silva on 26/11/2013.
//  Revised for Swift 2.X support 29/12/2015
//  Copyright (c) 2013 Pereira da Silva. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PdSSync.h"

@interface PdSLocalAnalyzer : NSObject


/**
 *  Creates a hashmap - a dictionary with  relative paths as key and  CRC32 as value
 *  And save it to the relevent path
 *
 *  @param url the folder url
 *  @param dataBlock if you define this block it will be used to extract the data from the file
 *  @param progressBlock the progress block
 *  @param completionBlock the completion block.
 *
 */
- (void)createHashMapFromLocalFolderURL:(nonnull NSURL* )folderURL
                                dataBlock:(nullable  NSData *_Nullable (^)(NSString* _Nonnull path, NSUInteger index))dataBlock
                        progressBlock:(nullable void(^)(NSString*_Nonnull hash,NSString*_Nonnull path, NSUInteger index))progressBlock
              andCompletionBlock:(nonnull void(^)(HashMap* _Nonnull hashMap))completionBlock;


#pragma mark - Advanced

/**
 *  Default is NO
 *  If set to NO the dataBlock or the standard hash method will be ignored.
 */
@property (nonatomic)BOOL recomputeHash;

/**
 * Default is YES
 * When the hash is computed it is save to file.extension.kBsyncHashFileExtension
 * Else any file file with kBsyncHashFileExtension will be removed.
 */
@property (nonatomic)BOOL saveHashInAFile;


/**
 *  Saves the hashMap for a given folder
 *
 *  @param hashMap   the hashMap
 *  @param folderURL the folderURL
 */
- (void)saveHashMap:(nonnull HashMap*)hashMap toFolderUrl:(nonnull NSURL*)folderURL;


@end