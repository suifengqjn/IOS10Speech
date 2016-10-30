//
//  FileViewController.m
//  iOS10Speech_OC
//
//  Created by qianjn on 2016/10/30.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "FileViewController.h"
#import <Speech/Speech.h>

@interface FileViewController ()

@end

@implementation FileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        BOOL isAuthorized = NO;
        
        switch (status) {
                //结果未知 用户尚未进行选择
            case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                isAuthorized = NO;
                break;
                //用户拒绝授权语音识别
            case SFSpeechRecognizerAuthorizationStatusDenied:
                isAuthorized = NO;
                break;
                //设备不支持语音识别功能
            case SFSpeechRecognizerAuthorizationStatusRestricted:
                isAuthorized = NO;
                break;
                //用户授权语音识别
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
                isAuthorized = YES;
                
                break;
                
            default:
                break;
        }
        
    }];
}

- (IBAction)start:(id)sender {
    
    //初始化一个识别器
    SFSpeechRecognizer *recognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"zh_CN"]];
    
    //初始化mp3的url
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"test.mp3" withExtension:nil];
    
    //初始化一个识别的请求
    SFSpeechURLRecognitionRequest *request = [[SFSpeechURLRecognitionRequest alloc] initWithURL:url];
    
    //发起请求
    [recognizer recognitionTaskWithRequest:request resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        if(error != nil)
        {
            NSLog(@"识别错误:%@",error);
        }
        
        NSString *resultString = result.bestTranscription.formattedString;
        NSLog(@"%@",resultString);
        
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:resultString message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [view show];
    }];
}


@end
