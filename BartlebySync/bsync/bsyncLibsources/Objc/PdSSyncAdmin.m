//
//  PdSSyncAdmin.m
//  Pods
//
//  Created by Benoit Pereira da Silva on 12/11/2014.
//  Revised for Swift 2.X support 30/12/2015
//

#import "PdSSyncAdmin.h"

#ifdef USE_BSYNC_XPC_OBJC
#import "BsyncXPC-Swift.h"
#else
#ifdef USE_CLIENT_BSYNC_XPC_OBJC
#import "ClientBsyncXPC-Swift.h"
#else
#ifdef USE_EMBEDDED_MODULES
#import "bsync-Swift.h"
#endif
#endif
#endif



#define kRecursiveMaxNumberOfAttempts 2

@interface PdSSyncAdmin (){
    PdSFileManager *__weak _fileManager;
    BOOL _shouldWait;
    NSURLSession* _urlSession;
    PdSCommandInterpreter*_interpreter;
}

// We store the current task.
@property (nonatomic,strong)NSURLSessionTask*currentTask;

@end

@implementation PdSSyncAdmin


/**
 *  Initialize the admin facade with a contzext
 *
 *  @param context the context
 *
 *  @return the admin instance
 */
- (instancetype)initWithContext:(BsyncContext*)context{
    self=[super init];
    if(self){
        _syncContext=context;
        _shouldWait=NO;
        _fileManager=[PdSFileManager sharedInstance];
    }
    return self;
}

#pragma mark - Synchronization

/**
 *  Synchronizes the source to the destination
 *
 *  @param progressBlock   the progress block
 *  @param completionBlock the completionBlock
 */
-(void)synchronizeWithprogressBlock:(void(^_Nullable)(NSInteger taskIndex,NSInteger totalTaskCount,double progress,NSString* _Nullable message))progressBlock
                 andCompletionBlock:(void(^_Nonnull)(BOOL success,NSString*_Nullable message))completionBlock{
    
    
    [self.finalizationDelegate progressMessage:[self.syncContext contextDescription]];
    
    if ( _syncContext.hashMapViewName ) {
        BsyncMode mode=[_syncContext mode];
        if(mode==SourceIsLocalDestinationIsDistant || mode==SourceIsDistantDestinationIsDistant){
            // Block the operation.
            completionBlock(NO,@"Hash Map views should be used on Read only Down streams the synchronization has been cancelled");
            return;
        }
    }
    
    int attempts=0;
    [self _prepareAndSynchronizeWithprogressBlock:progressBlock
                               andCompletionBlock:completionBlock
                                  numberOfAttempt:attempts];
}


-(void)_prepareAndSynchronizeWithprogressBlock:(void(^_Nullable)(NSInteger taskIndex,NSInteger totalTaskCount,double progress,NSString* _Nullable message))progressBlock
                            andCompletionBlock:(void(^)(BOOL success,NSString*message))completionBlock
                               numberOfAttempt:(int)attempts{
    attempts++;
    if(attempts > kRecursiveMaxNumberOfAttempts){
        // This occurs if the recursive call fails.
        completionBlock(NO,[NSString stringWithFormat:@"Excessive number of attempts of synchronization %i",kRecursiveMaxNumberOfAttempts]);
        return;
    }
    if(self.syncContext.autoCreateTrees){
        [self touchTreesWithCompletionBlock:^(BOOL success, NSInteger statusCode) {
            if(success){
                NSString*message=@"Tree exists!";
                printf("%s\n",[message cStringUsingEncoding:NSUTF8StringEncoding]);
                [self _synchronizeWithprogressBlock:progressBlock
                                 andCompletionBlock:completionBlock];
                
            }else{
                if (statusCode==404){
                    NSString*message=@"Auto creation of tree";
                    printf("%s\n",[message cStringUsingEncoding:NSUTF8StringEncoding]);
                    [self createTreesWithCompletionBlock:^(BOOL success, NSInteger statusCode) {
                        if(success){
                            // Recursive call
                            [self _prepareAndSynchronizeWithprogressBlock:progressBlock
                                                       andCompletionBlock:completionBlock
                                                          numberOfAttempt:attempts];
                        }else{
                            completionBlock(NO,[NSString stringWithFormat:@"Failure on createTreesWithCompletionBlock autoCreateTrees==YES with statusCode %i",(int)statusCode]);
                        }
                    }];
                }else{
                    completionBlock(NO,[NSString stringWithFormat:@"Tree autocreationfailure with status code : %@",@(statusCode)]);
                    return;
                }
            }
        }];
    }else{
        [self _synchronizeWithprogressBlock:progressBlock
                         andCompletionBlock:completionBlock];
    }
}



