//
//  AppDelegate.h
//  Restly
//
//  Created by Sean Walker on 1/24/12.
//  Copyright (c) 2012 swlkr. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSURLConnectionDelegate> {
    NSMutableData * receivedData;
    NSHTTPURLResponse * httpResponse;
    NSMutableURLRequest * request;
}

@property (assign) IBOutlet NSWindow * window;
@property (weak) IBOutlet NSComboBox * method;
@property (weak) IBOutlet NSTextField * url;
@property (weak) IBOutlet NSButton *send;
@property (unsafe_unretained) IBOutlet NSTextView * responseHeader;
@property (unsafe_unretained) IBOutlet NSTextView * responseBody;
@property (unsafe_unretained) IBOutlet NSTextView *requestHeader;
@property (unsafe_unretained) IBOutlet NSTextView *requestBody;


- (IBAction) sendClick:(id)sender;
- (void) setData:(NSData *)theData encoding:(NSString *)encoding;

@end
