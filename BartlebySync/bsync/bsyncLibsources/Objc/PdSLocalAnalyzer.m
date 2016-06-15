//
//  PdSLocalAnalyzer.m
//  PdSSync
//
//  Created by Benoit Pereira da Silva on 26/11/2013.
//  Copyright (c) 2013 Pereira da Silva. All rights reserved.
//

#import "PdSLocalAnalyzer.h"

#ifdef USE_EMBEDDED_OBJC
#import "bsync-Swift.h"
#endif

@interface PdSLocalAnalyzer(){
}
@end


@implementation PdSLocalAnalyzer

-(id)init{
    self=[super init];
    if(self){
        self.recomputeHash=NO;
        self.saveHashInAFile=YES;
    }
    return self;
}


/**
 *  Creates a dictionary with  relative paths as key and  CRC32 as value
 *
 *  @param folderPath the folder path
 *  @param dataBlock if you define this block it will be used to extract the data from the file
 *  @param progressBlock the progress block
 *  @param completionBlock the completion block.
 *
 */
- (void)createHashMapFromLocalFolder:(nonnull NSString* )folderPath
                              dataBlock:(nullable  NSData *_Nullable (^)(NSString* _Nonnull path, NSUInteger index))dataBlock
                          progressBlock:(nullable void(^)(NSString*_Nonnull hash,NSString*_Nonnull path, NSUInteger index))progressBlock
                     andCompletionBlock:(nonnull void(^)(HashMap* _Nonnull hashMap))completionBlock{
    
    PdSFileManager*fileManager=[PdSFileManager sharedInstance] ;
    HashMap*hashMap=[[HashMap alloc]init];
    if (![folderPath hasSuffix:@"/"]) {
        folderPath = [folderPath stringByAppendingString:@"/"];
    }
    
    if([fileManager fileExistsAtPath:folderPath]){
        
        NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
        NSDirectoryEnumerator *dirEnum =[fileManager enumeratorAtURL:[NSURL fileURLWithPath:folderPath]
                                          includingPropertiesForKeys:keys
                                                             options:0
                                                        errorHandler:^BOOL(NSURL *url, NSError *error) {
                                                            bprint(@"ERROR when enumerating  %@ %@",url, [error localizedDescription]);
                                                            return YES;
                                                        }];
        
        NSURL *file;
        int i=0;
        while ((file = [dirEnum nextObject])) {
            
            NSString *filePath=[[file URLByResolvingSymlinksInPath] path];
            NSNumber *isDirectory;
            [file getResourceValue:&isDirectory
                            forKey:NSURLIsDirectoryKey
                             error:nil];
            
            
            if([self pathSouldBeIncluded:filePath
                             isDirectory:[isDirectory boolValue]]){
                
                @autoreleasepool {
                    NSData *data=nil;
                    NSString*hashfile=[filePath stringByAppendingFormat:@".%@",kBsyncHashFileExtension];
                    NSString *relativePath=[filePath stringByReplacingOccurrencesOfString:folderPath withString:@""];
                    if([isDirectory boolValue]){
                        relativePath=[relativePath stringByAppendingString:@"/"];
                    }
                    // we check if there is a file.extension.kBsyncHashFileExtension
                    if(!self.recomputeHash && [fileManager fileExistsAtPath:hashfile] ){
                        NSError*crc32ReadingError=nil;
                        NSString*crc32String=[NSString stringWithContentsOfFile:filePath
                                                                       encoding:NSUTF8StringEncoding
                                                                          error:&crc32ReadingError];
                        if(!crc32ReadingError){
                            if (progressBlock){
                                progressBlock(crc32String,relativePath,i);
                            }
                        }else{
                            bprint(@"ERROR when reading crc32 from %@ %@",filePath,[crc32ReadingError localizedDescription]);
                        }
                    }else{
                        if (dataBlock) {
                            data=dataBlock(filePath,i);
                        }else{
                            data=[NSData dataWithContentsOfFile:filePath];
                        }
                    }
                    uint32_t crc32=(uint32_t)[data crc32];
                    NSString*crc32String=[NSString stringWithFormat:@"%@",@(crc32)];
                    if (crc32==0){
                        // Include the folders.
                        // We use the relative path as CRC32
                        crc32=[[relativePath dataUsingEncoding:NSUTF8StringEncoding] crc32];
                    }
                    if(crc32!=0){
                        [hashMap setSyncHash:crc32String
                                     forPath:relativePath];
                        i++;
                        if(self.saveHashInAFile){
                            [self _writeCrc32:crc32String
                               toFileWithPath:filePath];
                        }
                        if(progressBlock)
                            progressBlock(crc32String,relativePath,i);
                    }
                }
            }
        }
        
        [self saveHashMap:hashMap toFolder:folderPath];
        completionBlock(hashMap);
    }
}

