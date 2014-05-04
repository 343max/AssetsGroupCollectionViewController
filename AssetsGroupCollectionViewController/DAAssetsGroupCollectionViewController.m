//
//  DAAssetsGroupCollectionViewController.m
//  AssetsGroupCollectionViewController
//
//  Created by Max Winde on 01.02.14.
//  Copyright (c) 2014 Max von Webel. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import "DAAssetGroupSection.h"
#import "DAAssetGroupSectionGroup.h"
#import "DAAssetGroupCollectionViewSectionHeader.h"
#import "DAMultiAssetsViewCell.h"
#import "DAAssetsGroupCollectionViewController.h"

@interface DAAssetsGroupCollectionViewController () <UICollectionViewDelegateFlowLayout>

@property (strong, readonly) NSCalendar *calendar;

@property (assign, readonly) NSUInteger assetsPerRow;
@property (assign, readonly) NSUInteger numberOfRowsPerCell;
@property (readonly, nonatomic) NSUInteger assetsPerCell;

@property (strong, readonly) NSMutableDictionary *imagePatches;
@property (strong, nonatomic) NSArray *sections;

@property (weak) UITapGestureRecognizer *tapGestureRecognizer;

@property (strong, nonatomic) NSOrderedSet *orderedAssets;

@end

@implementation DAAssetsGroupCollectionViewController

+ (UICollectionViewLayout *)layout;
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(320, 80);
    layout.minimumInteritemSpacing = 0.0;
    layout.minimumLineSpacing = 0.0;
    return layout;
}

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    
    if (self) {
        _calendar = [NSCalendar currentCalendar];
        _assetsPerRow = 32;
        _numberOfRowsPerCell = 8;
        _assetSize = CGSizeMake(10.0, 10.0);
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.collectionView registerClass:[DAMultiAssetsViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.collectionView registerClass:[DAAssetGroupCollectionViewSectionHeader class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:@"SectionHeader"];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self.collectionView addGestureRecognizer:tapGestureRecognizer];
    self.tapGestureRecognizer = tapGestureRecognizer;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.collectionView removeGestureRecognizer:self.tapGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    _imagePatches = [[NSMutableDictionary alloc] init];
}

- (void)setAssetsGroup:(ALAssetsGroup *)assetsGroup
{
    if (assetsGroup == _assetsGroup)
        return;
    
    _assetsGroup = assetsGroup;
    _imagePatches = [[NSMutableDictionary alloc] init];

    [self createOrderedAssetSet];
}

- (void)setSections:(NSArray *)sections
{
    if (_sections == sections)
        return;
    
    _sections = sections;
    
    _imagePatches = [[NSMutableDictionary alloc] init];
    
    if ([self isViewLoaded]) {
        [self.collectionView reloadData];
    }
}

- (void)createOrderedAssetSet
{
    NSMutableSet *assetSet = [[NSMutableSet alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self.assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                [assetSet addObject:result];
            } else {
                NSArray *sortedAssets = [[assetSet allObjects] sortedArrayUsingComparator:^NSComparisonResult(ALAsset *asset1, ALAsset *asset2) {
                    NSDate *date1 = [asset1 valueForProperty:ALAssetPropertyDate];
                    NSDate *date2 = [asset2 valueForProperty:ALAssetPropertyDate];
                    
                    return [date1 compare:date2];
                }];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.orderedAssets = [[NSOrderedSet alloc] initWithArray:sortedAssets];
                });
            }
        }];
    });
}

- (void)setOrderedAssets:(NSOrderedSet *)orderedAssets
{
    if ([_orderedAssets isEqual:orderedAssets])
        return;
    
    _orderedAssets = orderedAssets;
    
    [self calculateSections];
}

- (void)calculateSections
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        DAAssetGroupSectionGroup *sectionGroup = [[DAAssetGroupSectionGroup alloc] initWithEra:NSCalendarUnitYear
                                                                                      calendar:self.calendar
                                                                              dateFormatString:@"YYYY"];
        [self.orderedAssets enumerateObjectsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
            [sectionGroup addAsset:asset withIndex:index];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.sections = [sectionGroup orderedSections];
        });
    });
}

- (NSInteger)indexOfAssetAtPoint:(CGPoint)point
{
    NSInteger x = floorf(point.x / self.assetSize.width);
    NSInteger y = floorf(point.y / self.assetSize.height);
    NSInteger index = y * self.assetsPerRow + x;
    if (index >= self.assetsGroup.numberOfAssets || index < 0) {
        return NSNotFound;
    } else {
        return index;
    }
}

