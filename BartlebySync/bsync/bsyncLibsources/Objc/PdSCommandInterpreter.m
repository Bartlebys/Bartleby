//
//  PdSCommandInterpreter.m
//  PdSSync
//
//  Created by Benoit Pereira da Silva on 11/03/2014.
//

#import "PdSCommandInterpreter.h"
#include <stdarg.h>

#ifdef USE_EMBEDDED_OBJC
#import "bsync-Swift.h"
#endif

NSString * const PdSSyncInterpreterWillFinalize = @"PdSSyncInterpreterWillFinalize";
NSString * const PdSSyncInterpreterHasFinalized = @"PdSSyncInterpreterHasFinalized";

typedef void(^ProgressBlock_type)(uint taskIndex,double progress);
typedef void(^CompletionBlock_type)(BOOL success, NSInteger statusCode, NSString*_Nonnull message);

@interface PdSCommandInterpreter ()<NSURLSessionDownloadDelegate>{
    CompletionBlock_type             _completionBlock;
    ProgressBlock_type               _progressBlock;
    PdSFileManager                  *_fileManager;
    NSMutableArray                  *_allCommands;
    BOOL                            _sanitizeAutomatically;
    BOOL                            _hasBeenInterrupted;
    int                             _messageCounter;


}

@property (nonatomic,readonly)NSArray*bunchOfCommand;
@property (nonatomic,readonly)BsyncContext*context;
@property (nonatomic,strong)NSOperationQueue *queue;
@property (nonatomic) NSURLSession*urlSession;

// We store the current task.
// It can be a :
//    - NSURLSessionDataTask
//    - NSURLSessionDownloadTask
//    - NSURLSessionUploadTask
// If necessary you should cast it
@property (nonatomic,strong)NSURLSessionTask*currentTask;

@end

@implementation PdSCommandInterpreter

@synthesize bunchOfCommand  = _bunchOfCommand;
@synthesize context         = _context;

/**
 *
 *
 *  @param bunchOfCommand  the bunch of command
 *  @param context         the interpreter context
 *  @param progressBlock   the progress block
 *  @param completionBlock te completion block
 *
 *  @return the interpreter
 */
+ (PdSCommandInterpreter*)interpreterWithBunchOfCommand:(NSArray*)bunchOfCommand
                                                context:(BsyncContext*)context
                                          progressBlock:(void(^)(uint taskIndex,double progress))progressBlock
                                     andCompletionBlock:(void(^)(BOOL success, NSInteger statusCode,NSString*_Nonnull message))completionBlock{

    return [[PdSCommandInterpreter alloc] initWithBunchOfCommand:bunchOfCommand
                                                         context:context
                                                   progressBlock:progressBlock
                                              andCompletionBlock:completionBlock];
}

/**
 *   The dedicated initializer.
 *
 *  @param bunchOfCommand  the bunch of command
 *  @param context         the interpreter context
 *  @param progressBlock   the progress block
 *  @param completionBlock te completion block
 *
 *  @return the interpreter
 */
- (instancetype)initWithBunchOfCommand:(NSArray*)bunchOfCommand
                               context:(BsyncContext*)context
                         progressBlock:(void(^)(uint taskIndex,double progress))progressBlock
                    andCompletionBlock:(void(^)(BOOL success, NSInteger statusCode,NSString*message))completionBlock;{
    self=[super init];
    if(self){
        self->_bunchOfCommand=[bunchOfCommand copy];
        self->_context=context;
        self->_progressBlock=progressBlock?[progressBlock copy]:nil;
        self->_completionBlock=completionBlock?[completionBlock copy]:nil;
        self->_fileManager=[PdSFileManager sharedInstance];
        self->_messageCounter=0;
        self->_sanitizeAutomatically=YES;

        if(self->_context.mode==SourceIsDistantDestinationIsDistant ){
            [NSException raise:@"TemporaryException"
                        format:@"SourceIsDistantDestinationIsDistant is currently not supported"];
        }


        if([context isValid] && _bunchOfCommand){

            self.queue=[[NSOperationQueue alloc] init];
            self.queue.name=[NSString stringWithFormat:@"com.pereira-da-silva.PdSSync.CommandInterpreter.%@",@([self hash])];
            [self.queue setMaxConcurrentOperationCount:1];// Sequential
            [self _run];

        }else{
            if(self->_completionBlock){
                _completionBlock(NO, PdsStatusErrorInvalidArgument,@"sourceUrl && destinationUrl && bunchOfCommand && finalHashMap are required");
            }
        }
    }
    return self;
}


+(id)encodeCreate:(NSString*)source destination:(NSString*)destination{
    if(source && destination){
        return [NSString stringWithFormat:@"[%@,\"%@\",\"%@\"]", @(BCreate),destination,source];
    }
    return nil;
}

+(id)encodeUpdate:(NSString*)source destination:(NSString*)destination{
    if(source && destination){
        return [NSString stringWithFormat:@"[%@,\"%@\",\"%@\"]", @(BUpdate),destination,source];
    }
    return nil;
}

+(id)encodeCopy:(NSString*)source destination:(NSString*)destination{
    if(source && destination){
        return [NSString stringWithFormat:@"[%@,\"%@\",\"%@\"]",@(BCopy),destination,source];
    }else{
        return nil;
    }
}

