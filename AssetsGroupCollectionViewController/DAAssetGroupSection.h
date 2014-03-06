//
//  DAAssetGroupSection.h
//  AssetsGroupCollectionViewController
//
//  Created by Max von Webel on 05/03/14.
//  Copyright (c) 2014 Max von Webel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DAAssetGroupSection : NSObject

- (id)initWithFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate title:(NSString *)title;

@property (strong, readonly) NSString *title;
@property (strong, readonly) NSDate *fromDate;
@property (strong, readonly) NSDate *toDate;

- (NSIndexSet *)assetIndexSet;

- (void)addIndex:(NSUInteger)index;
- (void)addIndexesInRange:(NSRange)range;

@end
