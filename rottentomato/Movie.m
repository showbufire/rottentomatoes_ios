//
//  Movie.m
//  rottentomato
//
//  Created by Xiao Jiang on 2/27/15.
//  Copyright (c) 2015 Xiao Jiang. All rights reserved.
//

#import "Movie.h"

@implementation Movie

+ (NSArray*) moviesFromDictionary:(NSDictionary *)dictionary {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (NSDictionary *movieDict in dictionary[@"movies"]) {
        Movie *movie = [[Movie alloc] init];
        movie.title = movieDict[@"title"];
        movie.synopsis = movieDict[@"synopsis"];
        movie.thumbnail = [NSURL URLWithString:[movieDict valueForKeyPath:@"posters.thumbnail"]];
        [arr addObject:movie];
    }
    return arr;
}

@end
