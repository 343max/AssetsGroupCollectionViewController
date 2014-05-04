//
//  DAAssetGroupSectionGroup.m
//  AssetsGroupCollectionViewController
//
//  Created by Max von Webel on 06/03/14.
//  Copyright (c) 2014 Max von Webel. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import "DAAssetGroupSection.h"
#import "DAAssetGroupSectionGroup.h"

@interface DAAssetGroupSectionGroup ()

@property (strong, readonly) NSMutableSet *sections;
@property (strong) DAAssetGroupSection *lastSection;
@property (strong) NSDateFormatter *dateFormatter;

@end


@implementation DAAssetGroupSectionGroup

- (id)initWithEra:(NSCalendarUnit)eraUnit calendar:(NSCalendar *)calendar dateFormatString:(NSString *)dateFormatString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = dateFormatString;
    return [self initWithEra:eraUnit calendar:calendar dateFormatter:dateFormatter];
}

- (id)initWithEra:(NSCalendarUnit)eraUnit calendar:(NSCalendar *)calendar dateFormatter:(NSDateFormatter *)dateFormatter
{
    self = [super init];
    
    if (self) {
        _eraUnit = eraUnit;
        _calendar = calendar;
        _dateFormatter = dateFormatter;
        _sections = [[NSMutableSet alloc] init];
    }
    
    return self;
}

- (BOOL)date:(NSDate *)date isInTheEraOfSection:(DAAssetGroupSection *)section;
{
    return [date compare:section.fromDate] != NSOrderedAscending && [date compare:section.toDate] != NSOrderedDescending;
}

- (DAAssetGroupSection *)sectionForEraOfDate:(NSDate *)date
{
    NSDate *fromDate;
    NSTimeInterval interval;
    BOOL success = [self.calendar rangeOfUnit:self.eraUnit
                                    startDate:&fromDate
                                     interval:&interval
                                      forDate:date];
    NSAssert(success, @"could not calculate the date");

    NSDate *toDate = [fromDate dateByAddingTimeInterval:interval];
    NSString *title = [self.dateFormatter stringFromDate:fromDate];
    
    return [[DAAssetGroupSection alloc] initWithFromDate:fromDate toDate:toDate title:title];
}

- (DAAssetGroupSection *)sectionForDate:(NSDate *)date create:(BOOL)create
{
    if (self.lastSection && [self date:date isInTheEraOfSection:self.lastSection]) {
        return self.lastSection;
    }

    for (DAAssetGroupSection *section in [self.sections allObjects]) {
        if ([self date:date isInTheEraOfSection:section]) {
            return section;
        }
    }
    
    if (create) {
        DAAssetGroupSection *section = [self sectionForEraOfDate:date];
        [self.sections addObject:section];
        return section;
    }
    
    return nil;
}

- (void)addAsset:(ALAsset *)asset withIndex:(NSInteger)index
{
    NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
    DAAssetGroupSection *matchingSection = [self sectionForDate:date create:YES];
    [matchingSection addIndex:index];
    self.lastSection = matchingSection;
}

- (NSArray *)orderedSections
{
    return [[self.sections allObjects] sortedArrayUsingComparator:^NSComparisonResult(DAAssetGroupSection *section1, DAAssetGroupSection *section2) {
        return [section1.fromDate compare:section2.fromDate];
    }];
}

@end