+(id)encodeMove:(NSString*)source destination:(NSString*)destination{
    if(source && destination){
        return [NSString stringWithFormat:@"[%@,\"%@\",\"%@\"]", @(BMove),destination,source];
    }else{
        return nil;
    }
}

+(id)encodeRemove:(NSString*)destination{
    if(destination){
        return [NSString stringWithFormat:@"[%@,\"%@\"]", @(BDelete),destination];
    }else{
        return nil;
    }
}


#pragma mark - private methods

- (void)_run{
    _hasBeenInterrupted=NO;
    if(_sanitizeAutomatically){
        [self _sanitize:@""];
    }

    if([_bunchOfCommand count]>0){
        NSMutableArray*__block creativeCommands=[NSMutableArray array];
        _allCommands=[NSMutableArray array];

        // First pass we dicriminate creative for un creative commands
        // Creative commands requires for example download or an upload.
        // Copy or move are "not creative" as we move or copy a existing resource

        for (id encodedCommand in _bunchOfCommand) {
            NSArray*cmdAsAnArray=[self _encodedCommandToArray:encodedCommand];
            if (!_hasBeenInterrupted) {
                if(cmdAsAnArray){
                    if([[cmdAsAnArray objectAtIndex:0] intValue]==BCreate||
                       [[cmdAsAnArray objectAtIndex:0] intValue]==BUpdate){
                        [creativeCommands addObject:cmdAsAnArray];
                    }
                    [_allCommands addObject:cmdAsAnArray];
                }
                if(![encodedCommand isKindOfClass:[NSString class]]){
                    [self _interruptOnFault:[NSString stringWithFormat:@"Illegal command %@",encodedCommand]];
                }
            }
        }

        if (!_hasBeenInterrupted) {
            // Add all creational commands
            for (NSArray*cmd in creativeCommands) {
                [self->_queue addOperationWithBlock:^{
                    // The queue will be suspended and restarted with _commandInProgress and _nextCommand
                    [self _runCommandFromArrayOfArgs:cmd];
                }];
            }

            [_queue addOperationWithBlock:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:PdSSyncInterpreterWillFinalize
                                                                    object:self];
            }];
            [_queue addOperationWithBlock:^{
                if(self.finalizationDelegate){
                    [self.finalizationDelegate readyForFinalization:self];
                }else{
                    [self finalize];
                }
            }];
        }
    }else{
        if(_sanitizeAutomatically){
            [self _sanitize:@""];
        }else{
        }
        _completionBlock(YES, PdsStatusErrorNoError, @"There was no command to execute");
    }
}

/**
 * Called by the delegate to conclude the operations
 */
- (void)finalize{
    // The creative commands will produce UNPREFIXING temp files
    // The "unCreative" commands will be executed during finalization
    [self _finalizeWithCommands:self->_allCommands];

    if(_sanitizeAutomatically){
        [self _sanitize:@""];
    }else{

    }
}

-(void)_sanitize:(NSString*)relativePath{
    if (self->_context.mode==SourceIsDistantDestinationIsLocal||
        self->_context.mode==SourceIsLocalDestinationIsLocal){

        // SANITIZE LOCALLY
        NSString *folderPath=[self _absoluteLocalPathFromRelativePath:relativePath
                                                           toLocalUrl:_context.destinationBaseUrl
                                                           withTreeId:_context.destinationTreeId
                                                            addPrefix:NO];

        NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
        NSDirectoryEnumerator *dirEnum =[_fileManager enumeratorAtURL:[NSURL URLWithString:folderPath]
                                           includingPropertiesForKeys:keys
                                                              options:0
                                                         errorHandler:^BOOL(NSURL *url, NSError *error) {
                                                             [self _progressMessage:@"ERROR when enumerating  %@ %@",url, [error localizedDescription]];
                                                             return YES;
                                                         }];
        NSURL *file;
        NSError*removeFileError=nil;
        while ((file = [dirEnum nextObject])) {
            NSString *filePath=[file path];
            if([self _filePathDeletionAllowed:filePath]){
                [_fileManager removeItemAtPath:filePath
                                         error:&removeFileError];
            }
        }

        if(removeFileError){
            [self _interruptOnFault:@"Sanitizing error"];
        }
    }
}


- (BOOL)_filePathDeletionAllowed:(NSString*)path{
    NSArray*exclusion=@[@".DS_Store"];
    NSInteger minPrefixedLength=30+[kBsyncPrefixSignature length];
    if([[path lastPathComponent] length]>minPrefixedLength&&
       [exclusion indexOfObject:[path lastPathComponent]]==NSNotFound&&
       [[path lastPathComponent] rangeOfString:kBsyncPrefixSignature].location!=NSNotFound &&
       ![[path substringFromIndex:[path length]-1] isEqualToString:@"/"]
       ){
        return YES;
    }else{
        return NO;
    }
}





