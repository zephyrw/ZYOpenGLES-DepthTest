//
//  ViewController.m
//  ZYOpenGL-DepthTest
//
//  Created by wpsd on 2017/8/28.
//  Copyright © 2017年 wpsd. All rights reserved.
//

#import "ViewController.h"
#import "Const.h"
#import "ZYProgram.h"
#import "ZYCamera.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController ()

@property (strong, nonatomic) EAGLContext *glContext;
@property (assign, nonatomic) GLuint cubeVertexArray;
@property (assign, nonatomic) GLuint planeVertexArray;
@property (assign, nonatomic) GLuint grassVertexArray;
@property (assign, nonatomic) GLuint quadVertexArray;
@property (strong, nonatomic) ZYProgram *program;
@property (strong, nonatomic) ZYProgram *quadPragram;
@property (strong, nonatomic) GLKTextureInfo *cubeTextureInfo;
@property (strong, nonatomic) GLKTextureInfo *windowTextureInfo;
@property (assign, nonatomic) GLuint cubeTexture;
@property (assign, nonatomic) GLuint windowTexture;
@property (assign, nonatomic) GLuint planeTexture;
@property (assign, nonatomic) double currentXZValue;
@property (assign, nonatomic) double currentYValue;
@property (assign, nonatomic) double currentScale;
@property (strong, nonatomic) NSArray *windowsPositionArr;
@property (strong, nonatomic) ZYCamera *camera;
@property (assign, nonatomic) GLuint frameBuffer;
@property (assign, nonatomic) GLuint renderBuffer;
@property (assign, nonatomic) GLuint textureColorBuffer;
@property (assign, nonatomic) CGSize frameBufferSize;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupContext];
    [self setupVertexPoints];
    [self loadTexture];
    [self setupFrameBuffer];
    self.camera = [ZYCamera cameraWithView:self.view];
    
}

- (void)setupContext {
    
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!context) {
        NSLog(@"Failed to initialize context");
        return;
    }
    
    self.glContext = context;
    
    GLKView *glView = (GLKView *)self.view;
    glView.context = self.glContext;
    glView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    glView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [EAGLContext setCurrentContext:self.glContext];
    glEnable(GL_DEPTH_TEST);
    
}

- (void)setupVertexPoints {
    
    self.program = [ZYProgram programWithVertexShaderString:vertexShaderString fragmentShaderString:fragmentShaderString];
    
    GLuint positionLoc = [self.program attributeLocWithName:"position"];
    GLuint texCoordsLoc = [self.program attributeLocWithName:"texCoords"];
    
    glGenVertexArraysOES(1, &_cubeVertexArray);
    glBindVertexArrayOES(_cubeVertexArray);
    GLuint cubeVBO;
    glGenBuffers(1, &cubeVBO);
    glBindBuffer(GL_ARRAY_BUFFER, cubeVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(cubeVertices), cubeVertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(positionLoc);
    glVertexAttribPointer(positionLoc, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GL_FLOAT), (GLvoid *)0);
    glEnableVertexAttribArray(texCoordsLoc);
    glVertexAttribPointer(texCoordsLoc, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GL_FLOAT), (GLvoid *)(3 * sizeof(GL_FLOAT)));
    
    glGenVertexArraysOES(1, &_planeVertexArray);
    glBindVertexArrayOES(_planeVertexArray);
    GLuint planeVBO;
    glGenBuffers(1, &planeVBO);
    glBindBuffer(GL_ARRAY_BUFFER, planeVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(planeVertices), planeVertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(positionLoc);
    glVertexAttribPointer(positionLoc, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GL_FLOAT), (GLvoid *)0);
    glEnableVertexAttribArray(texCoordsLoc);
    glVertexAttribPointer(texCoordsLoc, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GL_FLOAT), (GLvoid *)(3 * sizeof(GL_FLOAT)));
    
    glGenVertexArraysOES(1, &_grassVertexArray);
    glBindVertexArrayOES(_grassVertexArray);
    GLuint grassVBO;
    glGenBuffers(1, &grassVBO);
    glBindBuffer(GL_ARRAY_BUFFER, grassVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(grassVertices), grassVertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(positionLoc);
    glVertexAttribPointer(positionLoc, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GL_FLOAT), (GLvoid *)0);
    glEnableVertexAttribArray(texCoordsLoc);
    glVertexAttribPointer(texCoordsLoc, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GL_FLOAT), (GLvoid *)(3 * sizeof(GL_FLOAT)));
    
    self.quadPragram = [ZYProgram programWithVertexShaderString:vertexShaderString fragmentShaderString:screenFragmentShaderString];
    
    glGenVertexArraysOES(1, &_quadVertexArray);
    glBindVertexArrayOES(_quadVertexArray);
    GLuint quadVBO;
    glGenBuffers(1, &quadVBO);
    glBindBuffer(1, quadVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(quadVertices), quadVertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(positionLoc);
    glVertexAttribPointer(positionLoc, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(GL_FLOAT), (GLvoid *)0);
    glEnableVertexAttribArray(texCoordsLoc);
    glVertexAttribPointer(texCoordsLoc, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(GL_FLOAT), (GLvoid *)(2 * sizeof(GL_FLOAT)));
    
    self.windowsPositionArr = @[[ZYVec3 vec3WithX:-1.5 y:0 z:-0.48],
                                [ZYVec3 vec3WithX: 1.5 y:0 z: 0.51],
                                [ZYVec3 vec3WithX: 0.0 y:0 z: 0.70],
                                [ZYVec3 vec3WithX:-0.3 y:0 z:-2.30],
                                [ZYVec3 vec3WithX: 0.5 y:0 z:-0.60]];
    
}

