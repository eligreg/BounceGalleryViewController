//
//  BounceGalleryViewController.m
//
//  Created by Eli Gregory on 4/13/15.
//  Copyright (c) 2015 Stublisher Inc. All rights reserved.
//

#import "BounceGalleryViewController.h"
#import "BounceGalleryFlowLayout.h"
#import "BounceGalleryCell.h"
#import "BounceGalleryImageRef.h"
#import "BounceGalleryImageDetail.h"

@interface BounceGalleryViewController ()
{
    NSUInteger page;
    
    dispatch_queue_t queue;
    dispatch_group_t group;
    
    BounceGalleryImageDetail *detail;
}
@property (nonatomic) NSMutableArray *imgs;
@end

@implementation BounceGalleryViewController
@synthesize imgToScreenAspectRatio = _imgToScreenAspectRatio;
@synthesize imgs = _imgs;

static NSString * const reuseIdentifier = @"Cell";
const CGFloat exit_button_size = 36.0f;

static CGSize CGSizeResizeToHeight(CGSize size, CGFloat height) {
    size.width *= height / size.height;
    size.height = height;
    return size;
}

-(id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout andAssets:(NSArray*)assets
{
    if (assets.count == 0) return nil;
    
    self = [self initWithCollectionViewLayout:layout];
    
    if (self)
    {
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        group = dispatch_group_create();
        page = 0;
        _imgToScreenAspectRatio = 4.5f;
        _imgs = [NSMutableArray array];
        [self initAssets:assets];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.collectionView registerClass:[BounceGalleryCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView setBackgroundColor: [UIColor blackColor]];
    
    [self insertExitButton];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    detail = nil;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)insertExitButton
{
    UIButton *exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [exitButton setFrame:CGRectMake(exit_button_size*0.25f, exit_button_size*0.25f, exit_button_size, exit_button_size)];
    [exitButton setImage:[UIImage imageNamed:@"exit"] forState:UIControlStateNormal];
    [exitButton addTarget:self action:@selector(dismissBounceGallery:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:exitButton];
}

-(void)dismissBounceGallery:(id)sender
{
    [self dismissViewControllerAnimated:sender completion:nil];
}

-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    _imgs = nil;
    
    if (detail) [detail dismissViewControllerAnimated:flag completion:nil];
    
    [super dismissViewControllerAnimated:flag completion:completion];
}

-(void)initAssets:(NSArray*)assetsbatch
{
    [self appendImgsWithGalleryImageRefsForAssetsBatch:assetsbatch];
    [self constructFramesStartingN:0 onBackgroundThread:FALSE];
}

-(void)addImagesFromAssetsInBatch:(NSArray*)batchpaths
{
    NSUInteger n = _imgs.count;
    
    [self appendImgsWithGalleryImageRefsForAssetsBatch:batchpaths];
    [self constructFramesStartingN:n onBackgroundThread:TRUE];
}

-(void)insertGalleryImageRefIntImgs:(ALAsset*)asset
{
    BounceGalleryImageRef *gi = [BounceGalleryImageRef newWithAsset:asset];
    [_imgs insertObject:gi atIndex:0];
}

-(void)appendImgsWithGalleryImageRefsForAssetsBatch:(NSArray*)assetsbatch
{
    for (ALAsset *asset in assetsbatch)
    {
        BounceGalleryImageRef *gi = [BounceGalleryImageRef newWithAsset:asset];
        [_imgs addObject:gi];
    }
}

-(void)constructFramesStartingN:(NSUInteger)num onBackgroundThread:(BOOL)bg
{
    __block NSUInteger n = num;
    
    void (^construct)(void) = ^void(void)
    {
        CGSize size = self.view.bounds.size;
        
        int N = (int)(_imgs.count - n);
        CGSize newSizes[N];
        
        float ideal_height = MAX(size.height, size.width) / _imgToScreenAspectRatio;
        float seq[N];
        float total_width = 0;
        
        for (int i = 0; i < N; i++)
        {
            BounceGalleryImageRef *gi = _imgs[i + n];
            
            @autoreleasepool
            {
                UIImage *image = [gi galleryThumb];
                newSizes[i] = CGSizeResizeToHeight(image.size, ideal_height);
            }

            seq[i] = newSizes[i].width;
            total_width += seq[i];
            gi = nil;
        }
        
        int K = (int)roundf(total_width / size.width);
        
        float M[N][K];
        float D[N][K];
        
        for (int i = 0 ; i < N; i++) {
            for (int j = 0; j < K; j++) {
                D[i][j] = 0;
            }
        }
        
        for (int i = 0; i < K; i++) {
            M[0][i] = seq[0];
        }
        
        for (int i = 0; i < N; i++) {
            M[i][0] = seq[i] + (i ? M[i-1][0] : 0);
        }
        
        float cost;
        for (int i = 1; i < N; i++) {
            for (int j = 1; j < K; j++) {
                M[i][j] = INT_MAX;
                
                for (int k = 0; k < i; k++) {
                    cost = MAX(M[k][j-1], M[i][0]-M[k][0]);
                    if (M[i][j] > cost)
                    {
                        M[i][j] = cost;
                        D[i][j] = k;
                    }
                }
            }
        }
        
        int k1 = K-1;
        int n1 = N-1;
        int ranges[N][2];
        while (k1 >= 0) {
            ranges[k1][0] = D[n1][k1]+1;
            ranges[k1][1] = n1;
            
            n1 = D[n1][k1];
            k1--;
        }
        ranges[0][0] = 0;
        
        BounceGalleryFlowLayout *layout = (BounceGalleryFlowLayout*) self.collectionViewLayout;
        
        float cellDistance = layout.minimumInteritemSpacing/2;
        float widthOffset = cellDistance;
        float frameWidth;
        for (int i = 0; i < K; i++)
        {
            float rowWidth = 0;
            frameWidth = size.width - (((ranges[i][1] - ranges[i][0]) * 2) * cellDistance);
            
            for (int j = ranges[i][0]; j <= ranges[i][1]; j++) {
                rowWidth += newSizes[j].width;
            }
            
            float ratio = frameWidth / rowWidth;
            widthOffset = 0;
            
            for (int j = ranges[i][0]; j <= ranges[i][1]; j++) {
                newSizes[j].width = floorf(ratio * newSizes[j].width);
                newSizes[j].height = floorf(ratio * newSizes[j].height);
                widthOffset += newSizes[j].width;
            }
        }
        
        for (int i = 0; i < N; i++)
        {
            BounceGalleryImageRef *gi = _imgs[i + n];
            [gi setSize:newSizes[i]];
        }
    };
    
    if (!bg)
    {
        construct();
        
        [self reloadGracefully];
    }
    else
    {
        dispatch_group_async(group, queue, ^
        {
            construct();
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self reloadGracefully];
            });
        });
    }
}