- (void)_synchronizeWithprogressBlock:(void(^_Nullable)(NSInteger taskIndex,NSInteger totalTaskCount,double progress,NSString* _Nullable message))progressBlock
                   andCompletionBlock:(void(^)(BOOL success,NSString*message))completionBlock{
    
    
    [self _hashMapsForTreesWithCompletionBlock:^(HashMap *sourceHashMap, HashMap *destinationHashMap, NSInteger statusCode) {
        if(sourceHashMap && destinationHashMap ){
            
    
            DeltaPathMap*dpm=[sourceHashMap deltaPathMapWithSource:sourceHashMap
                                                    andDestination:destinationHashMap
                                                        withFilter:self.filteringBlock];
            
            NSMutableArray*commands=[PdSCommandInterpreter commandsFromDeltaPathMap:dpm];
            NSInteger cmdCounts=(NSInteger)commands.count;
            
            NSString*s=[NSString stringWithFormat:@"Source\n%@",[sourceHashMap dictionaryRepresentation]];
            NSString*d=[NSString stringWithFormat:@"Destination\n%@",[destinationHashMap dictionaryRepresentation]];
            progressBlock(0,cmdCounts,0.f,[NSString stringWithFormat:@"# SYNCRONIZATION #"]);
            progressBlock(0,cmdCounts,0.f,s);
            progressBlock(0,cmdCounts,0.f,d);
            
            
            progressBlock(0,cmdCounts,0.f,[NSString stringWithFormat:@"DeltaPathMap\n%@",[dpm dictionaryRepresentation]]);
            NSMutableString*cmdString=[NSMutableString string];
            [cmdString appendString:@"## Commands to be executed : ##\n"];
            for (NSString*cmd in commands) {
                NSString*tmpCmdString=[NSString stringWithFormat:@"%@\n",[cmd copy]];
                tmpCmdString=[tmpCmdString stringByReplacingOccurrencesOfString:@"[0," withString:@"BCreate ["];
                tmpCmdString=[tmpCmdString stringByReplacingOccurrencesOfString:@"[1," withString:@"BUpdate ["];
                tmpCmdString=[tmpCmdString stringByReplacingOccurrencesOfString:@"[2," withString:@"BMove ["];
                tmpCmdString=[tmpCmdString stringByReplacingOccurrencesOfString:@"[3," withString:@"BCopy ["];
                tmpCmdString=[tmpCmdString stringByReplacingOccurrencesOfString:@"[4," withString:@"BDelete ["];
                [cmdString appendString:tmpCmdString];
            }
            [cmdString appendString:@"## End of Commands List ##"];
            progressBlock(0,cmdCounts,0.f,cmdString);
            
            
            _interpreter= [PdSCommandInterpreter interpreterWithBunchOfCommand:commands context:self->_syncContext
                                                                 progressBlock:^(uint taskIndex, double progress) {
                                                                     NSString*cmd=([commands count]>taskIndex)?[commands objectAtIndex:taskIndex]:@"POST CMD";
                                                                     progressBlock(taskIndex,cmdCounts,progress,cmd);
                                                                 } andCompletionBlock:^(BOOL success, NSString *message) {
                                                                     completionBlock(success,message);
                                                                 }];
            
            _interpreter.finalizationDelegate=self.finalizationDelegate;
            
            
        }else{
            
            BOOL sourceHashMapIsNil=(!sourceHashMap);
            BOOL destinationHashMapIsNil=(!destinationHashMap);
            NSString *m=[NSString stringWithFormat:@"Failure on hashMapsForTreesWithCompletionBlock with statusCode %i\nSource HashMap Is Nil? %@ \ndestination HashMap Is Nil? %@\n"
                         ,(int)statusCode,sourceHashMapIsNil?@"YES":@"NO",destinationHashMapIsNil?@"YES":@"NO"];
            completionBlock(NO,m);
            
        }
    }];
}



#pragma mark - Advanced actions


/**
 *  Proceed to installation of the Repository
 *  @param block   the completion block
 */
- (void)installWithCompletionBlock:(void (^_Nonnull)(BOOL success, NSInteger statusCode))block{
    if(_syncContext.mode==SourceIsLocalDestinationIsDistant){
        NSMutableDictionary*parameters=[NSMutableDictionary dictionary];
        if(_syncContext.creationKey)
            [parameters setObject:_syncContext.creationKey forKey:@"key"];
        
        
        NSURL*baseUrl=[_syncContext.destinationBaseUrl URLByAppendingPathComponent:@"/install"];
        NSURL*urlWithParameters=[baseUrl URLByAppendingQueryStringDictionary:parameters];
        
        // REQUEST
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:urlWithParameters];
        request.HTTPMethod = @"POST";
        
        // TASK
        [self addCurrentTaskAndResume:[self.urlSession uploadTaskWithRequest:request
                                                                    fromData:nil
                                                           completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                               if(!error && response){
                                                                   NSInteger HTTPStatusCode=((NSHTTPURLResponse*)response).statusCode;
                                                                   if (HTTPStatusCode>=200 && HTTPStatusCode<=300){
                                                                       block(YES,HTTPStatusCode);
                                                                       return ;
                                                                   }else{
                                                                       if (data!=nil) {
                                                                           NSString*message=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                                                                           printf("Fault on repository installation: %s\n",[message cStringUsingEncoding:NSUTF8StringEncoding]);
                                                                       }
                                                                       block(NO,HTTPStatusCode);
                                                                       return;
                                                                   }
                                                               }
                                                               if(error){
                                                                   NSString*message=[[NSString alloc]initWithFormat:@"%@",error];
                                                                   printf("Error on repository installation: %s\n",[message cStringUsingEncoding:NSUTF8StringEncoding]);
                                                               }
                                                               block(NO,0);
                                                           }]];
    }else if (_syncContext.mode==SourceIsLocalDestinationIsLocal){
        // CURRENTLY NOT SUPPORTED
    }else if (_syncContext.mode==SourceIsDistantDestinationIsDistant){
        // CURRENTLY NOT SUPPORTED
    }
}

