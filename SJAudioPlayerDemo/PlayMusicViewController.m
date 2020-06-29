//
//  PlayMusicViewController.m
//  SJAudioPlayerDemo
//
//  Created by 张诗健 on 2017/4/3.
//  Copyright © 2017年 张诗健. All rights reserved.
//

#import "PlayMusicViewController.h"
#import "SJAudioPlayer/SJAudioPlayer.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SJAudioPlayer/ZZAudioPlayer.h"

@interface PlayMusicViewController ()<SJAudioPlayerDelegate, ZZAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *musiceImageView;

@property (weak, nonatomic) IBOutlet UILabel *musicNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *artistLabel;

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (weak, nonatomic) IBOutlet UILabel *playedTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

@property (weak, nonatomic) IBOutlet UIButton *playOrPauseButton;

//@property (nonatomic, strong) SJAudioPlayer *player;

@property (nonatomic, strong) ZZAudioPlayer *player;

@property (nonatomic, strong) NSArray *musicList;

@property (nonatomic, strong) NSDictionary *currentMusicInfo;

@property (nonatomic, assign) NSInteger currentIndex;

@end


@implementation PlayMusicViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.titleLabel.text = @"SJAudioPlayer";
    
    // 允许接受远程控制
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    [self.slider addTarget:self action:@selector(sliderValueChanged:forEvent:) forControlEvents:UIControlEventValueChanged];
    
    /*
     播放本地音频文件
     
     NSString *path = [[NSBundle mainBundle] pathForResource:@"Sample" ofType:@"mp3"];
    
     NSURL *url = [NSURL fileURLWithPath:path];
    */
    
    
    
    /*
     播放远程音频文件
    */
    self.musicList = @[
                       @{@"music_url":@"http://music.163.com/song/media/outer/url?id=29723022.mp3", @"pic":@"https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=2904967709,1533413265&fm=26&gp=0.jpg", @"artist":@"刘德华", @"music_name":@"暗里着迷"},
                       @{@"music_url":@"http://music.163.com/song/media/outer/url?id=235690.mp3", @"pic":@"https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=2223849947,4164002656&fm=26&gp=0.jpg", @"artist":@"关淑怡", @"music_name":@"难得有情人"},
                       @{@"music_url":@"http://music.163.com/song/media/outer/url?id=263720.mp3", @"pic":@"https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=806489170,327517180&fm=26&gp=0.jpg", @"artist":@"刘小慧", @"music_name":@"初恋情人"},
                       @{@"music_url":@"http://music.163.com/song/media/outer/url?id=166321.mp3", @"pic":@"http://imgsrc.baidu.com/forum/w=580/sign=0828c5ea79ec54e741ec1a1689399bfd/e3d9f2d3572c11df80fbf7f7612762d0f703c238.jpg", @"artist":@"毛阿敏", @"music_name":@"爱上张无忌"}
                       ];
    
    self.currentIndex = 0;
    self.currentMusicInfo = self.musicList.firstObject;
    
    NSURL *url = [NSURL URLWithString:self.currentMusicInfo[@"music_url"]];
    
    //self.player = [[SJAudioPlayer alloc] initWithUrl:url delegate:self];
    
    self.player = [[ZZAudioPlayer alloc] initWithUrl:url delegate:self];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
}

- (void)updateProgress
{
    self.durationLabel.text   = [self timeIntervalToMMSSFormat:self.player.duration];
    self.playedTimeLabel.text = [self timeIntervalToMMSSFormat:self.player.progress];
    
    if (self.player.duration > 0.0)
    {
        self.slider.value = self.player.progress/self.player.duration;
        
        [self configNowPlayingInfoCenter];
    }else
    {
        self.slider.value = 0.0;
    }
}


- (IBAction)showMusicList:(id)sender
{
    
}


- (IBAction)likeTheMusic:(UIButton *)sender
{
    sender.selected = !sender.selected;
}


- (IBAction)changePlaySequence:(id)sender
{
    
}

