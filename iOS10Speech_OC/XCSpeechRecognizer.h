//
//  XCSpeechRecognizer.h
//  ios10Speech
//
//  Created by qianjn on 2016/10/30.
//  Copyright © 2016年 SF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Speech/Speech.h>

typedef void(^XCSpeechAuthorizationCallback)(BOOL authorized, SFSpeechRecognizerAuthorizationStatus status);

@protocol XCSpeechRecognizerDelegate <NSObject>

- (void)recognizeDidStart:(NSError *)error;
- (void)recognizeDidStop;
- (void)recognizeFail:(NSError *)error;
- (void)recognizeSuccess:(NSString *)result;
- (void)recognizeFinish;

@end

@interface XCSpeechRecognizer : NSObject

@property (nonatomic, assign) id <XCSpeechRecognizerDelegate> delegate;
@property (nonatomic, readonly, assign) BOOL isRunning;

- (instancetype)initWithLocaleIdentifier:(NSString *)localeIdentifier;
- (void)checkSpeechAuthorization:(XCSpeechAuthorizationCallback)callback;
- (void)startRecording;
- (void)stopRecording;

@end