- (NSArray*)_encodedCommandToArray:(NSString*)encoded{
    NSData *data = [encoded dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    id cmd = [NSJSONSerialization JSONObjectWithData:data
                                             options:0
                                               error:&error];
    if(error && !encoded){
        // We stop the process on any error
        [self _interruptOnFault:[NSString stringWithFormat:@"Cmd deserialization failed %@ : %@",encoded,[error localizedDescription]]];
    }
    if(cmd && [cmd isKindOfClass:[NSArray class]] && [cmd count]>0){
        return cmd;
    } else {
        [self _interruptOnFault:[NSString stringWithFormat:@"Invalid command (encoding) : %@, %@",encoded,cmd]];
    }
    return nil;
}


-(void)_runCommandFromArrayOfArgs:(NSArray*)cmd{
    [self _commandInProgress];
    if(cmd && [cmd isKindOfClass:[NSArray class]] && [cmd count]>0){
        int cmdName=[[cmd objectAtIndex:0] intValue];
        NSString*arg1= [cmd count]>1?[cmd objectAtIndex:1]:nil;
        NSString*arg2=[cmd count]>2?[cmd objectAtIndex:2]:nil;
        switch (cmdName) {
            case (BCreate):{
                if(arg1 && arg2){
                    [self _runCreateOrUpdate:arg2 destination:arg1];
                }else{
                    [self _interruptOnFault:[NSString stringWithFormat:@"Invalid command BCreate : %i arg1:%@ arg2:%@",cmdName,arg1?arg1:@"nil",arg2?arg2:@"nil"]];
                }
                break;
            }
            case (BUpdate):{
                if(arg1 && arg2){
                    [self _runCreateOrUpdate:arg2 destination:arg1];
                }else{
                    [self _interruptOnFault:[NSString stringWithFormat:@"Invalid command BUpdate : %i arg1:%@ arg2:%@",cmdName,arg1?arg1:@"nil",arg2?arg2:@"nil"]];
                }
                break;
            }
            case (BCopy):{
                if(arg1 && arg2){
                    [self _runCopy:arg2 destination:arg1];
                }else{
                    [self _interruptOnFault:[NSString stringWithFormat:@"Invalid command BCopy : %i arg1:%@ arg2:%@",cmdName,arg1?arg1:@"nil",arg2?arg2:@"nil"]];
                }
                break;
            }
            case (BMove):{
                if(arg1 && arg2){
                    [self _runMove:arg2 destination:arg1];
                }else{
                    [self _interruptOnFault:[NSString stringWithFormat:@"Invalid command BMove : %i arg1:%@ arg2:%@",cmdName,arg1?arg1:@"nil",arg2?arg2:@"nil"]];
                }
                break;
            }
            case (BDelete):{
                if(arg1){
                    [self _runDelete:arg1];
                }else{
                    [self _interruptOnFault:[NSString stringWithFormat:@"Invalid command BDelete : %i arg1:%@ ",cmdName,arg1?arg1:@"nil"]];
                }
                break;
            }
            default:
                [self _interruptOnFault:[NSString stringWithFormat:@"The command default %i is currently not supported",cmdName]];
                break;
        }
    }else{
        [self _interruptOnFault:[NSString stringWithFormat:@"Invalid command global %@",cmd?cmd:@"nil"]];
    }
}


- (void)_commandInProgress{
    dispatch_barrier_sync(dispatch_get_main_queue(), ^{
        [_queue setSuspended:YES];
    });
}


- (void)_nextCommand{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_queue setSuspended:NO];
    });

}




#pragma  mark - Commands runtime -

#pragma  mark  Create or Update

