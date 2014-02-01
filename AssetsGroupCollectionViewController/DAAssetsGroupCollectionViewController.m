//
//  DAAssetsGroupCollectionViewController.m
//  AssetsGroupCollectionViewController
//
//  Created by Max Winde on 01.02.14.
//  Copyright (c) 2014 Max von Webel. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import "DAMultiAssetsViewCell.h"
#import "DAAssetsGroupCollectionViewController.h"

@interface DAAssetsGroupCollectionViewController () <UICollectionViewDelegateFlowLayout>

@property (assign, readonly) NSUInteger assetsPerRow;
@property (assign, readonly) NSUInteger numberOfRowsPerCell;
@property (readonly, nonatomic) NSUInteger assetsPerCell;

@property (strong, readonly) NSMutableDictionary *imagePatches;

@end

@implementation DAAssetsGroupCollectionViewController

+ (UICollectionViewLayout *)layout;
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(320, 80);
    layout.minimumInteritemSpacing = 0.0;
    layout.minimumLineSpacing = 0.0;
    return layout;
}

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    
    if (self) {
        _assetsPerRow = 32;
        _numberOfRowsPerCell = 8;
        _assetSize = CGSizeMake(10.0, 10.0);
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.collectionView registerClass:[DAMultiAssetsViewCell class] forCellWithReuseIdentifier:@"Cell"];
}

- (void)setAssetsGroup:(ALAssetsGroup *)assetsGroup
{
    if (assetsGroup == _assetsGroup)
        return;
    
    _assetsGroup = assetsGroup;
    _imagePatches = [[NSMutableDictionary alloc] init];
    
    if ([self isViewLoaded]) {
        [self.collectionView reloadData];
    }
}

- (NSUInteger)assetsPerCell
{
    return self.assetsPerRow * self.numberOfRowsPerCell;
}

- (void)drawAssets:(NSArray *)assets withIndexes:(NSIndexSet *)indexSet callback:(void(^)(UIImage *image))callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        CGSize size = CGSizeMake(self.assetSize.width * self.assetsPerRow,
                                 self.assetSize.height * ceilf((float)assets.count / (float)self.assetsPerRow));
        
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
        CGContextRef contextRef = UIGraphicsGetCurrentContext();
        
        for (NSUInteger index = 0; index < assets.count; index++) {
            ALAsset *asset = assets[index];
            NSUInteger row = index / self.assetsPerRow;
            NSUInteger column = index % self.assetsPerRow;
            CGRect frame = CGRectMake(column * self.assetSize.width,
                                      row * self.assetSize.height,
                                      self.assetSize.width,
                                      self.assetSize.height);
            CGContextDrawImage(contextRef, frame, asset.thumbnail);
        }
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imagePatches[indexSet] = image;
            callback(image);
        });
    });
}

- (void)loadAndDrawAssetsAtIndexes:(NSIndexSet *)indexSet callback:(void(^)(UIImage *image))callback
{
    if (self.imagePatches[indexSet]) {
        callback(self.imagePatches[indexSet]);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray *assets = [[NSMutableArray alloc] init];

        [self.assetsGroup enumerateAssetsAtIndexes:indexSet
                                           options:0
                                        usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                            if (result == nil) {
                                                [self drawAssets:assets
                                                     withIndexes:indexSet
                                                        callback:callback];
                                                return;
                                            }
                                            
                                            [assets addObject:result];
                                        }];
    });
}

#pragma mark UICollectionViewDelegate / UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return ceilf((float)self.assetsGroup.numberOfAssets / (float)self.assetsPerCell);
}

- (NSIndexSet *)indexSetForIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger loc = self.assetsPerCell * indexPath.row;
    NSUInteger length = MIN(self.assetsPerRow * self.numberOfRowsPerCell, self.assetsGroup.numberOfAssets - loc);
    return [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(loc, length)];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DAMultiAssetsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell"
                                                                            forIndexPath:indexPath];
    
    [self loadAndDrawAssetsAtIndexes:[self indexSetForIndexPath:indexPath]
                            callback:^(UIImage *image) {
                                cell.imageView.image = image;
                            }];
    
    return cell;
}


#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger totalRows = ceilf((float)self.assetsGroup.numberOfAssets / (float)self.assetsPerRow);
    NSUInteger startRow = indexPath.row * self.numberOfRowsPerCell;
    NSUInteger rows = MIN(totalRows - startRow, self.numberOfRowsPerCell);
    return CGSizeMake(self.assetsPerRow * self.assetSize.width, rows * self.assetSize.height);
}

@end
