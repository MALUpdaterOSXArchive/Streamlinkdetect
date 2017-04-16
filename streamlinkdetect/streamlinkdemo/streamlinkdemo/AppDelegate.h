//
//  AppDelegate.h
//  streamlinkdemo
//
//  Created by 天々座理世 on 2017/03/21.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <streamlinkdetect/streamlinkdetect.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, streamlinkdetectordelegate>
@property (strong)  streamlinkdetector * detector;
@property (weak) IBOutlet NSTextField *args;
@property (weak) IBOutlet NSTextField *streamurl;
@property (weak) IBOutlet NSTextField *stream;
@property (weak) IBOutlet NSButton *startstreambtn;
@property (weak) IBOutlet NSButton *stopstreambtn;
@property (unsafe_unretained) IBOutlet NSTextView *streaminfotextview;
- (IBAction)startstream:(id)sender;
- (IBAction)stopstream:(id)sender;
- (IBAction)loadinfo:(id)sender;
- (IBAction)getAvailableStreams:(id)sender;

@end

