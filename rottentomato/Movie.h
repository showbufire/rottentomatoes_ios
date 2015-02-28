//
//  Movie.h
//  rottentomato
//
//  Created by Xiao Jiang on 2/27/15.
//  Copyright (c) 2015 Xiao Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Movie : NSObject

@property(strong, nonatomic) NSString *title;
@property(strong, nonatomic) NSString *synopsis;
@property(strong, nonatomic) NSURL *thumbnail;

+ (NSArray*) moviesFromDictionary:(NSDictionary *)dictionary;

@end
