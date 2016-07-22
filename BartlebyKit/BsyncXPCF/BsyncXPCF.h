//
//  BsyncXPCF.h
//  BsyncXPCF
//
//  Created by Benoit Pereira da silva on 22/07/2016.
//
//

#import <Foundation/Foundation.h>
#import "BsyncXPCFProtocol.h"

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@interface BsyncXPCF : NSObject <BsyncXPCFProtocol>
@end
