//
//  DAAssetsGroupCollectionViewController.h
//  AssetsGroupCollectionViewController
//
//  Created by Max Winde on 01.02.14.
//  Copyright (c) 2014 Max von Webel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DAAssetsGroupCollectionViewControllerDelegate.h"

@class ALAssetsGroup;

@interface DAAssetsGroupCollectionViewController : UICollectionViewController

+ (UICollectionViewLayout *)layout;

@property (strong, nonatomic) ALAssetsGroup *assetsGroup;
@property (assign, nonatomic) CGSize assetSize;

@property (assign) id<DAAssetsGroupCollectionViewControllerDelegate> delegate;

- (NSInteger)indexOfAssetAtPoint:(CGPoint)point;

@end
