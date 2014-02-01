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
    
    if ([self isViewLoaded]) {
        [self.collectionView reloadData];
    }
}

- (NSUInteger)assetsPerCell
{
    return self.assetsPerRow * self.numberOfRowsPerCell;
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

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DAMultiAssetsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell"
                                                                            forIndexPath:indexPath];
    
    [cell setAssetsGroup:self.assetsGroup
         firstAssetIndex:indexPath.row * self.assetsPerCell
            assetsPerRow:self.assetsPerRow
                    rows:self.numberOfRowsPerCell
               assetSize:self.assetSize];
    
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
