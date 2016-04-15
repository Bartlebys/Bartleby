//
//  PdSFileManager.h
//  Pods
//
//  Created by Benoit Pereira da Silva on 30/03/2014.
//
//

#import <Foundation/Foundation.h>
#import "PdSSync.h"

@interface PdSFileManager : NSFileManager<NSFileManagerDelegate>

+ (PdSFileManager*)sharedInstance;

- (BOOL)createRecursivelyRequiredFolderForPath:(NSString*)path;

- (NSString *)applicationDocumentsDirectory;

@end