-(void)_runCreateOrUpdate:(NSString*)source destination:(NSString*)destination{
    if((self->_context.mode==SourceIsLocalDestinationIsDistant)){

        // UPLOAD
        //_context.destinationBaseUrl;

        NSURL *sourceURL=[_context.sourceBaseUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",_context.sourceTreeId,source]];
        NSString *URLString =[[_context.destinationBaseUrl absoluteString] stringByAppendingFormat:@"/uploadFileTo/tree/%@/?syncIdentifier=%@&destination=%@",
                              _context.destinationTreeId, _context.syncID, destination];

        NSURL*url=[NSURL URLWithString:URLString];
        // REQUEST
        NSURLRequest *immutableRequest = [HTTPManager requestWithTokenInRegistryWithUID:_context.credentials.user.registryUID
                                                                              withActionName:@"BartlebySyncUploadFileTo"
                                                                                   forMethod:@"POST"
                                                                                         and:url];

        NSMutableURLRequest*request=[immutableRequest mutableCopy];


        NSString*lastChar=[source substringFromIndex:[source length]-1];
        if(![lastChar isEqualToString:@"/"]){

            // It is a file
            // Add the "file" Headers
            // http://www.w3.org/Protocols/rfc2616/rfc2616-sec19.html#sec19.5.1


            NSString*cdvalue=[NSString stringWithFormat:@"attachment; name=\"%@\"; filename=\"%@\"", @"source", [sourceURL lastPathComponent]];
            [request setValue:cdvalue forHTTPHeaderField:@"Content-Disposition"];

            NSString*mimeType=@"application/octet-stream";
            [request setValue:mimeType forHTTPHeaderField:@"Content-Type"];
            [request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];

            [self _progressMessage:@"Uploading %@", [sourceURL path]];

            // We use an upload task.
            [self addCurrentTaskAndResume:[[self urlSession] uploadTaskWithRequest:request
                                                                          fromFile:sourceURL
                                                                 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                                     if (response){
                                                                         NSInteger httpStatusCode=[(NSHTTPURLResponse*)response statusCode];
                                                                         bprint(@"%@ => %@", request.URL.absoluteString, @(httpStatusCode));
                                                                         if (httpStatusCode>=200 && httpStatusCode<300) {
                                                                             [self _nextCommand];
                                                                             return ;
                                                                         }
                                                                     }
                                                                     if (data!=nil) {
                                                                         NSString*message=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                                                                         bprint(@"Fault on upload: %@", message);
                                                                     }

                                                                     NSString *msg=@"No message";
                                                                     if (error) {
                                                                         msg=[NSString stringWithFormat:@"Error on file upload: %@",[self _stringFromError:error]];
                                                                     }
                                                                     [self _interruptOnFault:msg];

                                                                 }]];


        } else {
            // It is a folder.
            // We donnot need any header

            [self _progressMessage:@"Creation of distant folder %@", [sourceURL absoluteString]];

            // We use a data task.
            [self addCurrentTaskAndResume:[[self urlSession] dataTaskWithRequest:request
                                                               completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

                                                                   if (response) {
                                                                       NSInteger httpStatusCode=[(NSHTTPURLResponse*)response statusCode];
                                                                       bprint(@"%@ => %@", request.URL.absoluteString, @(httpStatusCode));
                                                                       if (httpStatusCode>=200 && httpStatusCode<300) {
                                                                           [self _nextCommand];
                                                                           return ;
                                                                       }
                                                                   }
                                                                   if (data!=nil) {
                                                                       NSString*message=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                                                                       bprint(@"Fault on distant folder creation: %@", message);
                                                                   }

                                                                   NSString *msg=@"No message";
                                                                   if (error) {
                                                                       msg=[NSString stringWithFormat:@"Error on distant folder creation: %@",[self _stringFromError:error]];
                                                                   }
                                                                   [self _interruptOnFault:msg];
                                                               }]];

        }


    }else if (self->_context.mode==SourceIsDistantDestinationIsLocal){

        // If it is a folder we gonna create it directly

        BOOL isAFolder= [[destination substringFromIndex:[destination length]-1] isEqualToString:@"/"];
        if(isAFolder){
            NSString*localFolderPath=[self _absoluteLocalPathFromRelativePath:destination
                                                                   toLocalUrl:_context.destinationBaseUrl
                                                                   withTreeId:_context.destinationTreeId
                                                                    addPrefix:NO];
            if([_fileManager createRecursivelyRequiredFolderForPath:localFolderPath]){
                [self _nextCommand];
            }else{
                NSString *msg=[NSString stringWithFormat:@"Error when creating %@",localFolderPath];
                [self _interruptOnFault:msg];
                return;
            }

        }else{


            // DOWNLOAD
            NSString*treeId=_context.sourceTreeId;
            // Decompose in a GET for the URI then a download task
            NSString *urlString = [NSString stringWithFormat:@"%@/file/tree/%@/?path=%@&redirect=true&returnValue=false",
                                   [_context.sourceBaseUrl absoluteString],
                                   treeId,
                                   [source stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]]
                                   ];

            NSURL *url = [NSURL URLWithString:urlString];

            // REQUEST
            NSURLRequest *request = [HTTPManager requestWithTokenInRegistryWithUID:_context.credentials.user.registryUID
                                                                                  withActionName:@"BartlebySyncGetFile"
                                                                                       forMethod:@"GET"
                                                                                             and:url];


            [self _progressMessage:@"Downloading %@", url];


            // Prepare the destination With a Sync Prefix
            NSString*__block p=[self _absoluteLocalPathFromRelativePath:destination
                                                             toLocalUrl:_context.destinationBaseUrl
                                                             withTreeId:_context.destinationTreeId
                                                              addPrefix:YES];


            [_fileManager createRecursivelyRequiredFolderForPath:p];

            [self addCurrentTaskAndResume:[[self urlSession]downloadTaskWithRequest:request
                                                                  completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                                      if (!error){
                                                                          NSError*moveItemError=nil;
                                                                          NSURL*destinationURL=[NSURL fileURLWithPath:p];
                                                                          [_fileManager moveItemAtURL:location
                                                                                                toURL:destinationURL
                                                                                                error:&moveItemError];
                                                                          if(moveItemError){
                                                                              NSString*message=[NSString stringWithFormat:@"Error when moving tmp loaded file %@",[self _stringFromError:error]];
                                                                              [self _interruptOnFault:message];
                                                                              return ;
                                                                          }else{
                                                                              [self _nextCommand];
                                                                              return ;
                                                                          }
                                                                      }
                                                                      if (response) {
                                                                          NSInteger httpStatusCode=[(NSHTTPURLResponse*)response statusCode];
                                                                          NSDictionary*headers=[(NSHTTPURLResponse*)response allHeaderFields];
                                                                          NSString*message=[[NSString alloc]initWithFormat:@"Http Status code: %@\n%@",@(httpStatusCode),headers];
                                                                          bprint(@"Fault on download: %@", message);
                                                                      }

                                                                      NSString *msg=@"No message";
                                                                      if (error) {
                                                                          msg=[NSString stringWithFormat:@"Error on distant folder creation: %@",[self _stringFromError:error]];
                                                                      }
                                                                      [self _interruptOnFault:msg];

                                                                  }]];
        };


    }else if (self->_context.mode==SourceIsLocalDestinationIsLocal){
        // If it is a folder we gonna create it directly

        BOOL isAFolder= [[destination substringFromIndex:[destination length]-1] isEqualToString:@"/"];



        // Copy the destination file with a Sync Prefix

        NSString*absoluteSource=[self _absoluteLocalPathFromRelativePath: source
                                                              toLocalUrl:  _context.sourceBaseUrl
                                                              withTreeId: _context.sourceTreeId
                                                               addPrefix: NO];

        NSString*absoluteDestination=[self _absoluteLocalPathFromRelativePath: destination
                                                                   toLocalUrl: _context.destinationBaseUrl
                                                                   withTreeId: _context.destinationTreeId
                                                                    addPrefix: YES];

        [_fileManager createRecursivelyRequiredFolderForPath:absoluteDestination];

        if (!isAFolder){
            NSError*error=nil;

            [_fileManager copyItemAtPath:absoluteSource
                                  toPath:absoluteDestination
                                   error:&error];


            if(error){
                if(![_fileManager fileExistsAtPath:absoluteDestination]){
                    // NSFileManagerDelegate seems not to handle correctly this case
                    [self _progressMessage:@"Error on copyItemAtPath \nfrom %@ \nto %@ \n%@ ",absoluteSource,absoluteDestination ,[error localizedDescription]];
                }
                [self _interruptOnFault:[error localizedDescription]];
            }

        }


        [self _nextCommand];


    }else if (self->_context.mode==SourceIsDistantDestinationIsDistant){
        // CURRENTLY NOT SUPPORTED
    }
}

