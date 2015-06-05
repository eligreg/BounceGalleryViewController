//
//  BounceGallerySharing.m
//
//  Created by Eli Gregory on 5/7/15.
//  Copyright (c) 2015 Stublisher Inc. All rights reserved.
//

#import "BounceGallerySharing.h"
@import MobileCoreServices;

@implementation BounceGallerySharing

+(instancetype)shared
{
    static dispatch_once_t onceToken;
    __strong static BounceGallerySharing *s = nil;
    
    dispatch_once(&onceToken, ^
                  {
                      s = [[self alloc] init];
                  });
    return s;
}

+(BOOL)canShareFacebook:(BounceGalleryImageRef*)img
{
    return ([SLComposeViewController isAvailableForServiceType:[BounceGallerySharing SLStringForType:SharingTypeFacebook]]
            && !img.isVideo);
}

+(BOOL)canShareTwitter:(BounceGalleryImageRef*)img
{
    return ([SLComposeViewController isAvailableForServiceType:[BounceGallerySharing SLStringForType:SharingTypeTwitter]]
            && !img.isVideo);
}

+(BOOL)canShareEmail:(BounceGalleryImageRef*)img
{
    return [MFMailComposeViewController canSendMail];
}

+(BOOL)canShareMMS:(BounceGalleryImageRef*)img
{
    NSString *uti;
    
    if (img.isVideo) uti = (NSString*)kUTTypeMovie;
    else uti = (NSString*)kUTTypeJPEG;
    
    return ([MFMessageComposeViewController canSendAttachments] &&
            [MFMessageComposeViewController isSupportedAttachmentUTI:uti]);
}

+(SLComposeViewController*)facebookShareImage:(BounceGalleryImageRef*)img
{
    if (![BounceGallerySharing canShareFacebook:img]) return nil;
    
    if (!img) return nil;
    
    SLComposeViewController *compose =
    [SLComposeViewController composeViewControllerForServiceType:[BounceGallerySharing SLStringForType:SharingTypeFacebook]];
    
    [compose addImage:[img fullRez]];
    
    return compose;
}

+(SLComposeViewController*)twitterShareImage:(BounceGalleryImageRef*)img
{
    if (![BounceGallerySharing canShareTwitter:img]) return nil;
    
    if (!img) return nil;
    
    SLComposeViewController *compose =
    [SLComposeViewController composeViewControllerForServiceType:[BounceGallerySharing SLStringForType:SharingTypeTwitter]];
    
    [compose addImage:[img fullRez]];
    
    return compose;
}

+(MFMailComposeViewController*)mailImage:(BounceGalleryImageRef*)img
{
    if (![BounceGallerySharing canShareEmail:img]) return nil;
    
    if (!img) return nil;
    
    MFMailComposeViewController *compose = [[MFMailComposeViewController alloc] init];
    
    NSData *imgData;
    
    if (img.isVideo)
    {
        imgData = [img videoData];
        [compose addAttachmentData:imgData mimeType:@"video/mp4" fileName:@"video.mp4"];
    }
    else
    {
        imgData = UIImageJPEGRepresentation([img fullRez], 0.8f);
        [compose addAttachmentData:imgData mimeType:@"image/jpeg" fileName:@"photo.jpg"];
    }
    
    return compose;
}

+(MFMessageComposeViewController*)mmsImage:(BounceGalleryImageRef*)img
{
    if (![BounceGallerySharing canShareMMS:img]) return nil;
    
    if (!img) return nil;
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    
    NSData *imgData;
    
    if (img.isVideo)
    {
        imgData = [img videoData];
        [messageController addAttachmentData:imgData typeIdentifier:@"public.video" filename:@"video.mp4"];
    }
    else
    {
        imgData = UIImageJPEGRepresentation([img fullRez], 0.8f);
        [messageController addAttachmentData:imgData typeIdentifier:@"public.image" filename:@"image.png"];
    }
    
    return messageController;
}

+(NSString*)SLStringForType:(SharingType)type
{
    switch (type)
    {
        case SharingTypeFacebook: { return SLServiceTypeFacebook; }
            break;
            
        case SharingTypeTwitter: { return SLServiceTypeTwitter; }
            break;
            
        default: return nil;
            break;
    }
}

@end
