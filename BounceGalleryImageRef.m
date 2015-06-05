//
//  BounceGalleryImageRef.m
//
//  Created by Eli Gregory on 4/13/15.
//  Copyright (c) 2015 Stublisher Inc. All rights reserved.
//

#import "BounceGalleryImageRef.h"

@interface BounceGalleryImageRef()
@property (nonatomic) ALAsset *asset;
@property (nonatomic, readwrite) BOOL isVideo;
@end

@implementation BounceGalleryImageRef
@synthesize size = _size;
@synthesize isVideo = _isVideo;
@synthesize asset = _asset;

+(BounceGalleryImageRef*)newWithAsset:(ALAsset*)asset
{
    if (! asset) return nil;
    
    BounceGalleryImageRef *gi = [[BounceGalleryImageRef alloc] initWithAsset:asset];
    [gi setIsVideo:([asset valueForProperty:ALAssetPropertyType] == ALAssetTypeVideo)];
    
    return gi;
}

-(id)initWithAsset:(ALAsset*)asset
{
    self = [super init];
    
    if (self)
    {
        _size = CGSizeMake(100.0f, 100.0f);
        _isVideo = FALSE;
        _asset = asset;
    }
    
    return self;
}

-(UIImage*)squareThumb
{
    return [UIImage imageWithCGImage:[_asset thumbnail]];
}

-(UIImage*)galleryThumb
{
    return [UIImage imageWithCGImage:[_asset aspectRatioThumbnail]];
}

-(UIImage*)fullRez
{
    NSNumber *orientation = [_asset valueForProperty:ALAssetPropertyOrientation];

    return [UIImage imageWithCGImage:[[_asset defaultRepresentation] fullResolutionImage] scale:1.0f orientation:orientation.integerValue];
}

-(NSData*)videoData
{
    ALAssetRepresentation *rep = [_asset defaultRepresentation];
    Byte *buffer = (Byte*)malloc(rep.size);
    NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
    return [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
}

-(NSURL*)videoAssetURL
{
    return (NSURL*)[_asset valueForProperty:@"ALAssetPropertyAssetURL"];
}

@end
