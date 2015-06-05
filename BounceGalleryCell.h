//
//  BounceGalleryCell.h
//
//  Created by Eli Gregory on 4/13/15.
//  Copyright (c) 2015 Stublisher Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "BounceGalleryImageRef.h"

@interface BounceGalleryCell : UICollectionViewCell

- (id)initWithFrame:(CGRect)frame;

@property (nonatomic, strong) BounceGalleryImageRef *imgRef;

@end
