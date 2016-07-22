//
//  PdSSyncContext.m
//  PdSSync
//
//  Created by Benoit Pereira da Silva on 13/03/2014.
//
//

#import "PdSSyncContext.h"

@implementation PdSSyncContext{

}

@synthesize repositoryPath = _repositoryPath;
@synthesize syncID = _syncID;
@synthesize sourceBaseUrl = _sourceBaseUrl;
@synthesize destinationBaseUrl = _destinationBaseUrl;
@synthesize finalHashMap = _finalHashMap;



/**
 * The url are considerated as the repository root
 *
 *  for example     : @"http://PdsSync.api.local/api/v1/tree/unique-public-id-1293"
 *  or              : @"~/Entrepot/Git/Public-projects/PdSSync/PdSSyncPhp/Repository/"
 *
 *  If the url is distant we extract the tree id.
 *
 *
 *  @param sourceUrl        the sourceUrl
 *  @param destinationUrl   the destinationUrl
 *  @param hashMapViewName  the optionnal hashMapViewName
 *
 *  @return the context
 */
-(instancetype)initWithSourceURL:(NSURL*_Nonnull)sourceUrl
                         andDestinationUrl:(NSURL*_Nonnull)destinationUrl
                              restrictedTo:(NSString*_Nullable)hashMapViewName{
    if(self){
        self->_sourceBaseUrl=[self _baseUrlFromUrl:sourceUrl];
        self->_destinationBaseUrl=[self _baseUrlFromUrl:destinationUrl];
        self->_sourceTreeId=[self _treeIDFromUrl:sourceUrl];
        self->_destinationTreeId=[self _treeIDFromUrl:destinationUrl];
        self->_syncID=[self _getNewSyncID];
        self->_autoCreateTrees=YES;
        if (hashMapViewName){
            self->_hashMapViewName=hashMapViewName;
        }
    }
    return self;
}

/**
 *  Initializer used for retro-compatibility purposes
 *
 *  @param sourceUrl      the source URL
 *  @param destinationUrl the destination URL
 *
 *  @return the context
 */
-(instancetype)initWithSourceURL:(NSURL*_Nonnull)sourceUrl
               andDestinationUrl:(NSURL*_Nonnull)destinationUrl{
    return  [self initWithSourceURL:sourceUrl andDestinationUrl:destinationUrl restrictedTo:nil];
}

- (BOOL)isValid{
    BsyncMode mode=[self mode];
    if (mode==SourceIsDistantDestinationIsDistant ){
        return false;
    }
    return (_sourceBaseUrl && _destinationBaseUrl);
}


- (BsyncMode)mode{
    // We use the http/s to discriminate local from distant urls.
    // If we introduce for example FTP adapter i will fail.
    // @todo
    if([[_sourceBaseUrl absoluteString] rangeOfString:@"http"].location==0){
        if([[_destinationBaseUrl absoluteString] rangeOfString:@"http"].location==0){
            return SourceIsDistantDestinationIsDistant;
        }else{
            return SourceIsDistantDestinationIsLocal;
        }
    }else{
        if([[_destinationBaseUrl absoluteString] rangeOfString:@"http"].location==0){
            return SourceIsLocalDestinationIsDistant;
        }else{
            return SourceIsLocalDestinationIsLocal;
        }
    }
}


- (NSString*)_treeIDFromUrl:(NSURL*)url{
    if([[url absoluteString] rangeOfString:@"http"].location==0){
        NSArray* components=url.pathComponents;
        if([components indexOfObject:@"tree"]){
            NSUInteger tIdx=[components indexOfObject:@"tree"];
            if([components count]>tIdx+1){
                return [components objectAtIndex:tIdx+1];
            }
        }
        return nil;
    }else{
        NSArray* components=url.pathComponents;
        return (NSString*)[components lastObject];
    }
}


- (NSURL*)_baseUrlFromUrl:(NSURL*)url{
    if([[url absoluteString] rangeOfString:@"http"].location==0){
        // HTTP and HTTPS
        NSArray* components=url.pathComponents;
        if([components indexOfObject:@"tree"]){
            NSUInteger tIdx=[components indexOfObject:@"tree"];
            if(tIdx >2 && tIdx!=NSNotFound){
                NSMutableString*stringUrl=[NSMutableString stringWithFormat:@"%@://%@",[url scheme],[url host]];
                for (int i=0; i<tIdx; i++) {
                    [stringUrl appendFormat:@"%@%@",[components objectAtIndex:i],(i==0||i==tIdx-1)?@"":@"/"];
                }
                return [NSURL URLWithString:stringUrl];
            }
        }
    }
    
    if(url){
        // LOCAL FILES
        NSURL*parentFolderURL=[url URLByDeletingLastPathComponent];
        NSString*path=[parentFolderURL path];
        NSURL*baseURL=[NSURL fileURLWithPath:path];
        return baseURL;
    }
    return nil;
}


-(NSString *)_getNewSyncID{
    // Returns a UUID
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    return [NSString stringWithFormat:@"%@%@",kBsyncPrefixSignature,uuidStr];
}


- (NSString*)contextDescription{
    NSMutableString*description=[NSMutableString stringWithString:@"# Synchro context description #\n"];
    [description appendFormat:@"%@\n",[kBsyncModeStrings objectAtIndex:[self mode]]];
    [description appendFormat:@"Repository path : %@\n",_repositoryPath];
    [description appendFormat:@"Source Base Url : %@\n",_sourceBaseUrl];
    [description appendFormat:@"Destination Base Url : %@\n",_destinationBaseUrl];
    [description appendFormat:@"Source Tree Id : %@\n",_sourceTreeId];
    [description appendFormat:@"Destination Tree Id : %@\n",_destinationTreeId];
    [description appendFormat:@"Sync Id : %@\n",_syncID];
    [description appendFormat:@"Auto create trees? %@\n",_autoCreateTrees?@"YES":@"NO"];
    [description appendString:@"# End of Context description #"];
    return description;
}

@end