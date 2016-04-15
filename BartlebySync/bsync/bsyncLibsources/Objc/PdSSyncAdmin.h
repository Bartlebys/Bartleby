//
//  PdSSyncAdmin.h
//  PdSSync
//
//  Created by Benoit Pereira da Silva on 12/11/2014.
//  Revised for Swift 2.X support 30/12/2015
//

#import <Foundation/Foundation.h>
#import "PdSSync.h"

@class BsyncContext;

@protocol PdSSyncFinalizationDelegate;

typedef NS_ENUM(NSInteger,
                PdSSyncExtentedStatusError) {
    PdSStatusErrorHashMapDeserializationTypeMissMatch=1000,
    PdSStatusErrorHashMapDeserialization=1001,
    PdSStatusErrorHashMapDecryptFailure=1002,
    PdSStatusErrorHashMapFailure=1003
} ;

#pragma mark - Synchronization


/**
 *  Administration interface.
 */
@interface PdSSyncAdmin : NSObject

/**
 * The synchronization context
 */
@property (nonatomic,readonly)BsyncContext* _Nullable syncContext;


/**
 *  Initialize the admin facade with a contzext
 *
 *  @param context the context
 *
 *  @return the admin instance
 */
- (instancetype _Nonnull)initWithContext:(BsyncContext*_Nonnull)context;


/**
 *  Synchronizes the source to the destination
 *
 *  @param progressBlock   the progress block
 *  @param completionBlock the completionBlock
 */
-(void)synchronizeWithprogressBlock:(void(^_Nullable)(NSInteger taskIndex,NSInteger totalTaskCount,double progress,NSString* _Nullable message))progressBlock
                 andCompletionBlock:(void(^_Nonnull)(BOOL success,NSString*_Nullable message))completionBlock;


#pragma mark - Advanced


/**
 *  The finalization delegate can determine when to apply finalize the synchronization
 *  For exemple let's imagine we synchronize a bunch of music file.
 *  It can wait the end of the current track before finalizing.
 *  On finalization the track that was playing can have been deleted.
 */
@property (nonatomic)id<PdSSyncFinalizationDelegate> _Nullable finalizationDelegate;



/**
 * A filtering block that call before synchronization
 * You can modify by reference the DeltaPathMap to remove or add paths.
 *
 * [self->_syncAdmin setFilteringBlock:^(DeltaPathMap *__autoreleasing *pathMap) {
 *       // We filter the pathMap;
 *       [[*pathMap updatedPaths]enumerateObjectsWithOptions:NSEnumerationReverse
 *           usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
 *      if([[API objShouldNotBeUpdated:obj]){
 *          [[*pathMap updatedPaths] removeObjectAtIndex:idx];
 *      }
 *   } ];
 * }];
 */
@property (nonatomic, copy) void (^_Nullable filteringBlock)(DeltaPathMap*_Nonnull*_Nonnull pathMap);



#pragma mark - Install Repository , Create and touch trees.


/**
 *  Proceed to installation of the Repository
 *  @param block   the completion block
 */
- (void)installWithCompletionBlock:(void (^_Nonnull)(BOOL success, NSInteger statusCode))block;

/**
 *  Creates a tree
 *  @param block      the completion block
 */
- (void)createTreesWithCompletionBlock:(void (^_Nonnull)(BOOL success, NSInteger statusCode))block;

/**
 *  Touches the trees (changes the public ID )
 *
 *  @param block      the completion block
 */
- (void)touchTreesWithCompletionBlock:(void (^_Nonnull)(BOOL success, NSInteger statusCode))block;


#pragma  mark - Utilities 

/**
 *  Used by swift.
 *
 *  @param name the name of const
 *
 *  @return the value of the const
 */
+ (NSString*_Nullable)valueForConst:(NSString*_Nonnull)name;



@end
