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
    _detector = [streamlinkdetector new];
    [_detector checkStreamLink:nil];
    [_detector setDelegate:self];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (IBAction)startstream:(id)sender {
    [_detector setargs:_args.stringValue];
    [_detector setStreamURL:_streamurl.stringValue];
    [_detector setStream:_stream.stringValue];
    if (![_detector getStreamStatus]) {
        [_detector startStream];
    }
}

- (IBAction)stopstream:(id)sender {
    if ([_detector getStreamStatus]) {
        [_detector stopStream];
    }
}

- (IBAction)loadinfo:(id)sender {
    [_detector setStreamURL:_streamurl.stringValue];
    dispatch_queue_t queue = dispatch_get_global_queue(
                                                       DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        if ([_detector getDetectionInfo]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _streaminfotextview.string = [NSString stringWithFormat:@"%@",[_detector getdetectinfo]];
            });
        }
    });
}
- (IBAction)detectandloadinfo:(id)sender {

    dispatch_queue_t queue = dispatch_get_global_queue(
                                                       DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSArray * a = [_detector detectAndRetrieveInfo];
        if (a) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _streaminfotextview.string = [NSString stringWithFormat:@"%@",a];
            });
        }
    });
}

- (IBAction)getAvailableStreams:(id)sender {
    [_detector setStreamURL:_streamurl.stringValue];
    dispatch_queue_t queue = dispatch_get_global_queue(
                                                       DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSArray * streams = [_detector getAvailableStreams];
        dispatch_async(dispatch_get_main_queue(), ^{
            _streaminfotextview.string = [NSString stringWithFormat:@"%@",streams];
        });
    });
}
-(bool)checkifStreamLinkExists{
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString * fullfilenamewithpath = @"/usr/local/bin/streamlink";
    if ([filemanager fileExistsAtPath:fullfilenamewithpath]) {
        return true;
    }
    return false;
}
- (void)streamDidBegin{
    NSLog(@"stream start");
}
- (void)streamDidEnd{
    NSLog(@"stream stopped");
}
@end