- (void)loadTexture {
    
    self.cubeTexture = [ZYProgram genTextureWithImageName:@"container2"];
    self.windowTexture = [ZYProgram genTextureWithImageName:@"grass"];
    self.planeTexture = [ZYProgram genTextureWithImageName:@"floor" wrapType:GL_REPEAT];
    
}

- (void)setupFrameBuffer {
    
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    // 生成颜色缓冲区的纹理对象并绑定到framebuffer上
    glGenTextures(1, &_textureColorBuffer);
    glBindTexture(GL_TEXTURE_2D, _textureColorBuffer);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, SCREEN_WIDTH * 2, SCREEN_HEIGHT * 2, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _textureColorBuffer, 0);
    
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, SCREEN_WIDTH * 2, SCREEN_HEIGHT * 2);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _renderBuffer);
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"ERROR::FRAMEBUFFER:: Framebuffer is not complete!");
    }
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
}


- (void)drawCubes {
    
    glBindVertexArrayOES(_cubeVertexArray);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.cubeTexture);
    [self.program setIntWithName:"texture" value:0];
    
    GLKMatrix4 cubeModel1 = GLKMatrix4MakeTranslation(-1.0, 0, -1.0);
    [self.program setMatrix4WithName:"model" mat4:cubeModel1];
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    GLKMatrix4 cubeModel2 = GLKMatrix4MakeTranslation(2.0, 0.0, 0.0);
    [self.program setMatrix4WithName:"model" mat4:cubeModel2];
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
}

- (void)drawPlane {
    
    glBindVertexArrayOES(_planeVertexArray);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, self.planeTexture);
    [self.program setIntWithName:"texture" value:1];
    
    GLKMatrix4 planeModel = GLKMatrix4MakeTranslation(0, 0, 0);
    [self.program setMatrix4WithName:"model" mat4:planeModel];
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
}

- (void)drawGrassWithCamX:(float)camX camY:(float)camY camZ:(float)camZ {
    
    glBindVertexArrayOES(_grassVertexArray);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, self.windowTexture);
    [self.program setIntWithName:"texture" value:2];
    
    NSArray *sortedArr = [self.windowsPositionArr sortedArrayWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        ZYVec3 *v1 = (ZYVec3 *)obj1;
        ZYVec3 *v2 = (ZYVec3 *)obj2;
        float d1 = powf(v1.x - camX, 2.0) + powf(v1.y - camY, 2.0) + powf(v1.z - camZ, 2.0);
        float d2 = powf(v2.x - camX, 2.0) + powf(v2.y - camY, 2.0) + powf(v2.z - camZ, 2.0);
        NSComparisonResult result = [[NSNumber numberWithFloat:d2] compare:[NSNumber numberWithFloat:d1]];
        return result;
    }];
    
    for (int i = 0; i < sortedArr.count; i++) {
        ZYVec3 *vec3 = sortedArr[i];
        GLKMatrix4 grassModel = GLKMatrix4MakeTranslation(vec3.x, vec3.y, vec3.z);
        [self.program setMatrix4WithName:"model" mat4:grassModel];
        glDrawArrays(GL_TRIANGLES, 0, 6);
    }
    
}

- (void)drawQuard {
    
    glBindVertexArrayOES(_quadVertexArray);
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, _textureColorBuffer);
    [self.quadPragram setIntWithName:"texture" value:3];
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glClearColor(0.1, 0.1, 0.1, 0.1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self.program use];
    
    GLKMatrix4 projection = GLKMatrix4MakePerspective(M_PI_4, SCREEN_WIDTH / SCREEN_HEIGHT, 0.1, 100);
    [self.program setMatrix4WithName:"projection" mat4:projection];
    
    [self.program setMatrix4WithName:"view" mat4:self.camera.lookAt];
    
    [self drawCubes];
    [self drawPlane];
    [self drawGrassWithCamX:self.camera.position.x camY:self.camera.position.y camZ:self.camera.position.z];
    
    [view bindDrawable];
    glClearColor(0.1, 0.2, 0.3, 0.1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self drawCubes];
    [self drawPlane];
    [self drawGrassWithCamX:self.camera.position.x camY:self.camera.position.y camZ:self.camera.position.z];
    
    CGFloat ratio = SCREEN_WIDTH / SCREEN_HEIGHT;
    [self.quadPragram use];
    [self.quadPragram setMatrix4WithName:"projection" mat4:GLKMatrix4MakeOrtho(-1 - 3.5 * ratio, 1.0, -4.5, 1, -100, 100)];
    [self.quadPragram setMatrix4WithName:"view" mat4:GLKMatrix4Identity];
    [self.quadPragram setMatrix4WithName:"model" mat4:GLKMatrix4Identity];
    [self drawQuard];
    
}


@end
