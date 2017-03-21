//
//  streamlinkdetector.h
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

#import <Foundation/Foundation.h>

@interface streamlinkdetector : NSObject{
    NSTask * task;
    NSPipe * pipe;
}
@property (strong, setter=setStreamURL:) NSString * streamurl;
@property (strong, setter=setargs:) NSString * args;
@property (strong, setter=setStream:) NSString * stream;
@property (strong, getter=getdetectinfo) NSArray * detectioninfo;
@property (getter=getStreamStatus) bool isstreaming;


-(bool)getDetectionInfo;
-(void)startStream;
-(void)stopStream;

@end