/**
 *  Creates a tree
 *  @param block      the completion block
 */
- (void)createTreesWithCompletionBlock:(void (^_Nonnull)(BOOL success, NSInteger statusCode))block{
    
    if(_syncContext.mode==SourceIsLocalDestinationIsDistant){
        if([self _createOrConfirmTreeLocalUrl:_syncContext.sourceBaseUrl
                                       withId:_syncContext.sourceTreeId]){
            
            [self _createTreeDistantUrl:_syncContext.destinationBaseUrl
                                 withId:_syncContext.destinationTreeId
                     andCompletionBlock:^(BOOL success, NSInteger statusCode) {
                         block(success,statusCode);
                     }];
        }else{
            block(NO,404);
        }
    }else if(_syncContext.mode==SourceIsDistantDestinationIsLocal){
        if([self _createOrConfirmTreeLocalUrl:_syncContext.destinationBaseUrl
                                       withId:_syncContext.destinationTreeId]){
            
            [self _createTreeDistantUrl:_syncContext.sourceBaseUrl
                                 withId:_syncContext.sourceTreeId
                     andCompletionBlock:^(BOOL success, NSInteger statusCode) {
                         block(success,statusCode);
                     }];
        }else{
            block(NO,404);
        }
    }else if (_syncContext.mode==SourceIsLocalDestinationIsLocal){
        if([self _createOrConfirmTreeLocalUrl:_syncContext.sourceBaseUrl
                                       withId:_syncContext.sourceTreeId]&&
           [self _createOrConfirmTreeLocalUrl:_syncContext.destinationBaseUrl
                                       withId:_syncContext.destinationTreeId]){
               block(YES,200);
           }else{
               block(NO,404);
           }
    }else if (_syncContext.mode==SourceIsDistantDestinationIsDistant){
        // CURRENTLY NOT SUPPORTED
        block(NO, 501);
    }
}


-(void)_createTreeDistantUrl:(NSURL*)baseUrl withId:(NSString*)identifier
          andCompletionBlock:(void (^)(BOOL success, NSInteger statusCode))block{

    
    
    if(! _syncContext.creationKey || ! _syncContext.credentials.spaceUID ){
        printf("Invalid context creation key or credentials.spaceUID ");
        block(NO,0);
    }else{
        NSMutableDictionary*parameters=[NSMutableDictionary dictionary];
        [parameters setObject:_syncContext.creationKey forKey:@"key"];
        
        // URL
        baseUrl=[baseUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"/create/tree/%@",identifier]];
        NSURL*urlWithParameters=[baseUrl URLByAppendingQueryStringDictionary:parameters];
        
        
        
        
        // REQUEST
        NSMutableURLRequest *request = [HTTPManager mutableRequestWithTokenInDataSpace:_syncContext.credentials.spaceUID
                                                                           withActionName:@"BartlebySyncCreateTree"
                                                                                forMethod:@"POST"
                                                                                      and:urlWithParameters];
        
        [self addCurrentTaskAndResume:[self.urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(!error && response){
                NSInteger HTTPStatusCode=((NSHTTPURLResponse*)response).statusCode;
                if (HTTPStatusCode>=200 && HTTPStatusCode<=300){
                    block(YES,HTTPStatusCode);
                    return ;
                }else{
                    if (data!=nil) {
                        NSString*message=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                        printf("Fault on distant tree creation: %s\n",[message cStringUsingEncoding:NSUTF8StringEncoding]);
                    }
                    block(NO,HTTPStatusCode);
                    return ;
                }
            }
            if(error){
                NSString*message=[[NSString alloc]initWithFormat:@"%@",error];
                printf("Error on distant tree creation: %s\n",[message cStringUsingEncoding:NSUTF8StringEncoding]);
            }
            block(NO,0);
        }]];
    }
        
        


}

-(BOOL)_createOrConfirmTreeLocalUrl:(NSURL*)baseUrl
                             withId:(NSString*)identifier{
    
    NSString*p=[baseUrl path];
    p=[p stringByAppendingFormat:@"/%@",identifier];
    if ([_fileManager fileExistsAtPath:p]) {
        return YES;
    }
    [_fileManager createRecursivelyRequiredFolderForPath:p];
    // By default we create a void hashmap.
    HashMap*hashMap=[[HashMap alloc] init];
    PdSLocalAnalyzer*analyzer=[[PdSLocalAnalyzer alloc] init];
    analyzer.saveHashInAFile=NO;
    [analyzer saveHashMap:hashMap toFolderUrl:[NSURL URLWithString:p]];
    return YES;
}




/**
 *  Touches the trees (changes the public ID )
 *
 *  @param block      the completion block
 */
