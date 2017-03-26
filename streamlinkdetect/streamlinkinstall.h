//
//  streamlinkinstall.h
//  streamlinkdetect
//
//  Created by 天々座理世 on 2017/03/26.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class streamlinkdetector;

@interface streamlinkinstall : NSWindowController
@property (strong) IBOutlet NSButton *closebtn;
@property (strong) IBOutlet NSTextField *statuslbl;
@property (strong) IBOutlet NSTextView *consoletext;
@property (strong) IBOutlet NSProgressIndicator *progressind;
-(instancetype)initWithDetector:(streamlinkdetector *)detect;
- (IBAction)closewindow:(id)sender;

@end
