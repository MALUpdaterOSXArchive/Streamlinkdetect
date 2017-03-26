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
#import "streamlinkinstall.h"
#import "StreamInfoRetrieval.h"
#import "MediaStreamParse.h"
#import "ezregex.h"

@implementation streamlinkdetector
-(bool)getDetectionInfo{
    NSDictionary * sinfo = [StreamInfoRetrieval retrieveStreamInfo:[self streamurl]];
    if (sinfo){
        _detectioninfo = [MediaStreamParse parse:[NSArray arrayWithObjects:sinfo, nil]];
        return true;
    }
    return false;
}
-(void)startStream{
    task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/local/bin/streamlink"];
    if ([[self args] length] > 0){
        [task setArguments:@[[self args], [self streamurl], [self stream]]];
    }
    else{
        [task setArguments:@[[self streamurl], [self stream]]];
    }
    pipe = nil;
    if (!pipe){
        pipe = [[NSPipe alloc] init];
    }
    [task setStandardOutput:pipe];
    [[task.standardOutput fileHandleForReading] setReadabilityHandler:^(NSFileHandle *file) {
        NSData *data = [file availableData]; // this will read to EOF, so call only once
        NSLog(@"Streamlink: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
    [task setTerminationHandler:^(NSTask *task) {
        [task.standardOutput fileHandleForReading].readabilityHandler = nil;
        _isstreaming = false;
        }];
    [task launch];
    _isstreaming = true;

}
-(void)stopStream{
    if (task){
        [task terminate];
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
    [task waitUntilExit];
    int status = [task terminationStatus];
    if (status == 0){
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
-(void)checkStreamLink:(NSWindow *)w{
    if (![self checkifPythonExists]){
        if (![self checkifHomebrewExists]){
            [self showHomebrewNotInstalledAlert];
        }
        else if (![self checkifStreamLinkExists]){
            [self showStreamLinkNotInstalledAlert:w];
        }
    }
    else{
        if (![self checkifStreamLinkExists]){
            [self showStreamLinkNotInstalledAlert:w];
        }
    }
}
-(bool)checkifStreamLinkExists{
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString * fullfilenamewithpath = @"/usr/local/bin/streamlink";
    if ([filemanager fileExistsAtPath:fullfilenamewithpath]){
        return true;
    }
    return false;
}
-(bool)checkifPythonExists{
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString * fullfilenamewithpath = @"/usr/local/bin/python";
    if ([filemanager fileExistsAtPath:fullfilenamewithpath]){
        return true;
    }
    return false;
}
-(bool)checkifHomebrewExists{
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString * fullfilenamewithpath = @"/usr/local/bin/brew";
    if ([filemanager fileExistsAtPath:fullfilenamewithpath]){
        return true;
    }
    return false;
}
-(void)showHomebrewNotInstalledAlert{
    // Shows Donation Reminder
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
    // Shows Donation Reminder
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
        [self installStreamLink:w];
    }
}
-(void)installStreamLink:(NSWindow *)w{
    // Shows streamlink install window
    if (!streamlinkinstallw){
        streamlinkinstallw = [[streamlinkinstall alloc] initWithDetector:self];
    }
    [NSApp beginSheet:streamlinkinstallw.window
       modalForWindow:w modalDelegate:self
       didEndSelector:@selector(streamlinkinstallDidEnd:returnCode:contextInfo:)
          contextInfo:(void *)nil];
}
-(void)streamlinkinstallDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    streamlinkinstallw = nil;
}
@end
