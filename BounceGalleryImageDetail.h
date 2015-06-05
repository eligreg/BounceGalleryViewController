//
//  BounceGalleryImageDetail.h
//
//  Created by Eli Gregory on 5/7/15.
//  Copyright (c) 2015 Stublisher Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "BounceGalleryImageRef.h"
#import <MediaPlayer/MediaPlayer.h>

@interface BounceGalleryImageDetail : UIViewController <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>

-(id)initWithImageRef:(BounceGalleryImageRef*)ref;

@end
