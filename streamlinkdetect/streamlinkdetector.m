//
//  streamlinkdetector.m
//  streamlinkdetect
//
//  Created by 天々座理世 on 2017/03/21.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "streamlinkdetector.h"
#import "StreamInfoRetrieval.h"
#import "MediaStreamParse.h"
#import "ezregex.h"

@implementation streamlinkdetector
struct {
    unsigned int didBegin:1;
    unsigned int didEnd:1;
} delegateRespondsTo;

@synthesize delegate;

- (void)setDelegate:(id <streamlinkdetectordelegate>)aDelegate {
    if (delegate != aDelegate) {
        delegate = aDelegate;
        
        delegateRespondsTo.didBegin = [delegate respondsToSelector:@selector(streamDidBegin)];
        delegateRespondsTo.didEnd = [delegate respondsToSelector:@selector(streamDidBegin)];
    }
}
-(bool)getDetectionInfo{
    NSDictionary * sinfo = [StreamInfoRetrieval retrieveStreamInfo:[self streamurl]];
    if (sinfo) {
        _detectioninfo = [MediaStreamParse parse:[NSArray arrayWithObjects:sinfo, nil]];
        return true;
    }
    return false;
}
-(void)startStream{
    _task = [[NSTask alloc] init];
    [_task setLaunchPath:@"/usr/local/bin/streamlink"];
    _task.environment = @{@"PATH":@"/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"};
    if ([[self args] length] > 0) {
        [_task setArguments:@[[self args], [self streamurl], [self stream]]];
    }
    else {
        [_task setArguments:@[[self streamurl], [self stream]]];
    }
    _pipe = nil;
    if (!pipe) {
        _pipe = [[NSPipe alloc] init];
    }
    [_task setStandardOutput:_pipe];
    [[_task.standardOutput fileHandleForReading] setReadabilityHandler:^(NSFileHandle *file) {
        NSData *data = [file availableData]; // this will read to EOF, so call only once
        NSString * avilstring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Streamlink: %@", avilstring);
        [self checkPluginError:avilstring];
    }];
    [_task setTerminationHandler:^(NSTask *task) {
        [task.standardOutput fileHandleForReading].readabilityHandler = nil;
        _isstreaming = false;
        [delegate streamDidEnd];
        }];
    [_task launch];
    _isstreaming = true;
    [delegate streamDidBegin];
}
-(void)stopStream{
    if (_task) {
        [_task terminate];
    }
}
-(NSArray *)getAvailableStreams{
    NSTask * task2 = [[NSTask alloc] init];
    [task2 setLaunchPath:@"/usr/local/bin/streamlink"];
    [task2 setArguments:@[[self streamurl]]];
    NSPipe *pipe2 = [NSPipe pipe];
    task2.standardOutput = pipe2;
    NSFileHandle *file = pipe2.fileHandleForReading;
    [task2 launch];
    [_task waitUntilExit];
    int status = [_task terminationStatus];
    if (status == 0) {
        NSData *data = [file readDataToEndOfFile];
        NSString * output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        output = [[ezregex new] findMatch:output pattern:@"Available streams:*.*" rangeatindex:0];
        output = [output stringByReplacingOccurrencesOfString:@"Available streams: " withString:@""];
        output = [output stringByReplacingOccurrencesOfString:@" (worst)" withString:@""];
        output = [output stringByReplacingOccurrencesOfString:@" (best)" withString:@""];
        return [output componentsSeparatedByString:@","];
    }
    return @[];
}
-(NSArray *)detectAndRetrieveInfo{
    NSTask *task;
    task = [[NSTask alloc] init];
    task.launchPath = @"/bin/ps";
    task.arguments = @[@"-ax"];
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    task.standardOutput = pipe;
    
    NSFileHandle *file;
    file = pipe.fileHandleForReading;
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSString *pattern = @"streamlink (https?:\\/\\/(?:www\\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\\.[^\\s]{2,}|www\\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\\.[^\\s]{2,}|https?:\\/\\/(?:www\\.|(?!www))[a-zA-Z0-9]\\.[^\\s]{2,}|www\\.[a-zA-Z0-9]\\.[^\\s]{2,})";
    ezregex * regex = [ezregex new];
    if([regex checkMatch:string pattern:pattern]) {
        string = [regex findMatch:string pattern:pattern rangeatindex:0];
        string = [string stringByReplacingOccurrencesOfString:@"streamlink " withString:@""];
        return [MediaStreamParse parse:@[[StreamInfoRetrieval retrieveStreamInfo:string]]];
    }
    return nil;
}
-(void)checkStreamLink:(NSWindow *)w{
    if (![self checkifPythonExists]) {
        if (![self checkifHomebrewExists]) {
            [self showHomebrewNotInstalledAlert];
        }
        else if (![self checkifStreamLinkExists]) {
            [self showStreamLinkNotInstalledAlert:w];
        }
    }
    else {
        if (![self checkifStreamLinkExists]) {
            [self showStreamLinkNotInstalledAlert:w];
        }
    }
}
-(void)checkPluginError:(NSString *)errorstr{
    ezregex * regex = [ezregex new];
    if ([regex checkMatch:errorstr pattern:@"\\[error\\]*.*"]) {
        [self stopStream];
        [self showAlert:NSLocalizedString(@"This stream is not supported.",@"not_supported") withExplaination:[[regex findMatch:errorstr pattern:@"\\[error\\]*.*" rangeatindex:0] stringByReplacingOccurrencesOfString:@"[error] " withString:@""]];
    }
}
-(bool)checkifStreamLinkExists{
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString * fullfilenamewithpath = @"/usr/local/bin/streamlink";
    if ([filemanager fileExistsAtPath:fullfilenamewithpath]) {
        return true;
    }
    return false;
}
-(bool)checkifPythonExists{
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString * fullfilenamewithpath = @"/usr/local/bin/python";
    if ([filemanager fileExistsAtPath:fullfilenamewithpath]) {
        return true;
    }
    return false;
}
-(bool)checkifHomebrewExists{
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString * fullfilenamewithpath = @"/usr/local/bin/brew";
    if ([filemanager fileExistsAtPath:fullfilenamewithpath]) {
        return true;
    }
    return false;
}
-(void)showHomebrewNotInstalledAlert{
    // Shows Not Installed
    NSAlert * alert = [[NSAlert alloc] init] ;
    [alert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"No",nil)];
    [alert setMessageText:NSLocalizedString(@"Homebrew is not installed",nil)];
    [alert setInformativeText:NSLocalizedString(@"To install streamlink, Homebrew needs to be installed to install Python. Do you want to view instructions to install it?",nil)];
    [alert setShowsSuppressionButton:NO];
    // Set Message type to Warning
    [alert setAlertStyle:NSInformationalAlertStyle];
    long choice = [alert runModal];
    if (choice == NSAlertFirstButtonReturn) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://brew.sh"]];
    }
}
-(void)showStreamLinkNotInstalledAlert:(NSWindow *)w{
    // Shows Not Installed
    NSAlert * alert = [[NSAlert alloc] init] ;
    [alert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"No",nil)];
    [alert setMessageText:NSLocalizedString(@"Streamlink is not installed",nil)];
    [alert setInformativeText:NSLocalizedString(@"To use this feature, you need to install streamlink. Do you want install streamlink now?",nil)];
    [alert setShowsSuppressionButton:NO];
    // Set Message type to Warning
    [alert setAlertStyle:NSInformationalAlertStyle];
    long choice = [alert runModal];
    if (choice == NSAlertFirstButtonReturn) {
        [self installStreamLink];
    }
}
-(void)showAlert:(NSString *)title withExplaination:(NSString *)explaination{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAlert * alert = [[NSAlert alloc] init] ;
        [alert setMessageText:title];
        [alert setInformativeText:explaination];
        [alert setShowsSuppressionButton:NO];
        // Set Message type to Warning
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert runModal];
    });
}
-(void)installStreamLink{
    NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
    NSString *helperAppPath = [[mainBundle resourcePath]
                               stringByAppendingString:@"/streamlink Installer.app"];
    
    [[NSWorkspace sharedWorkspace] launchApplication:helperAppPath];
}


@end
