//
//  RottenTomatoesClient.m
//  rottentomato
//
//  Created by Xiao Jiang on 2/27/15.
//  Copyright (c) 2015 Xiao Jiang. All rights reserved.
//

#import "RottenTomatoesClient.h"

const NSString* APIKey = @"yt2y9kbakprqz9ne9kumm47g";

@implementation RottenTomatoesClient

+ (RottenTomatoesClient *)sharedInstance {
    static RottenTomatoesClient *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[RottenTomatoesClient alloc] init];
        }
    });
    return instance;
}

- (void) getTopBoxOffice:(void (^)(NSArray *, NSError *))completion {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=%@", APIKey]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            completion(nil, connectionError);
            return;
        }
        NSError *error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error) {
            completion(nil, error);
        } else {
            completion([Movie moviesFromDictionary:dict], nil);
        }
    }];
}

- (void) getTopDVDRentals:(void (^)(NSArray *, NSError *))completion {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=%@", APIKey]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            completion(nil, connectionError);
            return;
        }
        NSError *error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error) {
            completion(nil, error);
        } else {
            completion([Movie moviesFromDictionary:dict], nil);
        }
    }];
}

@end
