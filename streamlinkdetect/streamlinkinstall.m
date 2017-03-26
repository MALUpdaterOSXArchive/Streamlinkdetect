//
//  streamlinkinstall.m
//  streamlinkdetect
//
//  Created by 天々座理世 on 2017/03/26.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//
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

#import "streamlinkinstall.h"
#import "streamlinkdetector.h"

@interface streamlinkinstall (){
    streamlinkdetector * detector;
    NSTask * task;
    NSPipe * pipe;
}

@end

@implementation streamlinkinstall
-(instancetype)init{
    self = [super initWithWindowNibName:@"streamlinkinstall"];
    if(!self)
        return nil;
    return self;
}
-(instancetype)initWithDetector:(streamlinkdetector *)detect{
    detector = detect;
    return [self init];
}
- (void)windowDidLoad {
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString * fullfilenamewithpath = @"/usr/local/bin/python";
    if (![filemanager fileExistsAtPath:fullfilenamewithpath]){
        [self installPython];
    }
    else{
        [self installStreamLink];
    }
}
-(void)installPython{
    [_progressind startAnimation:nil];
    task = [NSTask new];
    _statuslbl.stringValue = @"Installing Python from Homebrew.";
    [task setLaunchPath:@"/usr/local/Homebrew/bin/brew"];
    [task setArguments:@[@"install", @"python"]];
    pipe = nil;
    if (!pipe){
        pipe = [[NSPipe alloc] init];
    }
    [task setStandardOutput:pipe];
    __weak typeof(self) weakSelf = self;
    [[task.standardOutput fileHandleForReading] setReadabilityHandler:^(NSFileHandle *file) {
        NSData *data = [file availableData]; // this will read to EOF, so call only once
        [weakSelf appendString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    }];
    [task setTerminationHandler:^(NSTask *task2) {
        [task2.standardOutput fileHandleForReading].readabilityHandler = nil;
        if ([task2 terminationStatus] != 0){
            [weakSelf appendString:@"Python install failed!"];
            [weakSelf setStatusLabel:[task2 terminationStatus]];
        }
        else {
             weakSelf.statuslbl.stringValue = @"Installing streamlink.";
             [weakSelf installStreamLink];
        }
    }];
    [task launch];

}
-(void)installStreamLink{
    task = nil;
    __weak typeof(self) weakSelf = self;
    [_progressind startAnimation:nil];
    task = [NSTask new];
    weakSelf.statuslbl.stringValue = @"Installing streamlink.";
    [task setLaunchPath:@"/usr/local/bin/easy_install"];
    [task setArguments:@[@"-U", @"streamlink"]];
    pipe = nil;
    if (!pipe){
        pipe = [[NSPipe alloc] init];
    }
    [task setStandardOutput:pipe];
    [[task.standardOutput fileHandleForReading] setReadabilityHandler:^(NSFileHandle *file) {
        NSData *data = [file availableData]; // this will read to EOF, so call only once
        [weakSelf appendString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    }];
    [task setTerminationHandler:^(NSTask *task2) {
        [task2.standardOutput fileHandleForReading].readabilityHandler = nil;
        if ([task2 terminationStatus] != 0){
            [weakSelf appendString:@"Install failed"];
        }
        [weakSelf setStatusLabel:[task2 terminationStatus]];
    }];
    [task launch];
}
-(void)appendString:(NSString *)append{
    [_consoletext setString:[_consoletext.string stringByAppendingString:append]];
}
-(void)setStatusLabel:(int)exit{
    switch (exit){
        case 0:
            _statuslbl.stringValue = @"Installation successful";
            break;
        case 1:
            _statuslbl.stringValue = @"Installation failed";
            break;
            
    }
    [_closebtn setEnabled:true];
    [_progressind stopAnimation:nil];
    [_progressind setHidden:YES];
}
- (IBAction)closewindow:(id)sender {
    [self.window orderOut:self];
    [NSApp endSheet:self.window returnCode:0];
}

@end