- (void)touchTreesWithCompletionBlock:(void (^_Nonnull)(BOOL success, NSInteger statusCode))block{
    
    if(_syncContext.mode==SourceIsLocalDestinationIsDistant){
        if( [self _touchLocalUrl:_syncContext.sourceBaseUrl
                   andTreeWithId:_syncContext.sourceTreeId]){
            [self _touchDistantUrl:_syncContext.destinationBaseUrl
                    withTreeWithId:_syncContext.destinationTreeId
                andCompletionBlock:^(BOOL success, NSInteger statusCode) {
                    block(success,statusCode);
                }];
        }else{
            block(NO,404);
        }
    }else if (_syncContext.mode==SourceIsDistantDestinationIsLocal){
        if([self _touchLocalUrl:_syncContext.destinationBaseUrl
                  andTreeWithId:_syncContext.destinationTreeId]){
            [self _touchDistantUrl:_syncContext.sourceBaseUrl
                    withTreeWithId:_syncContext.sourceTreeId
                andCompletionBlock:^(BOOL success, NSInteger statusCode) {
                    block(success,statusCode);
                }];
        }else{
            block(NO,404);
        }
        
    }else if (_syncContext.mode==SourceIsLocalDestinationIsLocal){
        if([self _touchLocalUrl:_syncContext.sourceBaseUrl andTreeWithId:_syncContext.sourceTreeId]&&
           [self _touchLocalUrl:_syncContext.destinationBaseUrl andTreeWithId:_syncContext.destinationTreeId]){
            block(YES,200);
        }else{
            block(NO,404);
        }
    }else if (_syncContext.mode==SourceIsDistantDestinationIsDistant){
        // CURRENTLY NOT SUPPORTED
    }
}

-(void)_touchDistantUrl:(NSURL*)baseUrl
         withTreeWithId:(NSString*)identifier
     andCompletionBlock:(void (^)(BOOL success, NSInteger statusCode))block{
    
    if( ! _syncContext.creationKey || ! _syncContext.credentials.spaceUID  ){
        printf("Invalid context creationKey and credentials.spaceUID must be set");
        block(NO,0);
    }else{
        // URL
        NSMutableDictionary*parameters=[NSMutableDictionary dictionary];
        [parameters setObject:_syncContext.creationKey forKey:@"key"];
        baseUrl=[baseUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"/touch/tree/%@",identifier]];
        NSURL*urlWithParameters=[baseUrl URLByAppendingQueryStringDictionary:parameters];
    
        // REQUEST
        NSMutableURLRequest *request = [HTTPManager mutableRequestWithTokenInDataSpace:_syncContext.credentials.spaceUID
                                                                           withActionName:@"BartlebySyncTouchTree"
                                                                                forMethod:@"POST"
                                                                                      and:urlWithParameters];
        

    // TASK
    [self addCurrentTaskAndResume:[self.urlSession dataTaskWithRequest:request
                                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                         if(!error && response){
                                                             NSInteger HTTPStatusCode=((NSHTTPURLResponse*)response).statusCode;
                                                             if (HTTPStatusCode>=200 && HTTPStatusCode<=300){
                                                                 block(YES,HTTPStatusCode);
                                                                 return;
                                                             }else{
                                                                 if (data!=nil) {
                                                                     NSString*message=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                                                                     printf("Fault on touch distant url : %s\n",[message cStringUsingEncoding:NSUTF8StringEncoding]);
                                                                 }
                                                                 block(NO,HTTPStatusCode);
                                                                 return;
                                                             }
                                                         }
                                                         if(error){
                                                             NSString*message=[[NSString alloc]initWithFormat:@"%@",error];
                                                             printf("Error on touch distant url : %s\n",[message cStringUsingEncoding:NSUTF8StringEncoding]);
                                                         }
                                                         block(NO,0);
                                                     }]];
    }
    
}

-(BOOL)_touchLocalUrl:(NSURL*)baseUrl
        andTreeWithId:(NSString*)identifier{
    NSString*p=[baseUrl path];
    p=[p stringByAppendingFormat:@"/%@",identifier];
    BOOL treeExists=[_fileManager fileExistsAtPath:p];
    return treeExists;
}




/**
 *  Returns the source and destination hashMaps for a given tree
 *  @param block  the result block
 */
