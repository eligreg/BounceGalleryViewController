//
//  BounceGalleryImageDetail.m
//
//  Created by Eli Gregory on 5/7/15.
//  Copyright (c) 2015 Stublisher Inc. All rights reserved.
//

#import "BounceGalleryImageDetail.h"
#import "BounceGallerySharing.h"

@interface BounceGalleryImageDetail ()
{
    BOOL sharePresent;
    BOOL hideButtons;
    
    UIScrollView *scroller;
    UIImageView *iv;
    UIImage *img;
    
    UIButton *exit;
    UIButton *share;
    
    UIButton *mail;
    UIButton *facebook;
    UIButton *twitter;
    UIButton *mms;
    
    UIButton *playButton;
    MPMoviePlayerViewController *moviePlayerVC;
    
    NSArray *buttons;
}
@property (nonatomic) BounceGalleryImageRef *i_ref;
@end

@implementation BounceGalleryImageDetail
@synthesize i_ref = _i_ref;

const CGFloat exit_button_size = 36.0f;

-(id)initWithImageRef:(BounceGalleryImageRef*)ref
{
    if (!ref) return nil;
    
    self = [super init];
    
    if (self)
    {
        _i_ref = ref;
        [self setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        sharePresent = FALSE;
        hideButtons = FALSE;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self buildView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self adjustShareButtons];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
}

-(void)buildView
{
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    scroller = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [scroller setContentMode:UIViewContentModeCenter];
    [scroller setContentSize:scroller.frame.size];
    [scroller setDelegate:self];
    [scroller setBackgroundColor:[UIColor blackColor]];
    [scroller setBounces:TRUE];
    [self.view addSubview:scroller];
    
    img = _i_ref.fullRez;
    
    CGRect r = AspectFitRectInRect(CGRectMake(0.0f, 0.0f, img.size.width, img.size.height), scroller.bounds);

    iv = [[UIImageView alloc] initWithFrame:r];
    [iv setContentMode:UIViewContentModeScaleAspectFit];
    [iv setImage:img];
    [iv setCenter:scroller.center];
    [iv setUserInteractionEnabled:TRUE];

    [scroller addSubview:iv];
    [scroller setNeedsDisplay];
    
    [self adjustZoomScale];
    
    if ([_i_ref isVideo])
    {
        CGFloat playButtonSize = 68.0f;
        playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [playButton setFrame:CGRectMake(0.0f, 0.0f, playButtonSize, playButtonSize)];
        [playButton setImage:[UIImage imageNamed:@"playLarge"] forState:UIControlStateNormal];
        [playButton addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
        [playButton setCenter:CGPointMake(iv.bounds.size.width*0.5f, iv.bounds.size.height*0.5f)];
        [iv addSubview:playButton];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedScreen:)];
    [tap setDelaysTouchesBegan:FALSE];
    [tap setDelegate:self];
    [scroller addGestureRecognizer:tap];
    
    exit = [UIButton buttonWithType:UIButtonTypeCustom];
    [exit addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [exit setImage:[UIImage imageNamed:@"exit"] forState:UIControlStateNormal];
    [self.view addSubview:exit];
    
    NSMutableArray *buttons_tmp = [NSMutableArray array];
    
    if ([BounceGallerySharing canShareEmail:_i_ref])
    {
        mail = [UIButton buttonWithType:UIButtonTypeCustom];
        [mail addTarget:self action:@selector(sharingUsingMedia:) forControlEvents:UIControlEventTouchUpInside];
        [mail setImage:[UIImage imageNamed:@"mail"] forState:UIControlStateNormal];
        [self.view addSubview:mail];
        [buttons_tmp addObject:mail];
    }
    
    if ([BounceGallerySharing canShareMMS:_i_ref])
    {
        mms = [UIButton buttonWithType:UIButtonTypeCustom];
        [mms addTarget:self action:@selector(sharingUsingMedia:) forControlEvents:UIControlEventTouchUpInside];
        [mms setImage:[UIImage imageNamed:@"mms"] forState:UIControlStateNormal];
        [self.view addSubview:mms];
        [buttons_tmp addObject:mms];
    }
    
    if ([BounceGallerySharing canShareFacebook:_i_ref])
    {
        facebook = [UIButton buttonWithType:UIButtonTypeCustom];
        [facebook addTarget:self action:@selector(sharingUsingMedia:) forControlEvents:UIControlEventTouchUpInside];
        [facebook setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
        [self.view addSubview:facebook];
        [buttons_tmp addObject:facebook];
    }
    
    if ([BounceGallerySharing canShareTwitter:_i_ref])
    {
        twitter = [UIButton buttonWithType:UIButtonTypeCustom];
        [twitter addTarget:self action:@selector(sharingUsingMedia:) forControlEvents:UIControlEventTouchUpInside];
        [twitter setImage:[UIImage imageNamed:@"twitter"] forState:UIControlStateNormal];
        [self.view addSubview:twitter];
        [buttons_tmp addObject:twitter];
    }
    
    if (buttons_tmp.count)
    {
        buttons = [NSArray arrayWithArray:buttons_tmp];
        
        share = [UIButton buttonWithType:UIButtonTypeCustom];
        [share addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
        [share setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        [self.view addSubview:share];
    }
    
    [self adjustShareButtons];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{

    if (touch.view == playButton) return FALSE;
    else return TRUE;
}

CGFloat ScaleToAspectFitRectInRect(CGRect rfit, CGRect rtarget)
{
    // first try to match width
    CGFloat s = CGRectGetWidth(rtarget) / CGRectGetWidth(rfit);
    // if we scale the height to make the widths equal, does it still fit?
    if (CGRectGetHeight(rfit) * s <= CGRectGetHeight(rtarget)) {
        return s;
    }
    // no, match height instead
    return CGRectGetHeight(rtarget) / CGRectGetHeight(rfit);
}

CGRect AspectFitRectInRect(CGRect rfit, CGRect rtarget)
{
    CGFloat s = ScaleToAspectFitRectInRect(rfit, rtarget);
    CGFloat w = CGRectGetWidth(rfit) * s;
    CGFloat h = CGRectGetHeight(rfit) * s;
    CGFloat x = CGRectGetMidX(rtarget) - w / 2;
    CGFloat y = CGRectGetMidY(rtarget) - h / 2;
    return CGRectMake(x, y, w, h);
}

CGFloat ScaleToAspectFitRectAroundRect(CGRect rfit, CGRect rtarget)
{
    // fit in the target inside the rectangle instead, and take the reciprocal
    return 1 / ScaleToAspectFitRectInRect(rtarget, rfit);
}

CGRect AspectFitRectAroundRect(CGRect rfit, CGRect rtarget)
{
    CGFloat s = ScaleToAspectFitRectAroundRect(rfit, rtarget);
    CGFloat w = CGRectGetWidth(rfit) * s;
    CGFloat h = CGRectGetHeight(rfit) * s;
    CGFloat x = CGRectGetMidX(rtarget) - w / 2;
    CGFloat y = CGRectGetMidY(rtarget) - h / 2;
    return CGRectMake(x, y, w, h);
}

-(void)adjustZoomScale
{
    // Turning off zooming for now.
    
//    if (!_i_ref.isVideo)
//    {
//        scroller.maximumZoomScale = img.size.width / scroller.bounds.size.width;
//        scroller.minimumZoomScale = 1.0f;
//    }
//    else
//    {
        scroller.maximumZoomScale = 1.0f;
        scroller.minimumZoomScale = 1.0f;
//    }
}

-(void)share
{
    sharePresent = !sharePresent;
    [self adjustShareButtons];
}

-(void)playVideo
{
    if (moviePlayerVC) moviePlayerVC = nil;
    
    moviePlayerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[_i_ref videoAssetURL]];
    
    // Remove observer that the MPMoviePlayerViewController would use to know when to dismiss.
    [[NSNotificationCenter defaultCenter] removeObserver:moviePlayerVC
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:moviePlayerVC.moviePlayer];
    
    // Add my own so that I can mod the animation.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:moviePlayerVC.moviePlayer];
    
    moviePlayerVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:moviePlayerVC animated:TRUE completion:nil];
    
    [moviePlayerVC.moviePlayer prepareToPlay];
    [moviePlayerVC.moviePlayer play];
}

- (void)movieFinishedCallback:(NSNotification*)aNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:moviePlayerVC.moviePlayer];
    
    [moviePlayerVC dismissViewControllerAnimated:TRUE completion:^
    {
        moviePlayerVC = nil;
        hideButtons = FALSE;
        sharePresent = FALSE;
        [self adjustShareButtons];
    }];
}

-(void)adjustShareButtons
{
    CGRect b = self.view.bounds;
    CGFloat w = b.size.width;
    CGFloat h = b.size.height;
    
    [exit setFrame:CGRectOffset(CGRectMake(w-exit_button_size, h-exit_button_size, exit_button_size, exit_button_size),
                                -exit_button_size*0.75f, -exit_button_size*0.75f)];
    
    if (share) [share setFrame:CGRectOffset(exit.frame, 0.0f, -exit_button_size*1.75f)];

    CGFloat animDur = 0.15f;
    
    if (!sharePresent && !hideButtons) // hide share buttons
    {
        [UIView animateKeyframesWithDuration:animDur delay:0.0f options:0 | UIViewAnimationOptionCurveEaseIn animations:^
        {
            for (UIButton *b in buttons)
            {
                [b setFrame:share.frame];
                [b setAlpha:0.0f];
            }
        }
        completion:nil];

    }
    else if (sharePresent && !hideButtons) // show share buttons
    {
        [UIView animateKeyframesWithDuration:animDur delay:0.0f options:0 | UIViewAnimationOptionCurveEaseIn animations:^
         {
             for (int i = 0; i < buttons.count; i++)
             {
                 UIButton *b = buttons[i];
                 [b setFrame:[self outFrameForIndex:i]];
                 [b setAlpha:1.0f];
             }
         }
         completion:nil];
    }
    [UIView animateKeyframesWithDuration:animDur delay:0.0f options:0 | UIViewAnimationOptionCurveEaseIn animations:^
    {
        if (share) [share setAlpha:(CGFloat)!hideButtons && !sharePresent];
        [exit setAlpha:(CGFloat)!hideButtons];
    }
     completion:nil];
}

-(void)sharingUsingMedia:(id)sender
{
    UIButton *from = (UIButton*)sender;
    
    if (from == mail)
    {
        MFMailComposeViewController *ml = [BounceGallerySharing mailImage:_i_ref];
        [ml setMailComposeDelegate:self];
        [self presentViewController:ml animated:TRUE completion:nil];
    }
    else if (from == mms)
    {
        MFMessageComposeViewController *mm = [BounceGallerySharing mmsImage:_i_ref];
        [mm setMessageComposeDelegate:self];
        [self presentViewController:mm animated:TRUE completion:nil];
    }
    else if (from == facebook)
    {
        SLComposeViewController *fb = [BounceGallerySharing facebookShareImage:_i_ref];
        [fb setCompletionHandler:^(SLComposeViewControllerResult result)
        {
            sharePresent = !sharePresent;
            [self adjustShareButtons];
        }];
        [self presentViewController:fb animated:true completion:nil];
    }
    else if (from == twitter)
    {
        SLComposeViewController *tw = [BounceGallerySharing twitterShareImage:_i_ref];
        [tw setCompletionHandler:^(SLComposeViewControllerResult result)
         {
             sharePresent = !sharePresent;
             [self adjustShareButtons];
         }];
        [self presentViewController:tw animated:true completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [controller dismissViewControllerAnimated:TRUE completion:^
    {
        sharePresent = !sharePresent;
        [self adjustShareButtons];
    }];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:TRUE completion:^
    {
        sharePresent = !sharePresent;
        [self adjustShareButtons];
    }];
}

-(void)userTappedScreen:(id)sender
{
    if (sharePresent) sharePresent = !sharePresent;

    else hideButtons = !hideButtons;

    [self adjustShareButtons];

}

-(CGRect)outFrameForIndex:(NSUInteger)i
{
    return CGRectOffset(share.frame, 0.0f, -exit_button_size * 1.75f * i);
}

-(void)dismiss
{
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden { return TRUE; }

- (BOOL)shouldAutorotate
{
    return TRUE;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (self.isViewLoaded && self.view.window) return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
    
    else return UIInterfaceOrientationMaskPortrait;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return iv;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    // This can be wayy improved.
    
    [scroller setFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    [scroller setContentSize:scroller.frame.size];
    
    CGRect r = AspectFitRectInRect(CGRectMake(0.0f, 0.0f, img.size.width, img.size.height), scroller.bounds);
    [iv setFrame:r];
    [iv setCenter:scroller.center];
    
    if ([_i_ref isVideo]) [playButton setCenter:CGPointMake(iv.bounds.size.width*0.5f, iv.bounds.size.height*0.5f)];
    
    [scroller setNeedsDisplay];

    sharePresent = FALSE;
    [self adjustShareButtons];
    
    NSMutableArray *buttons_a = [NSMutableArray arrayWithObjects:exit, nil];
    if (share) [buttons_a addObject:share];
    if (mail) [buttons_a addObject:mail];
    if (facebook) [buttons_a addObject:facebook];
    if (twitter) [buttons_a addObject:twitter];
    if (mms) [buttons_a addObject:mms];
    for (UIButton *b in buttons_a) [b setAlpha:0.0f];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
    {
        for (UIButton *b in buttons) [b setEnabled:TRUE];
        
        [self adjustShareButtons];
        
        [self adjustZoomScale];
    }];
}


@end