- (IBAction)setPlayerPlayRate:(id)sender
{
    self.player.playRate = self.player.playRate > 1.0 ? 1.0 : 1.5;
}

- (IBAction)lastMusic:(id)sender
{
    self.currentIndex--;
    
    if (self.currentIndex < 0)
    {
        self.currentIndex = self.musicList.count - 1;
    }
    
    self.currentMusicInfo = self.musicList[self.currentIndex];
    
    [self.player stop];
    
    NSURL *url = [NSURL URLWithString:self.currentMusicInfo[@"music_url"]];
    
    //self.player = [[SJAudioPlayer alloc] initWithUrl:url delegate:self];
    
    self.player = [[ZZAudioPlayer alloc] initWithUrl:url delegate:self];
    
    [self.player play];
}


- (IBAction)nextMusic:(id)sender
{
    self.currentIndex++;
    
    if (self.currentIndex >= self.musicList.count)
    {
        self.currentIndex = 0;
    }
    
    self.currentMusicInfo = self.musicList[self.currentIndex];
    
    [self.player stop];
    
    NSURL *url = [NSURL URLWithString:self.currentMusicInfo[@"music_url"]];
    
    //self.player = [[SJAudioPlayer alloc] initWithUrl:url delegate:self];
    
    self.player = [[ZZAudioPlayer alloc] initWithUrl:url delegate:self];
    
    [self.player play];
}


- (IBAction)playOrPause:(UIButton *)sender
{
    if ([self.player isPlaying])
    {
        [self.player pause];
        
        self.playOrPauseButton.selected = NO;
    }else
    {
        [self.player play];
        
        self.playOrPauseButton.selected = YES;
    }
}

- (void)sliderValueChanged:(UISlider *)slider forEvent:(UIEvent *)event
{
    if ([[event allTouches] anyObject].phase == UITouchPhaseEnded)
    {
        [self.player seekToProgress:(slider.value * self.player.duration)];
    }
}



- (void)setCurrentMusicInfo:(NSDictionary *)currentMusicInfo
{
    _currentMusicInfo = currentMusicInfo;
    
    self.musicNameLabel.text = currentMusicInfo[@"music_name"];
    self.artistLabel.text    = currentMusicInfo[@"artist"];
    
    __weak typeof(self) weakself = self;
    
    [self.musiceImageView sd_setImageWithURL:[NSURL URLWithString:currentMusicInfo[@"pic"]] placeholderImage:[UIImage imageNamed:@"music_placeholder"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
        __strong typeof(weakself) strongself = weakself;
        
        strongself.backgroundImageView.image = image;
    }];
}


- (NSString *)timeIntervalToMMSSFormat:(NSTimeInterval)interval
{
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
}


#pragma mark- SJAudioPlayerDelegate
//- (void)audioPlayer:(SJAudioPlayer *)audioPlayer updateAudioDownloadPercentage:(float)percentage
//{
//    self.progressView.progress = percentage;
//}
//
//- (void)audioPlayer:(SJAudioPlayer *)audioPlayer statusDidChanged:(SJAudioPlayerStatus)status
//{
//    switch (status)
//    {
//        case SJAudioPlayerStatusIdle:
//        {
//            if (DEBUG)
//            {
//                NSLog(@"SJAudioPlayer: Idle");
//            }
//
//            self.playOrPauseButton.selected = NO;
//        }
//            break;
//        case SJAudioPlayerStatusWaiting:
//        {
//            if (DEBUG)
//            {
//                NSLog(@"SJAudioPlayer: Waiting");
//            }
//        }
//            break;
//        case SJAudioPlayerStatusPlaying:
//        {
//            if (DEBUG)
//            {
//                NSLog(@"SJAudioPlayer: Playing");
//            }
//
//            self.playOrPauseButton.selected = YES;
//        }
//            break;
//        case SJAudioPlayerStatusPaused:
//        {
//            if (DEBUG)
//            {
//                NSLog(@"SJAudioPlayer: Paused");
//            }
//
//            self.playOrPauseButton.selected = NO;
//        }
//            break;
//        case SJAudioPlayerStatusFinished:
//        {
//            if (DEBUG)
//            {
//                NSLog(@"SJAudioPlayer: Finished");
//            }
//
//            self.playOrPauseButton.selected = NO;
//
//            [self nextMusic:nil];
//        }
//            break;
//        default:
//            break;
//    }
//}


