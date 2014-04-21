//
//  main.m
//  Alert
//
//  Created by Andrey Andreev on 4/15/11.
//  Copyright 2011 MicroStrategy. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    const char *prefix = "GCOV_PREFIX";
    const char *prefixValue = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] cStringUsingEncoding:NSASCIIStringEncoding]; // This gets the filepath to the app's Documents directory
    const char *prefixStrip = "GCOV_PREFIX_STRIP";
    const char *prefixStripValue = "1";
    setenv(prefix, prefixValue, 1); // This sets an environment variable which tells gcov where to put the .gcda files.
    setenv(prefixStrip, prefixStripValue, 1); // This tells gcov to strip the default prefix, and use the filepath that we just declared.

    
    @autoreleasepool {
		NSString* appClass = @"UIApplicationWithEvents"; 
    int retVal = UIApplicationMain(argc, argv, appClass, nil);
    return retVal;
    }
}
