//
//  PdSFileManager.m
//  Pods
//
//  Created by Benoit Pereira da Silva on 30/03/2014.
//
//

#import "PdSFileManager.h"
#import "PdSSync.h"

@implementation PdSFileManager


+ (PdSFileManager*)sharedInstance{
    static PdSFileManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance setDelegate:(PdSFileManager<NSFileManagerDelegate>*)self];
    });
    return sharedInstance;
}


#pragma mark - File manager selectors

-(BOOL)createRecursivelyRequiredFolderForPath:(NSString*)path{
#if TARGET_OS_IPHONE
    if([path rangeOfString:[self applicationDocumentsDirectory]].location==NSNotFound){
        return NO;
    }
#endif
    NSString*filteredPath=path;
    if(![[path substringFromIndex:filteredPath.length-1] isEqualToString:@"/"]){
        filteredPath=[filteredPath stringByDeletingLastPathComponent];
    }
    if(![self fileExistsAtPath:filteredPath]){
        NSError *error=nil;
        [self createDirectoryAtPath:filteredPath
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:&error];
        if(error){
            return NO;
        }
    }
    return YES;
}


- (NSString *)applicationDocumentsDirectory{
#if TARGET_OS_IPHONE
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return [basePath stringByAppendingString:@"/"];
#else
    // If the absolute path was nil
    // We create automatically a data folder
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath=[paths lastObject];
    return basePath;
#endif
}



#pragma mark - NSFileManagerDelegate


- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error copyingItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath{
    if ([error code] == NSFileWriteFileExistsError)
        return YES;
    else
        return NO;
}
- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error copyingItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL{
    if ([error code] == NSFileWriteFileExistsError)
        return YES;
    else
        return NO;
}

- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error movingItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath{
    if ([error code] == NSFileWriteFileExistsError)
        return YES;
    else
        return NO;
    
}
- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error movingItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL{
    if ([error code] == NSFileWriteFileExistsError)
        return YES;
    else
        return NO;
    
}

#pragma mark -

/**
 *  Destructive implementation that overrides the standard behavior by destroying the dstPath before to proceed to copy.
 *
 *  @param srcPath srcPath the source path
 *  @param dstPath dstPath the destination path
 *  @param error   error description
 *
 *  @return the result
 */
- (BOOL)copyItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error{
    glog(@"Copy:\n\t- Src:%@\n\t- Dst:%@", srcPath, dstPath);
    if([self fileExistsAtPath:dstPath]){
        if(![self removeItemAtPath:dstPath
                             error:error]){
            return NO;
        }
    }
    return [super copyItemAtPath:srcPath
                          toPath:dstPath
                           error:error];
}

/**
 *  Destructive implementation that Ooverrides the standard behavior by destroying the dstPath before to proceed to move.
 *
 *  @param srcPath srcPath the source path
 *  @param dstPath dstPath the destination path
 *  @param error   error description
 *
 *  @return the result
 */
- (BOOL)moveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error{
    glog(@"Move:\n\t- Src:%@\n\t- Dst:%@", srcPath, dstPath);
    if([self fileExistsAtPath:dstPath]){
        if(![self removeItemAtPath:dstPath
                             error:error]){
            return NO;
        }
    }
    return [super moveItemAtPath:srcPath
                          toPath:dstPath
                           error:error];
}


@end