-(void)_hashMapsForTreesWithCompletionBlock:(void (^_Nonnull)(HashMap* _Nullable sourceHashMap,HashMap* _Nullable destinationHashMap,NSInteger statusCode))block{

    if (_syncContext.hashMapViewName ){
        [self _hashMapsViewsForTreesWithCompletionBlock:block];
    }else{
        PdSSyncAdmin*__block weakSelf=self;
        if(_syncContext.mode==SourceIsLocalDestinationIsDistant){
            [self _distantHashMapForUrl:_syncContext.destinationBaseUrl
                          andTreeWithId:_syncContext.destinationTreeId
                    withCompletionBlock:^(HashMap *hashMap, NSInteger statusCode) {
                        PdSSyncAdmin* strongSelf=weakSelf;
                        HashMap*sourceHashMap=[strongSelf  _localHashMapForUrl:strongSelf->_syncContext.sourceBaseUrl
                                                                 andTreeWithId:strongSelf->_syncContext.sourceTreeId];
                        
                        HashMap*destinationHashMap=hashMap;
                        [strongSelf->_syncContext setFinalHashMap:sourceHashMap];
                        if(!destinationHashMap && statusCode==404){
                            // There is currently no destination hashMap let's create a void one.
                            destinationHashMap=[[HashMap alloc] init];
                        }
                        block(sourceHashMap,destinationHashMap,statusCode);
                    }];
        }else if (_syncContext.mode==SourceIsDistantDestinationIsLocal){
            [self _distantHashMapForUrl:_syncContext.sourceBaseUrl
                          andTreeWithId:_syncContext.sourceTreeId
                    withCompletionBlock:^(HashMap *hashMap, NSInteger statusCode) {
                        PdSSyncAdmin* strongSelf=weakSelf;
                        HashMap*sourceHashMap=hashMap;
                        HashMap*destinationHashMap=[strongSelf  _localHashMapForUrl:strongSelf->_syncContext.destinationBaseUrl
                                                                      andTreeWithId:strongSelf->_syncContext.destinationTreeId];
                        if(!sourceHashMap && statusCode==404){
                            // There is currently no destination hashMap let's create a void one.
                            sourceHashMap=[[HashMap alloc] init];
                        }
                        [strongSelf->_syncContext setFinalHashMap:sourceHashMap];
                        block(sourceHashMap,destinationHashMap,statusCode);
                    }];
            
        }else if (_syncContext.mode==SourceIsLocalDestinationIsLocal){
            HashMap*sourceHashMap=[self _localHashMapForUrl:_syncContext.sourceBaseUrl
                                              andTreeWithId:_syncContext.sourceTreeId];
            _syncContext.finalHashMap=sourceHashMap;
            HashMap*destinationHashMap=[self _localHashMapForUrl:_syncContext.destinationBaseUrl
                                                   andTreeWithId:_syncContext.sourceTreeId];
            if(!destinationHashMap){
                // There is currently no destination hashMap let's create a void one.
                destinationHashMap=[[HashMap alloc] init];
            }
            if(sourceHashMap && destinationHashMap){
                block(sourceHashMap,destinationHashMap,200);
            }else{
                block(sourceHashMap,destinationHashMap,404);
            }
        }else if (_syncContext.mode==SourceIsDistantDestinationIsDistant){
            // CURRENTLY NOT SUPPORTED
        }
 
    }
}


-(HashMap*)_localHashMapForUrl:(NSURL*)url
                 andTreeWithId:(NSString*)identifier{
    
    NSString*hashMapRelativePath=[NSString stringWithFormat:@"%@/%@/%@/%@",[url path],identifier,kBsyncMetadataFolder,kBsyncHashMashMapFileName];
    hashMapRelativePath=hashMapRelativePath;
    NSURL *hashMapUrl=[NSURL fileURLWithPath:hashMapRelativePath];
    
    NSError*stringLoadingError=nil;
    
    NSString *string=[NSString stringWithContentsOfURL:hashMapUrl
                                              encoding:NSUTF8StringEncoding
                                                 error:&stringLoadingError];
    if(!stringLoadingError){
        NSError*cryptoError=nil;
        NSData *data = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
        // Uncomment to debug
        // [(CryptoHelper*)[Bartleby cryptoDelegate] dumpDebug];
        data=[[Bartleby cryptoDelegate] decryptData:data error:&cryptoError];
        if (cryptoError){
            NSString*message=[[NSString alloc]initWithFormat:@"Get local hash map crypto error %@",cryptoError];
            printf("%s\n",[message cStringUsingEncoding:NSUTF8StringEncoding]);
            return nil;
        }else{
            NSError*__block errorJson=nil;
            @try {
                // We use mutable containers and leaves by default.
                id __block result=nil;
                result=[NSJSONSerialization JSONObjectWithData:data
                                                       options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments
                                                         error:&errorJson];
                
                
                if([result isKindOfClass:[NSDictionary class]]){
                    return [HashMap fromDictionary:result];
                }else{
                    NSString*message=[[NSString alloc]initWithFormat:@"Get local hash map type missmatch on deserialization %@",hashMapUrl];
                    printf("%s\n",[message cStringUsingEncoding:NSUTF8StringEncoding]);
                }
            }
            @catch (NSException *exception) {
                NSString*message=[[NSString alloc]initWithFormat:@"get local hash map :%@",exception];
                printf("Exception on %s\n",[message cStringUsingEncoding:NSUTF8StringEncoding]);
            }
        }
    }
    
    // There is no hashMap or we have encoutered an issue
    [_fileManager createRecursivelyRequiredFolderForPath:hashMapRelativePath];
    return [[HashMap alloc] init];// Return a void HashMap
}

