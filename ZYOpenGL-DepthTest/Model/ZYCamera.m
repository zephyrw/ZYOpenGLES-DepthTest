//
//  ZYCamera.m
//  ZYOpenGL-DepthTest
//
//  Created by wpsd on 2017/8/31.
//  Copyright © 2017年 wpsd. All rights reserved.
//

#import "ZYCamera.h"

@interface ZYCamera ()

@property (assign, nonatomic) double currentScale;
@property (assign, nonatomic) double currentXZValue;
@property (assign, nonatomic) double currentYValue;
@property (strong, nonatomic) UIView *displayView;

@end

@implementation ZYCamera

+ (instancetype)cameraWithView:(UIView *)view {
    return [[self alloc] initWithView:view];
}

- (instancetype)initWithView:(UIView *)view
{
    self = [super init];
    if (self) {
        self.displayView = view;
        [self setupGesture];
    }
    return self;
}

- (void)setupGesture {
    
    UIPanGestureRecognizer *panGest = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    [self.displayView addGestureRecognizer:panGest];
    
    self.currentScale = 1.0;
    UIPinchGestureRecognizer *pinchGest = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureAction:)];
    [self.displayView addGestureRecognizer:pinchGest];
    
}

- (void)panGestureAction:(UIPanGestureRecognizer *)panGest {
    
    CGPoint trans = [panGest translationInView:self.displayView];
    //    NSLog(@"%@", NSStringFromCGPoint(trans));
    
    self.currentXZValue -= trans.x * 0.001;
    self.currentYValue += trans.y * 0.001;
    
}

- (void)pinchGestureAction:(UIPinchGestureRecognizer *)pinch {
    
    double scale = 1.0;
    if (pinch.scale > 1) {
        scale = (pinch.scale - 1) * 0.1 + 1;
    } else {
        scale = 1 - (1 - pinch.scale) * 0.1;
    }
    self.currentScale /= scale;
    
}

- (GLKMatrix4)lookAt {
    
    float camX = sin(self.currentXZValue) * self.currentScale * 10;
    float camZ = cos(self.currentXZValue) * self.currentScale * 10;
    float camY = sin(self.currentYValue) * self.currentScale * 10;
    
    return GLKMatrix4MakeLookAt(camX, camY, camZ, 0, 0, 0, 0, 1, 0);
}

- (GLKVector3)position {
    
    float camX = sin(self.currentXZValue) * self.currentScale * 10;
    float camZ = cos(self.currentXZValue) * self.currentScale * 10;
    float camY = sin(self.currentYValue) * self.currentScale * 10;
    
    return  GLKVector3Make(camX, camY, camZ);
    
}

@end
