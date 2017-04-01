//
//  AppDelegate.m
//  streamlinkdemo
//
//  Created by 天々座理世 on 2017/03/21.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    detector = [streamlinkdetector new];
    [detector checkStreamLink:nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (IBAction)startstream:(id)sender {
    [detector setargs:_args.stringValue];
    [detector setStreamURL:_streamurl.stringValue];
    [detector setStream:_stream.stringValue];
    if (![detector getStreamStatus]){
        [detector startStream];
    }
}

- (IBAction)stopstream:(id)sender {
    if ([detector getStreamStatus]){
        [detector stopStream];
    }
}

- (IBAction)loadinfo:(id)sender {
    [detector setStreamURL:_streamurl.stringValue];
    dispatch_queue_t queue = dispatch_get_global_queue(
                                                       DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        if ([detector getDetectionInfo]){
            dispatch_async(dispatch_get_main_queue(), ^{
                _streaminfotextview.string = [NSString stringWithFormat:@"%@",[detector getdetectinfo]];
            });
        }
    });
}
- (IBAction)detectandloadinfo:(id)sender {

    dispatch_queue_t queue = dispatch_get_global_queue(
                                                       DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSArray * a = [detector detectAndRetrieveInfo];
        if (a){
            dispatch_async(dispatch_get_main_queue(), ^{
                _streaminfotextview.string = [NSString stringWithFormat:@"%@",a];
            });
        }
    });
}

- (IBAction)getAvailableStreams:(id)sender {
    [detector setStreamURL:_streamurl.stringValue];
    dispatch_queue_t queue = dispatch_get_global_queue(
                                                       DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSArray * streams = [detector getAvailableStreams];
        dispatch_async(dispatch_get_main_queue(), ^{
            _streaminfotextview.string = [NSString stringWithFormat:@"%@",streams];
        });
    });
}
-(bool)checkifStreamLinkExists{
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString * fullfilenamewithpath = @"/usr/local/bin/streamlink";
    if ([filemanager fileExistsAtPath:fullfilenamewithpath]){
        return true;
    }
    return false;
}

@end