-(void)_distantHashMapForUrl:(NSURL*)url
               andTreeWithId:(NSString*)identifier
         withCompletionBlock:(void (^)(HashMap*hashMap,NSInteger statusCode))block{
    
    if( ! _syncContext.credentials.spaceUID ){
        printf("Invalid context credentials.spaceUID ");
        block(NO,0);
    }else{
        // URL
        NSMutableDictionary*parameters=[NSMutableDictionary dictionary];
        url=[url URLByAppendingPathComponent:[NSString stringWithFormat:@"/hashMap/tree/%@",identifier]];
        NSURL*urlWithParameters=[url URLByAppendingQueryStringDictionary:parameters];
        
        // REQUEST
        NSMutableURLRequest *request = [HTTPManager mutableRequestWithTokenInDataSpace:_syncContext.credentials.spaceUID
                                                                           withActionName:@"BartlebySyncGetHashMap"
                                                                                forMethod:@"GET"
                                                                                      and:urlWithParameters];
    
    // TASK
    
    [self addCurrentTaskAndResume:[self.urlSession dataTaskWithRequest:request
                                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                         if(!error && response){
                                                             double httpStatusCode=((NSHTTPURLResponse*)response).statusCode;
                                                             if (httpStatusCode==200) {
                                                                 
                                                                 // In this case decryptString is not directly interoparable with decrypt data.
                                                                 // We cannot infer the data encoding
                                                                 // So we need to proceed to multiple transformations.
                                                                 // from data to string and from string to data before to JSON deserialize
                                                                 NSString*cryptoString=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                                                                 
                                                                 NSError *cryptoError = nil;
                                                                 cryptoString=[[Bartleby cryptoDelegate] decryptString:cryptoString error:&cryptoError];
                                                                 if(cryptoError){
                                                                     NSString*message=@"String decryption error";
                                                                     printf("%s\n", [message cStringUsingEncoding:NSUTF8StringEncoding]);
                                                                     block(nil,PdSStatusErrorHashMapDeserialization);
                                                                 } else {
                                                                     data=[cryptoString dataUsingEncoding:NSUTF8StringEncoding];
                                                                     
                                                                     @try {
                                                                         NSError *parseError = nil;
                                                                         NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                                            options:0
                                                                                                                                              error:&parseError];
                                                                         if(parseError){
                                                                             NSString*message=@"Hash map JSON deserialization error";
                                                                             printf("%s\n",[message cStringUsingEncoding:NSUTF8StringEncoding]);
                                                                             block(nil,PdSStatusErrorHashMapDeserialization);
                                                                         }else if( [responseDictionary isKindOfClass:[NSDictionary class]]){
                                                                             HashMap*hashMap=[HashMap fromDictionary:responseDictionary];
                                                                             block(hashMap,((NSHTTPURLResponse*)response).statusCode);
                                                                         }else{
                                                                             NSString*message=@"Hash map deserialization type miss match";
                                                                             printf("%s\n",[message cStringUsingEncoding:NSUTF8StringEncoding]);
                                                                             block(nil,PdSStatusErrorHashMapDeserializationTypeMissMatch);
                                                                         }
                                                                     }
                                                                     @catch (NSException *exception) {
                                                                         NSString*message=[[NSString alloc]initWithFormat:@"%@",exception];
                                                                         printf("Exception on get distant hash map %s\n",[message cStringUsingEncoding:NSUTF8StringEncoding]);
                                                                         block(nil,PdSStatusErrorHashMapFailure);
                                                                     }
                                                                 }
                                                                 
                                                                 
                                                             }else{
                                                                 if (data!=nil) {
                                                                     NSString*message=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                                                                     printf("Fault on get distant hash map  : %s\n",[message cStringUsingEncoding:NSUTF8StringEncoding]);
                                                                 }
                                                                 block(nil,httpStatusCode);
                                                             }
                                                             
                                                         }else{
                                                             NSString*message=[[NSString alloc]initWithFormat:@"get distant hash map :%@",error];
                                                             printf("Error on %s\n",[message cStringUsingEncoding:NSUTF8StringEncoding]);
                                                             block(nil,0);
                                                         }
                                                     }]];
    }
}

#pragma mark - hashMapViews


/**
 *  The concrete implementation that handles the HashMapView Case.
 *
 *  To prevent from hazardous result
 *  we have blocked in BsyncDirectives.areValid() upstream directives with hashmap view.
 *  (IMPORTANT) If you need a save bidirectionnal hashmap view support this implementation should be revised.
 *
 *  @param block the completion block
 */
