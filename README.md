
# IOS10 语音识别详解
公司项目需要实现语音搜索，正好记录一下这个iOS10新出的API。

	iOS10是一个变化比价大的版本，开放了很多借口，这样也更方便开发者自定义各种功能。本文主要讲解一下新增的Speech框架，有了这个框架，我们想要为自己的app增加语音识别功能，不要依赖第三方的服务，几十行代码就可以轻松搞定。demo地址在文章末尾。

### 一：基本配置
- Xcode8，iOS10系统真机
- 导入头文件：OC `#import<Speech/Speech.h>`   swift `import Speech`
- 配置info.plist文件:配置两个权限，语音识别和麦克风


```
<key>NSMicrophoneUsageDescription</key>
    <string>Your microphone will be used to record your speech when you press the "Start Recording" button.</string>
    
    <key>NSSpeechRecognitionUsageDescription</key>
    <string>Speech recognition will be used to determine which words you speak into this device's microphone.</string>
  
```
### 二：用到的几个类

` AVAudioEngine `                           语音引擎，负责提供语音输入
` SFSpeechAudioBufferRecognitionRequest `   处理语音识别请求
` SFSpeechRecognizer`                       语音识别器
` SFSpeechRecognitionTask `                 输出语音识别对象的结果
` NSLocale `                                语言类型               
语音识别一共就用到了这几个类，整体的流程也容易理解，语音识别器通过语音引擎，处理语音识别请求，把结果交给`SFSpeechRecognitionTask`处理，最后输出文字。
` SFSpeechRecognizer` 自身有几个代理方法，实际上，如果只是将语音转化成文字，是不需要这几个代理方法的。

```
//当开始检测音频源中的语音时首先调用此方法
-(void)speechRecognitionDidDetectSpeech:(SFSpeechRecognitionTask *)task
{
  
}
//当识别出一条可用的信息后 会调用
/*需要注意，apple的语音识别服务会根据提供的音频源识别出多个可能的结果 每有一条结果可用 都会调用此方法 */
-(void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didHypothesizeTranscription:(SFTranscription *)transcription
{
   
}
//当识别完成所有可用的结果后调用
- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishRecognition:(SFSpeechRecognitionResult *)recognitionResult
{
    
}
//当不再接受音频输入时调用 即开始处理语音识别任务时调用
- (void)speechRecognitionTaskFinishedReadingAudio:(SFSpeechRecognitionTask *)task
{
    
}
//当语音识别任务被取消时调用
- (void)speechRecognitionTaskWasCancelled:(SFSpeechRecognitionTask *)task
{
    
}
//语音识别任务完成时被调用
- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishSuccessfully:(BOOL)successfully
{

}
```

### 三：重点代码
有两点需要注意：

* 语音识别会很耗电以及会使用很多数据
* 语音识别一次只持续大概一分钟的时间

我先定义了这几个属性

```
@property (nonatomic, strong) AVAudioEngine         *audioEngine;
@property (nonatomic, strong) SFSpeechRecognizer    *speechRecognizer;
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest     *recognitionRequest;
@property (nonatomic, strong) SFSpeechRecognitionTask   *recognitionTask;
@property (nonatomic, strong) NSLocale                  *locale;
```
1. 语音权限的判断
```
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
        
        if (callback) {
            callback(isAuthorized, status);
        }
    }];
```
2. 将语音引擎得到的语音数据添加到语音识别的请求中，这个过程也就是开始录音后的流程
```
AVAudioFormat *recordingFormat = [[self.audioEngine inputNode] outputFormatForBus:0];
    [[self.audioEngine inputNode] installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [self.recognitionRequest appendAudioPCMBuffer:buffer];
    }];
```

3. `SFSpeechRecognitionTask ` 把上一过程中得到的语音请求转化成文字，这个过程是试试进行的。

```
self.recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:self.recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        BOOL isFinal = NO;
        NSString *bestResult = [[result bestTranscription] formattedString];
        isFinal = result.isFinal;
        if (error || isFinal) {
            [self endTask];
            if (self.delegate && [self.delegate respondsToSelector:@selector(recognizeFail:)]) {
                [self.delegate recognizeFail:error];
            }
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(recognizeSuccess:)]) {
                [self.delegate recognizeSuccess:bestResult];
            }
        }
    }];
```
### 四：提取录音文件中的文字
1. 也需要先获取用户的授权，授权代码与上面一致。
2. 对文件的处理相对较为简单
```
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
        
    }];
```


[个人blog:http://gcblog.github.io](http://gcblog.github.io)
[简书blog:http://www.jianshu.com/users/527ecf8c8753/latest_articles](http://www.jianshu.com/users/527ecf8c8753/latest_articles)


