//
//  BounceGalleryCell.m
//
//  Created by Eli Gregory on 4/13/15.
//  Copyright (c) 2015 Stublisher Inc. All rights reserved.
//

#import "BounceGalleryCell.h"

@interface BounceGalleryCell()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *playButton;
@end

@implementation BounceGalleryCell
@synthesize imageView = _imageView;
@synthesize imgRef = _imgRef;
@synthesize playButton = _playButton;

const CGFloat playButtonSize = 36.0f;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self setBackgroundColor: [UIColor whiteColor]];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView = imageView;
        self.imageView.contentMode = UIViewContentModeScaleToFill;
        self.imageView.clipsToBounds = YES;
        [self.imageView setBackgroundColor:[UIColor darkGrayColor]];
        
        [self.contentView addSubview:self.imageView];

        
        [self videoOverlay];
    }
    
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.imageView setFrame:self.bounds];
    
    [self videoOverlay];
}

-(void)videoOverlay
{
    if (_imgRef.isVideo)
    {
        if (!_playButton)
        {
            _playButton = [[UIImageView alloc] init];
            [_playButton setImage:[UIImage imageNamed:@"play"]];
            [self.contentView addSubview:_playButton];
        }
        [_playButton setFrame:CGRectMake((_imgRef.size.width/2.0f)-(playButtonSize/2.0f),
                                         (_imgRef.size.height/2.0f)-(playButtonSize/2.0f),
                                         playButtonSize,
                                         playButtonSize)];
    }
    else
    {
        if (_playButton)
        {
            [_playButton removeFromSuperview];
            _playButton = nil;
        }
    }
}

-(void)setImgRef:(BounceGalleryImageRef *)imgRef
{
    _imgRef = imgRef;

    if (imgRef)
    {
        UIImage *thumb = [_imgRef galleryThumb];
        
        if (thumb) [_imageView setImage:thumb];
    }
    else
    {
        [_imageView setImage:nil];
    }
    
    [self videoOverlay];
}

@end
