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

@interface DAAssetsGroupCollectionViewController ()

@property (assign, readonly) NSUInteger itemsPerRow;
@property (assign, readonly) NSUInteger numberOfRows;

@end

@implementation DAAssetsGroupCollectionViewController

+ (UICollectionViewLayout *)layout;
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(320, 320);
    return layout;
}

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    
    if (self) {
        _itemsPerRow = 4;
        _numberOfRows = 4;
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

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return ceilf(self.assetsGroup.numberOfAssets / (self.itemsPerRow * self.numberOfRows));
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DAMultiAssetsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell"
                                                                            forIndexPath:indexPath];
    cell.backgroundColor = [UIColor orangeColor];
    return cell;
}

@end