-(void)_hashMapsViewsForTreesWithCompletionBlock:(void (^_Nonnull)(HashMap* _Nullable sourceHashMap,HashMap* _Nullable destinationHashMap,NSInteger statusCode))block{
    PdSSyncAdmin*__block weakSelf=self;
    if(_syncContext.mode==SourceIsLocalDestinationIsDistant){
        [self _distantHashMapViewForUrl:_syncContext.destinationBaseUrl
                      andTreeWithId:_syncContext.destinationTreeId  
                withCompletionBlock:^(HashMap *hashMap, NSInteger statusCode) {
                    PdSSyncAdmin* strongSelf=weakSelf;
                    HashMap*sourceHashMap=[strongSelf  _localHashMapViewForUrl:strongSelf->_syncContext.sourceBaseUrl
                                                             andTreeWithId:strongSelf->_syncContext.sourceTreeId];
                    
                    HashMap*destinationHashMap=hashMap;
                    [strongSelf->_syncContext setFinalHashMap:sourceHashMap];
                    if(!destinationHashMap && statusCode==404){
                        // There is currently no destination hashMap let's create a void one.
                        destinationHashMap=[[HashMap alloc] init];
                    }
                    block(sourceHashMap,destinationHashMap,statusCode);
                }];
    }else if (_syncContext.mode==SourceIsDistantDestinationIsLocal){
        [self _distantHashMapViewForUrl:_syncContext.sourceBaseUrl
                      andTreeWithId:_syncContext.sourceTreeId
                withCompletionBlock:^(HashMap *hashMap, NSInteger statusCode) {
                    PdSSyncAdmin* strongSelf=weakSelf;
                    HashMap*sourceHashMap=hashMap;
                    HashMap*destinationHashMap=[strongSelf  _localHashMapViewForUrl:strongSelf->_syncContext.destinationBaseUrl
                                                                  andTreeWithId:strongSelf->_syncContext.destinationTreeId];
                    if(!sourceHashMap && statusCode==404){
                        // There is currently no destination hashMap let's create a void one.
                        sourceHashMap=[[HashMap alloc] init];
                    }
                    [strongSelf->_syncContext setFinalHashMap:sourceHashMap];
                    block(sourceHashMap,destinationHashMap,statusCode);
                }];
        
    }else if (_syncContext.mode==SourceIsLocalDestinationIsLocal){
        HashMap*sourceHashMap=[self _localHashMapViewForUrl:_syncContext.sourceBaseUrl
                                          andTreeWithId:_syncContext.sourceTreeId];
        _syncContext.finalHashMap=sourceHashMap;
        HashMap*destinationHashMap=[self _localHashMapViewForUrl:_syncContext.destinationBaseUrl
                                               andTreeWithId:_syncContext.sourceTreeId];
        if(!destinationHashMap){
            // There is currently no destination hashMap let's create a void one.
            destinationHashMap=[[HashMap alloc] init];
        }
        if(sourceHashMap && destinationHashMap){
            block(sourceHashMap,destinationHashMap,200);
        }else{
            block(sourceHashMap,destinationHashMap,404);
        }
    }else if (_syncContext.mode==SourceIsDistantDestinationIsDistant){
        // CURRENTLY NOT SUPPORTED
    }

}

-(HashMap*)_localHashMapViewForUrl:(NSURL*)url
                 andTreeWithId:(NSString*)identifier{
    
    NSString*hashMapRelativePath=[NSString stringWithFormat:@"%@/%@/%@%@",[url path],identifier,kBsyncHashmapViewPrefixSignature,_syncContext.hashMapViewName];
    NSURL *hashMapUrl=[NSURL fileURLWithPath:hashMapRelativePath];
    
    NSError*stringLoadingError=nil;
    NSString *string=[NSString stringWithContentsOfURL:hashMapUrl
                                              encoding:NSUTF8StringEncoding
                                                 error:&stringLoadingError];
    if(!stringLoadingError){
        NSError*cryptoError=nil;
        NSData *data=[string dataUsingEncoding:NSUTF8StringEncoding];
        // Uncomment to debug
        // [(CryptoHelper*)[Bartleby cryptoDelegate] dumpDebug];
        data=[[Bartleby cryptoDelegate] decryptData:data error:&cryptoError];
        if (cryptoError){
            NSString*message=[[NSString alloc]initWithFormat:@"Get local hash map crypto error %@",cryptoError];
            printf("%s\n",[message cStringUsingEncoding:NSUTF8StringEncoding]);
            return nil;
        }else{
            NSError*__block errorJson=nil;
            @try {
                // We use mutable containers and leaves by default.
                id __block result=nil;
                result=[NSJSONSerialization JSONObjectWithData:data
                                                       options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments
                                                         error:&errorJson];
                
                
                if([result isKindOfClass:[NSDictionary class]]){
                    return [HashMap fromDictionary:result];
                }else{
                    NSString*message=[[NSString alloc]initWithFormat:@"Get local hash map type missmatch on deserialization %@",hashMapUrl];
                    printf("%s\n",[message cStringUsingEncoding:NSUTF8StringEncoding]);
                }
            }
            @catch (NSException *exception) {
                NSString*message=[[NSString alloc]initWithFormat:@"get local hash map :%@",exception];
                printf("Exception on %s\n",[message cStringUsingEncoding:NSUTF8StringEncoding]);
            }
        }
    }
    
    // There is no hashMap or we have encoutered an issue
    [_fileManager createRecursivelyRequiredFolderForPath:hashMapRelativePath];
    return [[HashMap alloc] init];// Return a void HashMap
}

