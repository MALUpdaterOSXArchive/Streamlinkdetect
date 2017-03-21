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
@end
