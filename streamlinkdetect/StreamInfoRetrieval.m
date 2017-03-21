//
//  StreamInfoRetrieval.m
//  streamlinkdetect
//
//  Created by 天々座理世 on 2017/03/21.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "StreamInfoRetrieval.h"
#import "EasyNSURLConnectionClass.h"
#import "ezregex.h"

@implementation StreamInfoRetrieval
NSString *const supportedSites = @"(crunchyroll|daisuki|animelab|animenewsnetwork|viz|netflix|plex|viewster|funimation|wakanim|myanimelist|32400)";
+(NSDictionary *)retrieveStreamInfo:(NSString*) URL{
    // Retrieves information about stream
    EasyNSURLConnectionLite * request = [[EasyNSURLConnectionLite alloc] initWithURL:[NSURL URLWithString:URL]];
    [request setUserAgent:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_4) AppleWebKit/600.7.12 (KHTML, like Gecko) Version/8.0.7 Safari/600.7.12"];
    [request startRequest];
    if (request.getStatusCode == 200){
        NSString * dom = [request getResponseDataString];
        NSString * title = [StreamInfoRetrieval getPageTitle:dom];
        NSString * browser = @"streamlink";
        NSString * site = [StreamInfoRetrieval checkURL:URL];
        return @{ @"title":title, @"DOM":dom, @"url":URL, @"browser":browser, @"site":site};
    }
    return nil;
}
+(NSString *)getPageTitle:(NSString *)dom{
    ezregex * regex = [ezregex new];
    NSString * title = [regex findMatch:dom pattern:@"<title>(.*?)<\\/title>" rangeatindex:0];
    title = [regex searchreplace:title pattern:@"(<title>|<\\/title>)"];
    return title;
}
+(NSString *)checkURL:(NSString *)url{
    NSString * site = [[[ezregex alloc] init] findMatch:url pattern:supportedSites rangeatindex:0];
    if ([site isEqualToString:@"32400"]) {
        //Plex local port, return plex
        return @"plex";
    }
    return site;
}
@end
