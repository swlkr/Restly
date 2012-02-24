//
//  AppDelegate.m
//  Restly
//
//  Created by Sean Walker on 1/24/12.
//  Copyright (c) 2012 swlkr. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window;
@synthesize method;
@synthesize url;
@synthesize responseHeader;
@synthesize responseBody;
@synthesize requestHeader;
@synthesize requestBody;
@synthesize send;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Fill the Method combo box
    [method addItemsWithObjectValues:[NSArray arrayWithObjects:@"GET", @"POST", @"UPDATE", @"DELETE", nil]];
    
    // Set the method combo box to GET by default
    [method selectItemAtIndex:0];
    [method setEditable:NO];
    
    // Give the url textbox focus
    [window makeFirstResponder:url];
    
    // Init the request
    request = [[NSMutableURLRequest alloc] init];
    
    NSMutableDictionary * requestHeaders = [[NSMutableDictionary alloc] init];
    [requestHeaders setObject:@"Restly" forKey:@"Host"];
    
    [request setAllHTTPHeaderFields:requestHeaders];
    
    [requestHeader.textStorage.mutableString setString:@"Host: Restly"];
}

// send button click handler
- (IBAction) sendClick: (id) sender {
    
    // update the header textbox (for debugging)
    NSLog(@"pressed the send button!");
    
    // Get the text from the url textbox
    NSString * urlString = [url stringValue];
    
    // put "http://" at the beginning of the string in the textbox if it's not there
    if(![urlString hasPrefix:@"http://"] && ![urlString hasPrefix:@"https://"])
        urlString = [NSString stringWithFormat:@"http://%@", urlString];
    
    [url setStringValue:urlString];
    
    receivedData = [[NSMutableData alloc] init];
    
    //[request setUrlrequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:[method objectValueOfSelectedItem]];
    [request setHTTPShouldHandleCookies:YES];
    
    // Get the headers from the header textview and split them on ':' and '\n'
    // Then loop through them and stick them in the request by using [request addValue]
    NSArray * headerLines = [requestHeader.textStorage.mutableString componentsSeparatedByString:@"\n"];
    if(headerLines != nil && headerLines.count > 0) {
        NSMutableDictionary * headerDictionary = [[NSMutableDictionary alloc] init];
        for(int i = 0; i != headerLines.count; i++) {
            NSArray * headerArray = [[headerLines objectAtIndex:i] componentsSeparatedByString:@":"];
            if(headerArray.count > 0)
                [headerDictionary setObject:[headerArray objectAtIndex:1] forKey:[headerArray objectAtIndex:0]];
        }
        [request setAllHTTPHeaderFields:headerDictionary];
    }
    
    NSString * bodyString = requestBody.textStorage.mutableString;
    
    if(bodyString.length > 0) {
        [request setValue:[NSString stringWithFormat:@"%d", bodyString.length] forHTTPHeaderField:@"Content-length"];
        [request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    }
    
    // Send an async webrequest
    NSURLConnection * connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    if (connection) {
        receivedData = [NSMutableData data];
    } else {
        // Inform the user that the connection failed.
    }
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    httpResponse = (NSHTTPURLResponse *)response;
    
    NSDictionary * headers = [httpResponse allHeaderFields];
    
    NSString * headerString = @"";
    
    // load the header textbox with the headers and their values
    for (id key in headers)
        headerString = [headerString stringByAppendingFormat:@"%@: %@\n", key, [headers objectForKey:key]];
    
    // load the header textview with the response headers
    [responseHeader.textStorage.mutableString setString:headerString];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    
    // load the body textview with the response body
    [self setData:receivedData encoding:httpResponse.textEncodingName];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [responseBody.textStorage.mutableString setString:error.description];
}

- (void)setData:(NSData *)data encoding:(NSString *)encoding {
    if (data != nil) {
        
        // NSURLResponse's encoding is an IANA string. Use CF utilities to convert it to a CFStringEncoding then a NSStringEncoding
        NSStringEncoding nsEncoding = NSUTF8StringEncoding; // default to UTF-8
        if (encoding) {
            CFStringEncoding cfEncoding = CFStringConvertIANACharSetNameToEncoding((__bridge CFStringRef)encoding);
            if (cfEncoding != kCFStringEncodingInvalidId) {
                nsEncoding = CFStringConvertEncodingToNSStringEncoding(cfEncoding);
            }
        }
        NSString * bodyString = [[NSString alloc] initWithData:data encoding:nsEncoding];
        [responseBody.textStorage.mutableString setString:bodyString];
    }
}

@end