- (NSUInteger)assetsPerCell
{
    return self.assetsPerRow * self.numberOfRowsPerCell;
}

- (void)didTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    CGPoint location = [tapGestureRecognizer locationInView:self.collectionView];
    if ([self.delegate respondsToSelector:@selector(assetsGroupCollectionViewController:didTapAssetAtIndex:)]) {
        [self.delegate assetsGroupCollectionViewController:self didTapAssetAtIndex:[self indexOfAssetAtPoint:location]];
    }
}

- (void)drawAssets:(NSArray *)assets withIndexes:(NSIndexSet *)indexSet callback:(void(^)(UIImage *image, BOOL fromCache))callback
{
    NSMutableDictionary *imagePatches = self.imagePatches;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        CGSize size = CGSizeMake(self.assetSize.width * self.assetsPerRow,
                                 self.assetSize.height * ceilf((float)assets.count / (float)self.assetsPerRow));
        
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
        for (NSUInteger index = 0; index < assets.count; index++) {
            ALAsset *asset = assets[index];
            NSUInteger row = index / self.assetsPerRow;
            NSUInteger column = index % self.assetsPerRow;
            CGRect frame = CGRectMake(column * self.assetSize.width,
                                      row * self.assetSize.height,
                                      self.assetSize.width,
                                      self.assetSize.height);
            [[UIImage imageWithCGImage:asset.thumbnail] drawInRect:frame];
        }
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (imagePatches != self.imagePatches) {
                NSLog(@"throwing image patch for indexes %@ away because it became obsolete in the meantime", indexSet);
                return;
            }
            
            if (self.imagePatches[indexSet] != nil) {
                NSLog(@"\n\n\nwe have drawn imagePatch %@ twice. Room for optimization\n\n\n", indexSet);
            }
            NSAssert(self.imagePatches[indexSet] == nil, @"we have drawn an image patch twice. Room for optimizations");
            self.imagePatches[indexSet] = image;
            callback(image, NO);
        });
    });
}

- (void)loadAndDrawAssetsAtIndexes:(NSIndexSet *)indexSet callback:(void(^)(UIImage *image, BOOL fromCache))callback
{
    NSMutableDictionary *imagePatches = self.imagePatches;

    if (imagePatches[indexSet]) {
        callback(imagePatches[indexSet], YES);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSArray *assets = [self.orderedAssets objectsAtIndexes:indexSet];
        
        [self drawAssets:assets withIndexes:indexSet callback:callback];
    });
}

- (DAAssetGroupSection *)sectionGroupForSection:(NSInteger)section
{
    return self.sections[section];
}

#pragma mark UICollectionViewDelegate / UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return ceilf((float)[self sectionGroupForSection:section].assetIndexSet.count / (float)self.assetsPerCell);
}

- (NSIndexSet *)indexSetForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    DAAssetGroupSection *sectionGroup = [self sectionGroupForSection:section];
    NSIndexSet *sectionIndexSet = sectionGroup.assetIndexSet;
    
    NSUInteger loc = self.assetsPerCell * row + sectionIndexSet.firstIndex;
    NSUInteger length = MIN(self.assetsPerCell, sectionIndexSet.lastIndex - loc);
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(loc, length)];
    NSAssert(indexSet.lastIndex < self.orderedAssets.count, @"index set is to big for assetGroup");
    return indexSet;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DAMultiAssetsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell"
                                                                            forIndexPath:indexPath];
    
    [self loadAndDrawAssetsAtIndexes:[self indexSetForIndexPath:indexPath]
                            callback:^(UIImage *image, BOOL fromCache) {
                                if (!fromCache && ![[collectionView indexPathForCell:cell] isEqual:indexPath])
                                    return;
                                
                                cell.imageView.image = image;
                            }];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    DAAssetGroupSection *section = [self sectionGroupForSection:indexPath.section];
    
    if (section.title == nil) {
        return nil;
    }
    
    DAAssetGroupCollectionViewSectionHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                         withReuseIdentifier:@"SectionHeader"
                                                                                                forIndexPath:indexPath];
    header.label.text = section.title;
    return header;
}


#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexSet *indexSet = [self indexSetForIndexPath:indexPath];
    NSUInteger rows = ceilf((float)indexSet.count / (float)self.assetsPerRow);
    return CGSizeMake(self.assetsPerRow * self.assetSize.width, rows * self.assetSize.height);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section
{
    if ([self sectionGroupForSection:section].title) {
        return CGSizeMake(CGRectGetWidth(self.view.bounds), 30);
    } else {
        return CGSizeZero;
    }
}

@end
