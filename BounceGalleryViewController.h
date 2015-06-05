//
//  BounceGalleryViewController.h
//
//  Created by Eli Gregory on 4/13/15.
//  Copyright (c) 2015 Stublisher Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BounceGalleryViewController : UICollectionViewController

-(id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout andAssets:(NSArray*)assets;

-(void)addImagesFromAssetsInBatch:(NSArray*)assetsbatch;

@property (nonatomic) CGFloat imgToScreenAspectRatio;

@end