#pragma  mark  Finalize


- (void)_finalizeWithCommands:(NSArray*)commands{

    [self _progressMessage:@"Finalizing %@ cmds", @([commands count])];

    NSDictionary *hashMapDict = [_context.finalHashMap dictionaryRepresentation];
    NSString *hashMapJsonString = [self _encodetoJson: hashMapDict];
    bprint(@"hashmap: %@", hashMapJsonString);
    NSError *cryptoError=nil;
    NSString *hashMapCryptedString = [[Bartleby cryptoDelegate] encryptString:hashMapJsonString error:&cryptoError];
    if(cryptoError){
        [self _interruptOnFault:[NSString stringWithFormat:@"CryptoError: %@", cryptoError]];
        return;
    }
    bprint(@"crypted hashmap: %@", hashMapCryptedString);

    if((self->_context.mode==SourceIsLocalDestinationIsDistant)||
       self->_context.mode==SourceIsDistantDestinationIsDistant){


        NSString *URLString =[[_context.destinationBaseUrl absoluteString] stringByAppendingFormat:@"/finalizeTransactionIn/tree/%@/",_context.destinationTreeId];
        NSDictionary *parameters = @{
                                     @"syncIdentifier": _context.syncID,
                                     @"commands":[self _encodetoJson:commands],
                                     @"hashMap":hashMapCryptedString
                                     };

        NSData *jsonBodyData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

        NSURL*url = [NSURL URLWithString:URLString];

        // REQUEST
        NSURLRequest *immutableRequest = [HTTPManager requestWithTokenInRegistryWithUID:_context.credentials.user.registryUID
                                                                              withActionName:@"BartlebySyncFinalizeTransactionIn"
                                                                                   forMethod:@"POST"
                                                                                         and:url];

        NSMutableURLRequest*request=[immutableRequest mutableCopy];

        [request setHTTPBody:jsonBodyData];

        // DATA TASK
        [self addCurrentTaskAndResume:[[self urlSession] dataTaskWithRequest:request
                                                           completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                               if (response) {
                                                                   NSInteger httpStatusCode=[(NSHTTPURLResponse*)response statusCode];
                                                                   bprint(@"%@\nHTTP Status Code = %@", request.URL.absoluteString, @(httpStatusCode));
                                                                   if (httpStatusCode>=200 && httpStatusCode<300) {
                                                                       [self _successFullEnd];
                                                                       return ;
                                                                   }
                                                               }
                                                               if (data!=nil) {
                                                                   NSString*message=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                                                                   bprint(@"(!) Fault on finalization: %@", message);
                                                               }

                                                               NSString *msg=@"No message";
                                                               if (error) {
                                                                   msg=[NSString stringWithFormat:@"(!) Error on finalization: %@",[self _stringFromError:error]];
                                                               }
                                                               [self _interruptOnFault:msg];
                                                           }]];

    }else if (self->_context.mode==SourceIsDistantDestinationIsLocal||
              self->_context.mode==SourceIsLocalDestinationIsLocal){

        // EXECUTE CREATIVES COMMANDS


        // SORT THE COMMANDS By BsyncCommand value order
        // Creation and Update will be done before Moves, Copies and Updates
        // BCreate   = 0
        // BUpdate   = 1
        // BCopy     = 2
        // BMove     = 3
        // BDelete   = 4


        NSMutableArray*secondPass=[NSMutableArray array];

        NSArray*sortedCommand=[commands sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSArray*a1=(NSArray*)obj1;
            NSArray*a2=(NSArray*)obj2;
            if ([[a1 objectAtIndex:BCommand] integerValue] > [[a2 objectAtIndex:BCommand] integerValue]){
                return NSOrderedDescending;
            }else{
                return NSOrderedAscending;
            }
        }];


        bprint(@"sortedCommand %@",sortedCommand);

        for (NSArray *cmd in sortedCommand) {
            NSString *destination=[cmd objectAtIndex:BDestination];
            NSUInteger command=[[cmd objectAtIndex:BCommand] integerValue];
            BOOL isAFolder=[[destination substringFromIndex:[destination length]-1] isEqualToString:@"/"];

            if(command==BCreate || command==BUpdate){
                if(!isAFolder){


                    NSString*destinationPrefixedFilePath=[self _absoluteLocalPathFromRelativePath:destination
                                                                                       toLocalUrl:_context.destinationBaseUrl
                                                                                       withTreeId:_context.destinationTreeId
                                                                                        addPrefix:YES];

                    NSString*destinationFileWithoutPrefix=[self _absoluteLocalPathFromRelativePath:destination
                                                                                        toLocalUrl:_context.destinationBaseUrl
                                                                                        withTreeId:_context.destinationTreeId
                                                                                         addPrefix:NO];

                    [_fileManager createRecursivelyRequiredFolderForPath:destinationFileWithoutPrefix];

                    NSError*error=nil;

                    // UN PREFIX
                    [_fileManager moveItemAtPath:destinationPrefixedFilePath
                                          toPath:destinationFileWithoutPrefix
                                           error:&error];

                    if(error){
                        NSString*message = [NSString stringWithFormat: @"Error during local finalization on moveItemAtPath\n\t- Src: %@\n\t- Dst: %@\n\t- Error: %@ ", destinationPrefixedFilePath, destinationFileWithoutPrefix,[error localizedDescription]];
                        bprint(@"%@", message)
                        [self _progressMessage:message];
                        [self _interruptOnFault:[error localizedDescription]];
                        return;
                    }
                }
                continue;

            }

            if (command==BMove || command==BCopy){
                NSString *source=[cmd objectAtIndex:BSource];

                if (![_fileManager fileExistsAtPath:source]){
                    // If we encounter a problem of move / copy dependency
                    // We store the command for a second pass.
                    // And we defer the command interpretation.
                    [secondPass addObject:cmd];

                }else{
                    if(command==BMove){
                        [self _runMove:source
                           destination:destination];
                    }

                    if(command==BCopy){
                        NSString *source=[cmd objectAtIndex:BSource];
                        [self _runCopy:source
                           destination:destination];
                    }
                }
            }

            if(command==BDelete){
                [self _runDelete:destination];
            }

        }

        // Second pass to deal with defered commands.
        for (NSArray*cmd in secondPass) {
            NSString *source=[cmd objectAtIndex:BSource];
            NSString *destination=[cmd objectAtIndex:BDestination];
            NSUInteger command=[[cmd objectAtIndex:BCommand] integerValue];
            if(command==BMove){
                [self _runMove:source
                   destination:destination];
            }
            if(command==BCopy){
                [self _runCopy:source
                   destination:destination];
            }
        }

        // Write the Hash Map
        NSString*relativePathOfHashMapFile=[_context.destinationTreeId stringByAppendingFormat:@"/%@/%@",kBsyncMetadataFolder,kBsyncHashMashMapFileName];
        NSURL *hashMapFileUrl=[_context.destinationBaseUrl URLByAppendingPathComponent:relativePathOfHashMapFile];



        NSError*jsonHashMapError=nil;
        [hashMapCryptedString writeToFile:[hashMapFileUrl path]
                               atomically:YES
                                 encoding:NSUTF8StringEncoding error:&jsonHashMapError];


        if(jsonHashMapError){
            bprint(@"%@",[jsonHashMapError localizedDescription]);
            // @md this is not normal (we should interrupt if there is a hash map issue;
            // May be we should delete then -> write the Hashmap to perform securely
            //[self _interruptOnFault:[jsonHashMapError description]];
            //return;
        }else{
            _completionBlock(YES, PdsStatusErrorNoError, @"");
            [[NSNotificationCenter defaultCenter] postNotificationName:PdSSyncInterpreterHasFinalized
                                                                object:self];
        }

    }
}


