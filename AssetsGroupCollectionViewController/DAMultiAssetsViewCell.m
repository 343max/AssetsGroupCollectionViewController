//
//  DAMultiAssetsViewCell.m
//  AssetsGroupCollectionViewController
//
//  Created by Max Winde on 01.02.14.
//  Copyright (c) 2014 Max von Webel. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import "DAMultiAssetsViewCell.h"

@interface DAMultiAssetsViewCell ()

@property (assign, readonly) NSUInteger assetsPerRow;
@property (assign, readonly) NSUInteger rows;

@end

@implementation DAMultiAssetsViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setAssetsGroup:(ALAssetsGroup *)assetsGroup
       firstAssetIndex:(NSUInteger)firstAssetsIndex
          assetsPerRow:(NSUInteger)assetsPerRow
                  rows:(NSUInteger)rows
{
    _assetsPerRow = assetsPerRow;
    _rows = rows;
    
    NSInteger length = MIN(assetsPerRow * rows, assetsGroup.numberOfAssets - firstAssetsIndex);
    
    [assetsGroup enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(firstAssetsIndex, length)]
                                  options:0
                               usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                   NSLog(@"index: %lu", (unsigned long)index);
                               }];
}

@end
