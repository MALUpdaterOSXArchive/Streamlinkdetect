# Stramlinkdetect

Streamlinkdetect is a Objective-C framework and frontend for [streamlink](https://streamlink.github.io). It allows detection information to be parsed and then launch streamline with the arguments, stream url and stream.


## How to Build
1. You will need Xcode 8 or later to build this project
2. Clone the repo
3. Type xcodebuild to build the project

## How to use 
### Objective C
1. Copy the framework to your XCode Project
2. Add this to the header file.
```objective-c
#import <streamlinkdetect/streamlinkdetect.h>
```

To use, simply do the following:
```objective-c
	streamlinkdetector * detector = [streamlinkdetector new];

	// Setting the parameters
    [detector setStreamURL:@“http://www.crunchyroll.com/granblue-fantasy-the-animation/episode-1-untitled-729263”];
    [detector setStream:@“360p”];

	// Loads parsed information about a stream
    if ([detector getDetectionInfo]){
		NSLog(@“%@“,[detector getdetectinfo]);
    }

	// Starts the stream
	if (![detector getStreamStatus]){
        [detector startStream];
    }

	// Stops the stream
    if ([detector getStreamStatus]){
        [detector stopStream];
    }
```
## Documentation
Documentation coming soon.

## License

Stramlinkdetect is licensed under GNU Public License version 3.

This project uses portions of EasyNSURLConnection licensed under MIT License.
