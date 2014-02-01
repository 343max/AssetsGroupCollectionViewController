//
//  DAAssetsGroupCollectionViewController.h
//  AssetsGroupCollectionViewController
//
//  Created by Max Winde on 01.02.14.
//  Copyright (c) 2014 Max von Webel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALAssetsGroup;

@interface DAAssetsGroupCollectionViewController : UICollectionViewController

+ (UICollectionViewLayout *)layout;

@property (strong, nonatomic) ALAssetsGroup *assetsGroup;
@property (assign, nonatomic) CGSize assetSize;

@end