#pragma  mark  Copy

-(void)_runCopy:(NSString*)source destination:(NSString*)destination{
    BsyncMode mode = self.context.mode;
    if (mode == SourceIsLocalDestinationIsDistant) {
        //DONE DURING FINALIZATION
    } else if (self->_context.mode==SourceIsDistantDestinationIsDistant){
        // CURRENTLY NOT SUPPORTED
    } else {


        NSString*absoluteSource=[self _absoluteLocalPathFromRelativePath: source
                                                              toLocalUrl: _context.destinationBaseUrl// it is a copy that occurs on the destination (!)
                                                              withTreeId: _context.destinationTreeId
                                                               addPrefix: NO];

        NSString*absoluteDestination=[self _absoluteLocalPathFromRelativePath: destination
                                                                   toLocalUrl: _context.destinationBaseUrl
                                                                   withTreeId: _context.destinationTreeId
                                                                    addPrefix: NO];

        [_fileManager createRecursivelyRequiredFolderForPath:absoluteDestination];


        NSError*error=nil;

        [_fileManager copyItemAtPath:absoluteSource
                              toPath:absoluteDestination
                               error:&error];
        /*
         if(error){
         if(![_fileManager fileExistsAtPath:absoluteDestination]){
         // NSFileManagerDelegate seems not to handle correctly this case
         [self _progressMessage:@"Error on copyItemAtPath \nfrom %@ \nto %@ \n%@ ",absoluteSource,absoluteDestination ,[error localizedDescription]];
         }
         [self _interruptOnFault:[error localizedDescription]];
         }*/

    }
}


