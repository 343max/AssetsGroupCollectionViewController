//
//  DAAssetGroupCollectionViewSectionHeader.m
//  AssetsGroupCollectionViewController
//
//  Created by Max von Webel on 06/03/14.
//  Copyright (c) 2014 Max von Webel. All rights reserved.
//

#import "DAAssetGroupCollectionViewSectionHeader.h"

@implementation DAAssetGroupCollectionViewSectionHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        [self addSubview:label];
        _label = label;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.bounds;
    frame = CGRectInset(frame, 10.0, 0.0);
    self.label.frame = frame;
}

@end
