//
//  BounceGalleryImageRef.h
//
//  Created by Eli Gregory on 4/13/15.
//  Copyright (c) 2015 Stublisher Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ASsetsLibrary/AssetsLibrary.h> 

@interface BounceGalleryImageRef : NSObject

+(BounceGalleryImageRef*)newWithAsset:(ALAsset*)asset;

-(UIImage*)squareThumb;
-(UIImage*)galleryThumb;
-(UIImage*)fullRez;

-(NSData*)videoData;
-(NSURL*)videoAssetURL;

@property (nonatomic) CGSize size;
@property (nonatomic, readonly) BOOL isVideo;

@end