#pragma  mark  Move

-(void)_runMove:(NSString*)source destination:(NSString*)destination{
    BsyncMode mode = self.context.mode;
    if (mode == SourceIsLocalDestinationIsDistant) {
        //DONE DURING FINALIZATION
    } else if (self->_context.mode==SourceIsDistantDestinationIsDistant){
        // CURRENTLY NOT SUPPORTED
    } else {
        // MOVE LOCALLY
        NSString*absoluteSource=[self _absoluteLocalPathFromRelativePath:source
                                                              toLocalUrl:_context.destinationBaseUrl // it is a move that occurs on the destination (!)
                                                              withTreeId:_context.destinationTreeId
                                                               addPrefix:NO];

        NSString*absoluteDestination=[self _absoluteLocalPathFromRelativePath:destination
                                                                   toLocalUrl:_context.destinationBaseUrl
                                                                   withTreeId:_context.destinationTreeId
                                                                    addPrefix:NO];

        [_fileManager createRecursivelyRequiredFolderForPath:absoluteDestination];

        NSError*error=nil;
        [_fileManager moveItemAtPath:absoluteSource
                              toPath:absoluteDestination
                               error:&error];
        /*
         if(error){
         if(![_fileManager fileExistsAtPath:absoluteDestination]){
         [self _progressMessage:@"Error on moveItemAtPath \nfrom %@ \nto %@ \n%@ ",absoluteSource,absoluteDestination,[error localizedDescription]];
         [self _interruptOnFault:[error localizedDescription]];
         }
         }*/
    }
}

#pragma  mark  Delete


-(void)_runDelete:(NSString*)destination{
    if((self->_context.mode==SourceIsLocalDestinationIsDistant)){
        //DONE DURING FINALIZATION
    }else if (self->_context.mode==SourceIsDistantDestinationIsLocal||
              self->_context.mode==SourceIsLocalDestinationIsLocal){
        // DELETE LOCALLY
        NSString*absoluteDestination=[self _absoluteLocalPathFromRelativePath:destination
                                                                   toLocalUrl:_context.destinationBaseUrl
                                                                   withTreeId:_context.destinationTreeId
                                                                    addPrefix:NO];

        if([_fileManager fileExistsAtPath:absoluteDestination]){
            NSError*error=nil;
            [_fileManager removeItemAtPath:absoluteDestination error:&error];
            if(error){
                [self _progressMessage:@"Error on removeItemAtPath \nfrom %@ \n%@ ",absoluteDestination,[error localizedDescription]];
                [self _interruptOnFault:[error localizedDescription]];
            }
        }
    }else if (self->_context.mode==SourceIsDistantDestinationIsDistant){
        // CURRENTLY NOT SUPPORTED
    }
}


#pragma mark utils

- (NSString*)_stringFromError:(NSError*)error{
    NSMutableString*result=[NSMutableString string];
    if([error localizedDescription]){
        [result appendFormat:@" debugDescription : %@",[error localizedDescription]];
    }
    if([error debugDescription]){
        [result appendFormat:@" debugDescription : %@",[error debugDescription]];
    }

    return result;
}



- (NSString*)_absoluteLocalPathFromRelativePath:(NSString*)relativePath
                                     toLocalUrl:(NSURL*)localUrl
                                     withTreeId:(NSString*)treeID
                                      addPrefix:(BOOL)addPrefix{
    if(!addPrefix || [[relativePath substringFromIndex:[relativePath length]-1] isEqualToString:@"/"]){
        // We donnot prefix the folders.
        return [NSString stringWithFormat:@"%@/%@/%@",[localUrl path],treeID,relativePath];
    }else{
        NSMutableArray*components=[NSMutableArray arrayWithArray:[relativePath componentsSeparatedByString:@"/"]];
        NSString*lastComponent=(NSString*)[components lastObject];
        lastComponent=[NSString stringWithFormat:@"%@%@",self->_context.syncID,lastComponent];
        [components replaceObjectAtIndex:[components count]-1 withObject:lastComponent];
        NSString*prefixedRelativePath=[components componentsJoinedByString:@"/"];
        NSString*path= [NSString stringWithFormat:@"%@/%@/%@",[localUrl path],treeID,prefixedRelativePath];
        return path;
    }
}





#pragma mark -

- (void)_successFullEnd{
    _completionBlock(YES, PdsStatusErrorNoError, @"");
    [[NSNotificationCenter defaultCenter] postNotificationName:PdSSyncInterpreterHasFinalized
                                                        object:self];
}


- (void)_interruptOnFault:(NSString*)faultMessage{
    bprint(@"INTERUPT ON FAULT: %@", faultMessage);

    [self _progressMessage:@"INTERUPT ON FAULT %@",faultMessage];
    [self->_queue cancelAllOperations];
    self->_hasBeenInterrupted=YES;
    self->_completionBlock(NO, PdsStatusErrorInterrupted,faultMessage);
}


