//
//  main.m
//  OGL30301
//
//  Created by aa64mac on 08/02/2017.
//  Copyright © 2017 cyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    setenv( "FILESYSTEM", argv[ 0 ], 1 );
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