-(void)reloadGracefully
{
    [self.collectionView reloadData];
    
    [self.collectionView performBatchUpdates:^
     {
         [self.collectionView.collectionViewLayout invalidateLayout];
         [self.collectionView setCollectionViewLayout:self.collectionViewLayout animated:YES];
     }
                                  completion:nil];
}

-(void)setImgToScreenAspectRatio:(CGFloat)imgToScreenAspectRatio
{
    _imgToScreenAspectRatio = imgToScreenAspectRatio;
    [self constructFramesStartingN:0 onBackgroundThread:FALSE];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView { return 1; }
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section { return _imgs.count; }

- (BounceGalleryCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BounceGalleryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [cell prepareForReuse];
    
    BounceGalleryImageRef *gi = [self gimgForIndexPath:indexPath];
    
    if (gi) [cell setImgRef:gi];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self gimgForIndexPath:indexPath] size];
}

#pragma mark <UICollectionViewDelegateDataFlow>

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
}

-(BounceGalleryImageRef*)gimgForIndexPath:(NSIndexPath*)path
{
    return _imgs[[path indexAtPosition:[path length] - 1]];
}

// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    detail = [[BounceGalleryImageDetail alloc] initWithImageRef:[self gimgForIndexPath:indexPath]];
    
    [self presentViewController:detail animated:TRUE completion:nil];
}

- (BOOL)prefersStatusBarHidden { return TRUE; }

-(BOOL)shouldAutorotate { return FALSE; }

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
