//
//  BounceGallerySharing.h
//
//  Created by Eli Gregory on 5/7/15.
//  Copyright (c) 2015 Stublisher Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>
#import "BounceGalleryImageRef.h"

typedef enum
{
    SharingTypeFacebook,
    SharingTypeTwitter
}
SharingType;

@interface BounceGallerySharing : NSObject

+(instancetype)shared;

+(BOOL)canShareFacebook:(BounceGalleryImageRef*)img;
+(BOOL)canShareTwitter:(BounceGalleryImageRef*)img;
+(BOOL)canShareEmail:(BounceGalleryImageRef*)img;
+(BOOL)canShareMMS:(BounceGalleryImageRef*)img;

+(SLComposeViewController*)facebookShareImage:(BounceGalleryImageRef*)img;
+(SLComposeViewController*)twitterShareImage:(BounceGalleryImageRef*)img;
+(MFMailComposeViewController*)mailImage:(BounceGalleryImageRef*)img;
+(MFMessageComposeViewController*)mmsImage:(BounceGalleryImageRef*)img;

+(NSString*)SLStringForType:(SharingType)type;

@end
