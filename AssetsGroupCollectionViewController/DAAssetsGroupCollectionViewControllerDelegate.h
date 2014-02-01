//
//  DAAssetsGroupCollectionViewControllerDelegate.h
//  AssetsGroupCollectionViewController
//
//  Created by Max Winde on 01.02.14.
//  Copyright (c) 2014 Max von Webel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DAAssetsGroupCollectionViewController;

@protocol DAAssetsGroupCollectionViewControllerDelegate <NSObject>

@optional

- (void)assetsGroupCollectionViewController:(DAAssetsGroupCollectionViewController *)assetGroupCollectionViewcontroller
                         didTapAssetAtIndex:(NSUInteger)index;

@end