-(void)_distantHashMapViewForUrl:(NSURL*)baseURL
               andTreeWithId:(NSString*)identifier
         withCompletionBlock:(void (^)(HashMap*hashMap,NSInteger statusCode))block{
    
    if( !_syncContext.hashMapViewName || !_syncContext.sourceTreeId || ! _syncContext.credentials.spaceUID  ){
        printf("Invalid context hashMapViewName, sourceTreeId and credentials.spaceUID must be set");
        block(NO,0);
    }else{
        
    // DOWNLOAD
    NSString*treeId =_syncContext.sourceTreeId;
    // Decompose in a GET for the URI then a download task
    NSDictionary *parameters = @{
                                 @"path": [NSString stringWithFormat:@"%@%@",kBsyncHashmapViewPrefixSignature,_syncContext.hashMapViewName],
                                 @"redirect":@"true",
                                 @"returnValue":@"false"
                                 };
    NSURL*url=[baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"/file/tree/%@",treeId]];
    NSURL*urlWithParameters=[url URLByAppendingQueryStringDictionary:parameters];

    // REQUEST
    NSMutableURLRequest *request = [HTTPManager mutableRequestWithTokenInDataSpace:_syncContext.credentials.spaceUID
                                                                           withActionName:@"BartlebySyncGetFile"
                                                                                forMethod:@"GET"
                                                                                      and:urlWithParameters];

    // TASK
    
    [self addCurrentTaskAndResume:[self.urlSession dataTaskWithRequest:request
                                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                         if(!error && response){
                                                             double httpStatusCode=((NSHTTPURLResponse*)response).statusCode;
                                                             if (httpStatusCode==200) {
                                                                 
                                                                 // In this case decryptString is not directly interoparable with decrypt data.
                                                                 // We cannot infer the data encoding
                                                                 // So we need to proceed to multiple transformations.
                                                                 // from data to string and from string to data before to JSON deserialize
                                                                 NSString*cryptoString=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                                                                 
                                                                 NSError *cryptoError = nil;
                                                                 cryptoString=[[Bartleby cryptoDelegate] decryptString:cryptoString error:&cryptoError];
                                                                 if(cryptoError){
                                                                     NSString*message=@"String decryption error";
                                                                     printf("%s\n", [message cStringUsingEncoding:NSUTF8StringEncoding]);
                                                                     block(nil,PdSStatusErrorHashMapDeserialization);
                                                                 } else {
                                                                     data=[cryptoString dataUsingEncoding:NSUTF8StringEncoding];
                                                                 
                                                                     @try {
                                                                         NSError *parseError = nil;
                                                                         NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                                            options:0
                                                                                                                                              error:&parseError];
                                                                         if(parseError){
                                                                             NSString*message=@"Hash map JSON deserialization error";
                                                                             printf("%s\n",[message cStringUsingEncoding:NSUTF8StringEncoding]);
                                                                             block(nil,PdSStatusErrorHashMapDeserialization);
                                                                         }else if( [responseDictionary isKindOfClass:[NSDictionary class]]){
                                                                             HashMap*hashMap=[HashMap fromDictionary:responseDictionary];
                                                                             block(hashMap,((NSHTTPURLResponse*)response).statusCode);
                                                                         }else{
                                                                             NSString*message=@"Hash map deserialization type miss match";
                                                                             printf("%s\n",[message cStringUsingEncoding:NSUTF8StringEncoding]);
                                                                             block(nil,PdSStatusErrorHashMapDeserializationTypeMissMatch);
                                                                         }
                                                                     }
                                                                     @catch (NSException *exception) {
                                                                         NSString*message=[[NSString alloc]initWithFormat:@"%@",exception];
                                                                         printf("Exception on get distant hash map %s\n",[message cStringUsingEncoding:NSUTF8StringEncoding]);
                                                                         block(nil,PdSStatusErrorHashMapFailure);
                                                                     }
                                                                 }
                                                                 
                                                                 
                                                             }else{
                                                                 if (data!=nil) {
                                                                     NSString*message=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                                                                     printf("Fault on get distant hash map  : %s\n",[message cStringUsingEncoding:NSUTF8StringEncoding]);
                                                                 }
                                                                 block(nil,httpStatusCode);
                                                             }
                                                             
                                                         }else{
                                                             NSString*message=[[NSString alloc]initWithFormat:@"get distant hash map :%@",error];
                                                             printf("Error on %s\n",[message cStringUsingEncoding:NSUTF8StringEncoding]);
                                                             block(nil,0);
                                                         }
                                                     }]];
    }
    
}


#pragma  mark - NSURLSession

/**
 *  We use a default session for those tasks.
 *  Notice that the Command Interpreter uses a dedicated session
 *
 *  @return the urlsession.
 */
- (NSURLSession*)urlSession{
    if (!_urlSession){
        _urlSession= [NSURLSession sharedSession];
    }
    return _urlSession;
}


- (void)addCurrentTaskAndResume:(NSURLSessionTask*)task{
    // We could implement a control logic.
    self.currentTask=task;
    [self.currentTask resume];
}


#pragma  mark - Utilities 

/**
 *  Used by swift.
 *
 *  @param name the name of const
 *
 *  @return the value of the const
 */
+ (NSString*_Nullable)valueForConst:(NSString*_Nonnull)name{
    if ([name isEqualToString:@"kBsyncPrefixSignature"])
        return kBsyncPrefixSignature;
   else if ([name isEqualToString:@"kBsyncMetadataFolder"])
        return kBsyncMetadataFolder;
   else if ([name isEqualToString:@"kBsyncHashFileExtension"])
       return kBsyncHashFileExtension;
   else if ([name isEqualToString:@"kBsyncHashMashMapFileName"])
       return kBsyncHashMashMapFileName;
   else if ([name isEqualToString:@"kBsyncHashmapViewPrefixSignature"])
       return kBsyncHashmapViewPrefixSignature;
    return nil;
}


@end