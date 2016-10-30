//
//  SpeechController.m
//  iOS10Speech_OC
//
//  Created by qianjn on 2016/10/30.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "SpeechController.h"
#import "XCSpeechRecognizer.h"
@interface SpeechController ()<XCSpeechRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UIButton *btn;

@property (nonatomic, strong) XCSpeechRecognizer *speech;
@end

@implementation SpeechController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.speech = [[XCSpeechRecognizer alloc] initWithLocaleIdentifier:@"en_US"];
    self.speech.delegate = self;
}


- (IBAction)startRecording:(id)sender {
    
    if ([self.speech isRunning]) {
        [self.speech stopRecording];
        [self.btn setTitle:@"开始录音" forState:UIControlStateNormal];
    } else {
        [self.speech startRecording];
        [self.btn setTitle:@"停止录音" forState:UIControlStateNormal];
    }
}



#pragma mark - XCSpeechRecognizerDelegate
- (void)recognizeDidStart:(NSError *)error
{
    NSLog(@"-----error%@", error);
}
- (void)recognizeDidStop
{

    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"录音结束" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [view show];
    
}
- (void)recognizeFail:(NSError *)error
{
    NSLog(@"-----fail%@", error);
}
- (void)recognizeSuccess:(NSString *)result
{
    [_textView setText:[NSString stringWithFormat:@"%@", result]];
}
- (void)recognizeFinish
{
    
}
@end
