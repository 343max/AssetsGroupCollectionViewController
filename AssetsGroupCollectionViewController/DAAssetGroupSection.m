//
//  DAAssetGroupSection.m
//  AssetsGroupCollectionViewController
//
//  Created by Max von Webel on 05/03/14.
//  Copyright (c) 2014 Max von Webel. All rights reserved.
//

#import "DAAssetGroupSection.h"

@interface DAAssetGroupSection ()

@property (strong, readonly) NSMutableIndexSet *indexSet;

@end


@implementation DAAssetGroupSection

- (id)initWithFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    self = [super init];
    
    if (self) {
        _fromDate = fromDate;
        _toDate = toDate;
        _indexSet = [[NSMutableIndexSet alloc] init];
    }
    
    return self;
}

- (void)addIndex:(NSUInteger)index
{
    [self.indexSet addIndex:index];
}

- (void)addIndexesInRange:(NSRange)range
{
    [self.indexSet addIndexesInRange:range];
}

- (NSIndexSet *)assetIndexSet
{
    return [self.indexSet copy];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ from: %@ to: %@, indexes: %@>", NSStringFromClass([self class]),
            self.fromDate, self.toDate, self.indexSet];
}

@end