+ (NSMutableArray*)commandsFromDeltaPathMap:(DeltaPathMap*)deltaPathMap{

    /*

     BCreate   = 0 , // W destination and source
     BUpdate   = 1 , // W destination and source
     BMove     = 2 , // R source W destination
     BCopy     = 3 , // R source W destination
     BDelete   = 4   // W source

     */

    NSMutableArray*commands=[NSMutableArray array];
    for (NSString*identifier in deltaPathMap.createdPaths) {
        [commands addObject:[PdSCommandInterpreter encodeCreate:identifier destination:identifier]];
    }
    for (NSString*identifier in deltaPathMap.updatedPaths) {
        [commands addObject:[PdSCommandInterpreter encodeUpdate:identifier destination:identifier]];
    }
    for (NSArray*movementArray in deltaPathMap.movedPaths) {
        NSString*source=[movementArray objectAtIndex:1];
        NSString*destination=[movementArray objectAtIndex:0];
        [commands addObject:[PdSCommandInterpreter encodeMove:source destination:destination]];
    }
    for (NSArray*copiesArray in deltaPathMap.copiedPaths) {
        NSString*source=[copiesArray objectAtIndex:1];
        NSString*destination=[copiesArray objectAtIndex:0];
        [commands addObject:[PdSCommandInterpreter encodeCopy:source destination:destination]];
    }
    for (NSString*identifier in deltaPathMap.deletedPaths) {
        [commands addObject:[PdSCommandInterpreter encodeRemove:identifier]];
    }
    return commands;
}


#pragma mark - Json


- (NSString*)_encodetoJson:(id)object{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:0
                                                         error:&error];
    if (jsonData) {
        return [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    } else {
        return [error localizedDescription];
    }
}


- (void)_progressMessage:(NSString*)format, ... {
    _messageCounter++;
    if(self.finalizationDelegate){
        va_list vl;
        va_start(vl, format);
        NSString* message = [[NSString alloc] initWithFormat:format
                                                   arguments:vl];
        [self.finalizationDelegate progressMessage:[NSString stringWithFormat:@"%i# %@",_messageCounter,message]];
        va_end(vl);
    }
}

#pragma  mark - NSURLSession


- (void)addCurrentTaskAndResume:(NSURLSessionTask*)task{
    // We could implement a control logic.
    self.currentTask=task;
    [self.currentTask resume];
}


- (NSURLSession*)urlSession{
    if (!self->_urlSession){
        // We currently use the shared session
        _urlSession=[NSURLSession sharedSession];
    }
    return _urlSession;
}


#pragma  mark NSURLSessionDelegate

/*
 * Messages related to the URL session as a whole
 */


/* The last message a session receives.  A session will only become
 * invalid because of a systemic error or when it has been
 * explicitly invalidated, in which case the error parameter will be nil.
 */
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error{

}

/* If implemented, when a connection level authentication challenge
 * has occurred, this delegate will be given the opportunity to
 * provide authentication credentials to the underlying
 * connection. Some types of authentication will apply to more than
 * one request on a given connection to a server (SSL Server Trust
 * challenges).  If this delegate message is not implemented, the
 * behavior will be to use the default handling, which may involve user
 * interaction.
 */
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition position, NSURLCredential * __nullable credential))completionHandler{

}

/* If an application has received an
 * -application:handleEventsForBackgroundURLSession:completionHandler:
 * message, the session delegate will receive this message to indicate
 * that all messages previously enqueued for this session have been
 * delivered.  At this time it is safe to invoke the previously stored
 * completion handler, or to begin any internal updates that will
 * result in invoking the completion handler.
 */
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{

}



#pragma  mark NSURLSessionTaskDelegate

/*
 * Messages related to the operation of a specific task.
 */


/* An HTTP request is attempting to perform a redirection to a different
 * URL. You must invoke the completion routine to allow the
 * redirection, allow the redirection with a modified request, or
 * pass nil to the completionHandler to cause the body of the redirection
 * response to be delivered as the payload of this request. The default
 * is to follow redirections.
 *
 * For tasks in background sessions, redirections will always be followed and this method will not be called.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * __nullable))completionHandler{
    // Redirects on 307
    completionHandler(request);
}

/* The task has received a request specific authentication challenge.
 * If this delegate is not implemented, the session specific authentication challenge
 * will *NOT* be called and the behavior will be the same as using the default handling
 * disposition.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler{

}

/* Sent if a task requires a new, unopened body stream.  This may be
 * necessary when authentication has failed for any request that
 * involves a body stream.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream * __nullable bodyStream))completionHandler{

}

/* Sent periodically to notify the delegate of upload progress.  This
 * information is also available as properties of the task.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    bprint(@"bytesSent %@",@(bytesSent));
}

/* Sent as the last message related to a specific task.  Error may be
 * nil, which implies that no error occurred and this task is complete.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
    
}


#pragma  mark NSURLSessionDownloadDelegate

/*
 * Messages related to the operation of a task that writes data to a
 * file and notifies the delegate upon completion.
 */


/* Sent when a download task that has completed a download.  The delegate should
 * copy or move the file at the given location to a new location as it will be
 * removed when the delegate message returns. URLSession:task:didCompleteWithError: will
 * still be called.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    
}


/* Sent periodically to notify the delegate of download progress. */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
}

/* Sent when a download has been resumed. If a download failed with an
 * error, the -userInfo dictionary of the error will contain an
 * NSURLSessionDownloadTaskResumeData key, whose value is the resume
 * data.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes{
    
}


@end
