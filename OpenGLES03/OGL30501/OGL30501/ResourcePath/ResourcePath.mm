//
// Licensed under the terms in LICENSE.txt
//
// Copyright 2014 Tom Dalling. All rights reserved.
//

#import "ResourcePath.hpp"
#import <Foundation/Foundation.h>

// returns the full path to the file `fileName` in the resources directory of the app bundle
std::string ResourcePath(std::string fileName, std::string ext) {
    NSString* fname = [NSString stringWithCString:fileName.c_str() encoding:NSUTF8StringEncoding];
    NSString* extName = [NSString stringWithCString:ext.c_str() encoding:NSUTF8StringEncoding];
    NSString * path = [[NSBundle mainBundle] pathForResource:fname
                                                      ofType:extName];
    //NSString* path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fname];
    return std::string([path cStringUsingEncoding:NSUTF8StringEncoding]);
}
