//
//  HTTPRequest.m
//  JSONExchange
//
//  Created by Chemersky on 4/4/17.
//  Copyright © 2017 Chemer. All rights reserved.
//

#import "HTTPRequest.h"

@interface HTTPRequest () <NSURLSessionDelegate>
@property NSString *ip;
@property NSString *body;
@property int port;
@end

@implementation HTTPRequest

- (id)initWithIP:(NSString *)ip port:(int)port body:(NSString *)body {
    self = [super init];
    if (self) {
        self.ip = ip;
        self.body = body;
        self.port = port;
    }
    return self;
}
//@TODO show error if body not json
- (void)run {
    NSError *error;

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d", self.ip, self.port]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                       cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                   timeoutInterval:15.0];

    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"POST"];
//@TODO check json format
    NSData *postData = [self.body dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:postData];


    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"%@", [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding]);
    }];
    [postDataTask resume];
}

@end
