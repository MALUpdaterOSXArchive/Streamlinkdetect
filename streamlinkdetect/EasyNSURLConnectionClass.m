//
//  EasyNSURLConnectionClass.m
//
//  Created by Nanoha Takamachi on 2014/11/25.
//  Copyright (c) 2014年 Atelier Shiori. Licensed under MIT License.
//
//  This class allows easy creation of synchronous request using NSURLSession
//

#import "EasyNSURLConnectionClass.h"
#import "EasyNSURLResponse.h"

@implementation EasyNSURLConnectionLite

#pragma constructors
-(id)init{
    // Set Default User Agent
    useragent =[NSString stringWithFormat:@"%@ %@ (Macintosh; Mac OS X %@; %@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"] objectForKey:@"ProductVersion"], [[NSLocale currentLocale] localeIdentifier]];
    return [super init];
}
-(id)initWithURL:(NSURL *)address{
    URL = address;
    return [self init];
}
#pragma getters
-(NSData *)getResponseData{
    return responsedata;
}
-(NSString *)getResponseDataString{
    NSString * datastring = [[NSString alloc] initWithData:responsedata encoding:NSUTF8StringEncoding];
    return datastring;
}
-(id)getResponseDataJsonParsed{
    return [NSJSONSerialization JSONObjectWithData:responsedata options:0 error:nil];
}
-(long)getStatusCode{
    return response.statusCode;
}
-(NSError *)getError{
    return error;
}
#pragma mutators
-(void)addHeader:(id)object
          forKey:(NSString *)key{
    NSLock * lock = [NSLock new]; // NSMutableArray is not Thread Safe, lock before performing operation
    [lock lock];
    if (headers == nil) {
        //Initalize Header Data Array
        headers = [[NSMutableArray alloc] init];
    }
    [headers addObject:[NSDictionary dictionaryWithObjectsAndKeys:object,key, nil]];
    [lock unlock]; //Finished operation, unlock
}
-(void)setUserAgent:(NSString *)string{
    useragent = [NSString stringWithFormat:@"%@",string];
}
-(void)setUseCookies:(BOOL)choice{
    usecookies = choice;
}
-(void)setURL:(NSURL *)address{
    URL = address;
}
#pragma request functions
-(void)startRequest{
    // Send a synchronous request
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:URL];
    // Do not use Cookies
    [request setHTTPShouldHandleCookies:usecookies];
    // Set Timeout
    [request setTimeoutInterval:15];
    // Set User Agent
    [request setValue:useragent forHTTPHeaderField:@"User-Agent"];
    NSLock * lock = [NSLock new]; // NSMutableArray is not Thread Safe, lock before performing operation
    [lock lock];
    // Set Other headers, if any
    if (headers != nil) {
        for (NSDictionary *d in headers ) {
            //Set any headers
            [request setValue:[[d allValues] objectAtIndex:0]forHTTPHeaderField:[[d allKeys] objectAtIndex:0]];
        }
    }
    [lock unlock];
    // Send Request
    EasyNSURLResponse * urlsessionresponse = [self performNSURLSessionRequest:request];
    responsedata = [urlsessionresponse getData];
    error = [urlsessionresponse getError];
    response = [urlsessionresponse getResponse];
}


#pragma helpers
-(EasyNSURLResponse *)performNSURLSessionRequest:(NSURLRequest *)request
{
    // Based on http://demianturner.com/2016/08/synchronous-nsurlsession-in-obj-c/
    __block NSHTTPURLResponse *urlresponse = nil;
    __block NSData *data = nil;
    __block NSError * error2 = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *taskData, NSURLResponse *rresponse, NSError *eerror) {
        data = taskData;
        urlresponse = (NSHTTPURLResponse *)rresponse;
        error2 = eerror;
        dispatch_semaphore_signal(semaphore);
        
    }];
    [dataTask resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return [[EasyNSURLResponse alloc] initWithData:data withResponse:urlresponse withError:error2];
}
@end
