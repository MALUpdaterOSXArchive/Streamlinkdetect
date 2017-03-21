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
@end
