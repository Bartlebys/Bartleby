//
//  PdSSyncContext.h
//  PdSSync
//
//  Created by Benoit Pereira da Silva on 13/03/2014.
//
//

#import <Foundation/Foundation.h>
#import "PdSSync.h"

@interface PdSSyncContext : NSObject

@property (nonatomic,strong)HashMap *_Nullable finalHashMap;

@property (nonatomic)NSString* _Nullable sourceTreeId;
@property (nonatomic)NSString* _Nullable destinationTreeId;

@property (nonatomic)NSURL* _Nonnull sourceBaseUrl;
@property (nonatomic)NSURL* _Nonnull destinationBaseUrl;

/**
 * A hashMapView is a HashMap stored within the repository regular file.
 * It should be serialized in a file named : .<hashMapViewName>.<kBsyncHashMapDataViewFileExtension>
 * It allows to share multiple view of the same file tree.
 * HashMapViews have been introduced in bsync 1.5 and are retro-inject in PdSSync code base
 * There is no risk to use hashMapViews in DownStream synchronization Master > Slaves
 * Other topology are currently not supported (!)
 */
@property (nonatomic)NSString*_Nullable hashMapViewName;

// A unique sync identifier
@property (nonatomic)NSString*_Nullable syncID;

// Informational properties

@property (nonatomic)int numberOfCompletedCommands;
@property (nonatomic)int numberOfCommands;

// If set to true any unexisting tree will be created on first sync
@property (nonatomic)BOOL autoCreateTrees;

/**
 * The url are considerated as the file tree root
 *
 *  for example     : http://yd.local/api/v1/BartlebySync/tree/nameOfTree/
 *  or              : file:///~/Desktop/test/
 *
 *  If the url is distant we extract the tree id.
 *  And determine the base url by truncated before the /tree/ component
 *  eg :    http://yd.local/api/v1/BartlebySync/tree/nameOfTree/
 *          => base url is : http://yd.local/api/v1/BartlebySync/
 *          => tree id is : nameOfTree
 *
 *  @param sourceUrl        the sourceUrl
 *  @param destinationUrl   the destinationUrl
 *  @param hashMapViewName  the optionnal hashMapViewName
 *
 *  @return the context or nil if the configuration is not valid
 */
-(instancetype _Nonnull)initWithSourceURL:(NSURL*_Nonnull)sourceUrl
                        andDestinationUrl:(NSURL*_Nonnull)destinationUrl
                             restrictedTo:(NSString*_Nullable)hashMapViewName;


/**
 *  Initializer used for retro-compatibility purposes
 *
 *  @param sourceUrl      the source URL
 *  @param destinationUrl the destination URL
 *
 *  @return the context or nil if the configuration is not valid
 */
-(instancetype _Nonnull)initWithSourceURL:(NSURL*_Nonnull)sourceUrl
                        andDestinationUrl:(NSURL*_Nonnull)destinationUrl;


- (BOOL)isValid;

- (BsyncMode)mode;

- (NSString*_Nonnull)contextDescription;


@end