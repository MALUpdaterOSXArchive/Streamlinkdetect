//
//  AppDelegate.m
//  streamlink Installer
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

#import "AppDelegate.h"
#import "streamlinkinstall.h"

@interface AppDelegate ()

@property (strong) streamlinkinstall * streamlinkinstallw;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [self installStreamLink];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(void)installStreamLink{
    _streamlinkinstallw = [streamlinkinstall new];
    [NSApp beginSheet:_streamlinkinstallw.window
       modalForWindow:nil modalDelegate:self
       didEndSelector:@selector(streamlinkinstallDidEnd:returnCode:contextInfo:)
          contextInfo:(void *)nil];
}
-(void)streamlinkinstallDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    // Close helper application
    [[NSApplication sharedApplication] terminate:nil];
}
@end