#pragma mark- ZZAudioPlayerDelegate
- (void)audioPlayer:(ZZAudioPlayer *)audioPlayer updateAudioDownloadPercentage:(float)percentage
{
    self.progressView.progress = percentage;
}

- (void)audioPlayer:(ZZAudioPlayer *)audioPlayer statusDidChanged:(ZZAudioPlayerStatus)status
{
    switch (status)
    {
        case ZZAudioPlayerStatusIdle:
        {
            if (DEBUG)
            {
                NSLog(@"SJAudioPlayer: Idle");
            }

            self.playOrPauseButton.selected = NO;
        }
            break;
        case ZZAudioPlayerStatusWaiting:
        {
            if (DEBUG)
            {
                NSLog(@"SJAudioPlayer: Waiting");
            }
        }
            break;
        case ZZAudioPlayerStatusPlaying:
        {
            if (DEBUG)
            {
                NSLog(@"SJAudioPlayer: Playing");
            }

            self.playOrPauseButton.selected = YES;
        }
            break;
        case ZZAudioPlayerStatusPaused:
        {
            if (DEBUG)
            {
                NSLog(@"SJAudioPlayer: Paused");
            }

            self.playOrPauseButton.selected = NO;
        }
            break;
        case ZZAudioPlayerStatusFinished:
        {
            if (DEBUG)
            {
                NSLog(@"SJAudioPlayer: Finished");
            }

            self.playOrPauseButton.selected = NO;

            [self nextMusic:nil];
        }
            break;
        default:
            break;
    }
}

- (void)audioPlayer:(ZZAudioPlayer *)audioPlayer errorOccurred:(NSError *)error
{
    NSLog(@"%@",error);
}


#pragma mark- 监听远程控制
- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeRemoteControl)
    {
        switch (event.subtype)
        {
            case UIEventSubtypeRemoteControlTogglePlayPause:
            {
                [self playOrPause:nil];
            }
                break;
                
            case UIEventSubtypeRemoteControlPlay:
            {
                [self playOrPause:nil];
            }
                break;
                
            case UIEventSubtypeRemoteControlPause:
            {
                [self playOrPause:nil];
            }
                break;
                
            case UIEventSubtypeRemoteControlStop:
            {
                [self.player stop];
            }
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
            {
                [self nextMusic:nil];
            }
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
            {
                [self lastMusic:nil];
            }
                break;
                
            default:
                break;
        }
    }
}

#pragma -mark 设置锁屏状态下音乐播放的信息(歌曲信息和图片)和播放进度更新
- (void)configNowPlayingInfoCenter
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    [dic setObject:self.currentMusicInfo[@"music_name"] forKey:MPMediaItemPropertyTitle];
    
    [dic setObject:self.currentMusicInfo[@"artist"] forKey:MPMediaItemPropertyAlbumTitle];
    
    // 当前音乐已经播放的时间
    [dic setObject:[NSNumber numberWithFloat:self.player.progress] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    
    // 设置进度光标的速度(原速播放)
    [dic setObject:[NSNumber numberWithFloat:1.0] forKey:MPNowPlayingInfoPropertyPlaybackRate];
    
    // 音乐的剩余播放时间
    [dic setObject:[NSNumber numberWithFloat:self.player.duration] forKey:MPMediaItemPropertyPlaybackDuration];
    
    // 设置锁屏封面
    MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:self.musiceImageView.image];
    
    [dic setObject:artwork forKey:MPMediaItemPropertyArtwork];
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dic];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
