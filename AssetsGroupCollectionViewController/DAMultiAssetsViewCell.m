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

@property (weak, readonly) UIImageView *imageView;

@end

@implementation DAMultiAssetsViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:imageView];
        _imageView = imageView;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.imageView.image = nil;
    self.imageView.backgroundColor = [UIColor greenColor];
}

- (void)drawAssets:(NSArray *)assets
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
        CGContextRef contextRef = UIGraphicsGetCurrentContext();
        
        CGSize thumbSize = CGSizeMake(CGRectGetWidth(self.bounds) / self.assetsPerRow,
                                      CGRectGetHeight(self.bounds) / self.rows);

        for (NSUInteger index = 0; index < assets.count; index++) {
            ALAsset *asset = assets[index];
            NSUInteger row = index / self.assetsPerRow;
            NSUInteger column = index % self.assetsPerRow;
            CGRect frame = CGRectMake(column * thumbSize.width, row * thumbSize.height, thumbSize.width, thumbSize.height);
            CGContextDrawImage(contextRef, frame, asset.thumbnail);
        }
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = image;
        });
    });
}

- (void)setAssetsGroup:(ALAssetsGroup *)assetsGroup
       firstAssetIndex:(NSUInteger)firstAssetsIndex
          assetsPerRow:(NSUInteger)assetsPerRow
                  rows:(NSUInteger)rows
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        _assetsPerRow = assetsPerRow;
        _rows = rows;
        
        NSInteger length = MIN(assetsPerRow * rows, assetsGroup.numberOfAssets - firstAssetsIndex);
        
        NSMutableArray *assets = [[NSMutableArray alloc] init];
        
        [assetsGroup enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(firstAssetsIndex, length)]
                                      options:0
                                   usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                       if (result == nil) {
                                           [self drawAssets:assets];
                                           return;
                                       }
                                       
                                       [assets addObject:result];
                                   }];
    });
}

@end
