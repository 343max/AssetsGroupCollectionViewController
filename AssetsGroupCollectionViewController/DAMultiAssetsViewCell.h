//
//  DAMultiAssetsViewCell.h
//  AssetsGroupCollectionViewController
//
//  Created by Max Winde on 01.02.14.
//  Copyright (c) 2014 Max von Webel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALAssetsGroup;

@interface DAMultiAssetsViewCell : UICollectionViewCell

- (void)setAssetsGroup:(ALAssetsGroup *)assetsGroup
       firstAssetIndex:(NSUInteger)firstAssetsIndex
          assetsPerRow:(NSUInteger)assetsPerRow
                  rows:(NSUInteger)rows;

@end
