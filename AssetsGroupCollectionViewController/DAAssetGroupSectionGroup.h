//
//  DAAssetGroupSectionGroup.h
//  AssetsGroupCollectionViewController
//
//  Created by Max von Webel on 06/03/14.
//  Copyright (c) 2014 Max von Webel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ALAsset;

@interface DAAssetGroupSectionGroup : NSObject

- (id)initWithEra:(NSCalendarUnit)eraUnit calendar:(NSCalendar*)calendar dateFormatString:(NSString *)dateFormatString;
- (id)initWithEra:(NSCalendarUnit)eraUnit calendar:(NSCalendar*)calendar dateFormatter:(NSDateFormatter *)dateFormatter;
- (void)addAsset:(ALAsset *)asset withIndex:(NSInteger)index;
- (NSArray *)orderedSections;

@property (assign, readonly) NSCalendarUnit eraUnit;
@property (strong, readonly) NSCalendar *calendar;

@end
