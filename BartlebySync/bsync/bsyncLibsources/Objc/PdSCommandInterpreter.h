//
//  PdSCommandInterpreter.h
//  PdSSync
//
//  Created by Benoit Pereira da Silva on 11/03/2014.
//
//

#import <Foundation/Foundation.h>
#import "PdSSync.h"

@class PdSCommandInterpreter;
@class BsyncContext;
@class BsyncSession;

#pragma mark - Finalization Delegate protocol

@protocol PdSSyncFinalizationDelegate <NSObject>
-(void)readyForFinalization:(PdSCommandInterpreter*)reference;
-(void)progressMessage:(NSString*)message;
@end

extern NSString * const PdSSyncInterpreterWillFinalize;// Notification
extern NSString * const PdSSyncInterpreterHasFinalized;// Notification

#pragma mark - Command Interpreter


@interface PdSCommandInterpreter : NSObject

@property (nonatomic)id<PdSSyncFinalizationDelegate>finalizationDelegate;

/**
 *  The progress counter in percent.
 * ( Total command number / executed command ) + proportionnal progress on the current command
 */
@property (nonatomic,readonly)uint progressCounter;


#pragma mark Interpretation

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
                                     andCompletionBlock:(void(^)(BOOL success,NSString*message))completionBlock;

/**
 *   The dedicated initializer.
 *
 *  @param bunchOfCommand  the bunch of command
 *  @param context         the interpreter context
 *  @param progressBlock   the progress block (float progress is equivalent to NSProgress fractionCompleted)
 *  @param completionBlock te completion block
 *
 *  @return the interpreter
 */
- (instancetype)initWithBunchOfCommand:(NSArray*)bunchOfCommand
                               context:(BsyncContext*)context
                         progressBlock:(void(^)(uint taskIndex,double progress))progressBlock
                    andCompletionBlock:(void(^)(BOOL success,NSString*message))completionBlock;

/**
 * Called by the delegate to conclude the sequence of commands.
 */
- (void)finalize;

#pragma mark - Commands encoding

// Commands encoding returns the encoded command in the relevant format.
// Currently we use JSON, MsgPack could be supported soon.

+(id)encodeCreate:(NSString*)source destination:(NSString*)destination;
+(id)encodeUpdate:(NSString*)source destination:(NSString*)destination;
+(id)encodeCopy:(NSString*)source destination:(NSString*)destination;
+(id)encodeMove:(NSString*)source destination:(NSString*)destination;
+(id)encodeRemove:(NSString*)destination;

#pragma mark - Commands from DeltaPathMap

+ (NSMutableArray*)commandsFromDeltaPathMap:(DeltaPathMap*)deltaPathMap;


@end