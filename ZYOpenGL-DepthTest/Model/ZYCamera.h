//
//  ZYCamera.h
//  ZYOpenGL-DepthTest
//
//  Created by wpsd on 2017/8/31.
//  Copyright © 2017年 wpsd. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface ZYCamera : NSObject

@property (assign, nonatomic, readonly) GLKMatrix4 lookAt;
@property (assign, nonatomic, readonly) GLKVector3 position;

+ (instancetype)cameraWithView:(UIView *)view;

@end
