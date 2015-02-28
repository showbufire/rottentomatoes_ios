//
//  RottenTomatoesClient.h
//  rottentomato
//
//  Created by Xiao Jiang on 2/27/15.
//  Copyright (c) 2015 Xiao Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Movie.h"

@interface RottenTomatoesClient : NSObject

+ (RottenTomatoesClient *)sharedInstance;

- (void) getTopBoxOffice:(void (^)(NSArray*, NSError*))commpletion;

- (void) getTopDVDRentals:(void (^)(NSArray*, NSError*))completion;

@end
