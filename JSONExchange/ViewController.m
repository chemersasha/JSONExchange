//
//  ViewController.m
//  JSONExchange
//
//  Created by Chemersky on 4/3/17.
//  Copyright © 2017 Chemer. All rights reserved.
//

#import "ViewController.h"
#import "HTTPServer.h"
#import "HTTPRequest.h"

@interface ViewController () <HTTPServerDelegate>
@property HTTPServer *httpServer;
@property HTTPRequest *httpRequest;
//@TODO add number formater
@property (weak) IBOutlet NSTextField *port;
@property (unsafe_unretained) IBOutlet NSTextView *body;
//@TODO add formater
@property (weak) IBOutlet NSTextField *requestIP;
//@TODO add number formater
@property (weak) IBOutlet NSTextField *requestPort;
@property (unsafe_unretained) IBOutlet NSTextView *requestBody;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *defaultBody = @{@"key0":@"value0",@"key1":@"value1",@"key2":@"value2",@"key3":@"value3",@"key4":@"value4",};
    self.requestBody.string = [NSString stringWithFormat:@"%@", defaultBody];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)run:(id)sender {
    self.httpServer = [[HTTPServer alloc] initWithPortNumber:[self.port.stringValue intValue] delegate:self];
}

- (IBAction)stop:(id)sender {
    [self.httpServer stop];
    self.httpServer = nil;
}

- (IBAction)send:(id)sender {
    self.httpRequest = [[HTTPRequest alloc] initWithIP:self.requestIP.stringValue port:[self.requestPort.stringValue intValue] body:self.requestBody.string];
    [self.httpRequest run];
}

#pragma mark - HTTPServer delegate

- (void)dataDidReceive:(NSData *)data {
    NSString *dataStr = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    self.body.string = [NSString stringWithFormat:@"%@%@", self.body.string, dataStr];
}

@end