- (BOOL)pathSouldBeIncluded:(NSString*)path isDirectory:(BOOL)isDirectory{
    return (
            // Exclude path explicitly enumerated to be excluded
            ![self _pathIsInTheExclusionList:path isDirectory:isDirectory]
            // Exclude files from the meta folder
            && ![self _pathIsInSyncMetadataFolder:path]
            // Temp files
            && ![self _pathIsAnSyncTemporaryFile:path]);
    
    
}

- (BOOL)_pathIsInTheExclusionList:(NSString*)path isDirectory:(BOOL)isDirectory{
    // Exclude directives
    NSArray*exclusions=@[
                        @".DS_Store",
                        @".fseventsd",
                        @".Trashes",
                        [BsyncDirectives DEFAULT_FILE_NAME]
                        ];

    for (NSString*exclusion in exclusions){
        BOOL found = ([path rangeOfString:exclusion].length > 0);
        if( found){
            return true;
        }
    }
    return false;
}


- (BOOL)_pathIsInSyncMetadataFolder:(NSString*)path{
    NSArray<NSString*>* components = [path pathComponents];
    for (NSString*component  in components) {
        if ([component isEqualToString:kBsyncMetadataFolder]){
            return true;
        }
    }
    return false;
}

- (BOOL)_pathIsAnSyncTemporaryFile:(NSString*)path{
    return ([[path lastPathComponent] rangeOfString:kBsyncPrefixSignature].location != NSNotFound );
}



/**
 *  Saves the hashMap in a given folder
 *
 *  @param hashMap   the hashMap
 *  @param folderURL the folderPath
 */
- (void)saveHashMap:(nonnull HashMap*)hashMap toFolder:(nonnull NSString*)folderPath{
    NSString *hashMapFileP = [folderPath stringByAppendingFormat:@"/%@/%@",kBsyncMetadataFolder,kBsyncHashMashMapFileName];
    [self saveHashMap:hashMap toPath:hashMapFileP];
}


/**
 *  Saves an hashMap to a given path
 *
 *  @param hashMap the hashMap
 *  @param path    the path
 */
- (void)saveHashMap:(nonnull HashMap *)hashMap toPath:(nonnull NSString *)path{
    PdSFileManager*fileManager=[PdSFileManager sharedInstance] ;
    // We gonna create the hashmap folder

    [fileManager createRecursivelyRequiredFolderForPath:path];

    // Let s write the serialized HashMap file
    NSDictionary*dictionaryHashMap=[hashMap dictionaryRepresentation];
    NSString*json=[self _encodetoJson:dictionaryHashMap];


    NSError *cryptoError = nil;

    NSString*jsonCrypted=[[Bartleby cryptoDelegate] encryptString:json error:&cryptoError];

    if(cryptoError){
        bprint(@"String encryption error: %@", [cryptoError description]);
    } else {

        // Un comment to debug
        // [(CryptoHelper*)[Bartleby cryptoDelegate] dumpDebug];

        NSError*error;
        [jsonCrypted writeToFile:path
                      atomically:YES
                        encoding:NSUTF8StringEncoding
                           error:&error];
        if(error){
            bprint(@"ERROR when writing hashmap to %@ %@", [error description],path);

        }
    }
}



#pragma mark - private


- (BOOL)_writeCrc32:(NSString*)crc32 toFileWithPath:(NSString*)path{
    NSError *crc32WritingError=nil;
    NSString *crc32Path=[path stringByAppendingFormat:@".%@",kBsyncHashFileExtension];
    
    [crc32 writeToFile:crc32Path
            atomically:YES
              encoding:NSUTF8StringEncoding
                 error:&crc32WritingError];
    if(crc32WritingError){
        return NO;
    }else{
        return YES;
    }
}


- (NSString*_Nullable)_encodetoJson:(id _Nonnull)object{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (!jsonData) {
        return [error localizedDescription];
    } else {
        return [[NSString alloc]initWithBytes:[jsonData bytes]
                                       length:[jsonData length] encoding:NSUTF8StringEncoding];
    }
}



@end