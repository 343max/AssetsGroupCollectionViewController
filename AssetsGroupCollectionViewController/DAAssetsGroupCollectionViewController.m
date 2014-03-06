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
        _numberOfRowsPerCell = 16;
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
    
    DAAssetGroupSection *allAssetsSection = [[DAAssetGroupSection alloc] init];
    [allAssetsSection addIndexesInRange:NSMakeRange(0, assetsGroup.numberOfAssets)];
    
    self.sections = @[ allAssetsSection ];
    
    [self calculateSections];
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

- (void)calculateSections
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        DAAssetGroupSectionGroup *sectionGroup = [[DAAssetGroupSectionGroup alloc] initWithEra:NSCalendarUnitYear
                                                                                      calendar:self.calendar
                                                                              dateFormatString:@"YYYY"];
        
        [self.assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                [sectionGroup addAsset:result withIndex:index];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.sections = [sectionGroup orderedSections];
                });
            }
        }];
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

- (void)drawAssets:(NSArray *)assets withIndexes:(NSIndexSet *)indexSet callback:(void(^)(UIImage *image))callback
{
    NSDictionary *imagePatches = self.imagePatches;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        CGSize size = CGSizeMake(self.assetSize.width * self.assetsPerRow,
                                 self.assetSize.height * ceilf((float)assets.count / (float)self.assetsPerRow));
        
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
        CGContextRef contextRef = UIGraphicsGetCurrentContext();
        
        for (NSUInteger index = 0; index < assets.count; index++) {
            ALAsset *asset = assets[index];
            NSUInteger row = index / self.assetsPerRow;
            NSUInteger column = index % self.assetsPerRow;
            CGRect frame = CGRectMake(column * self.assetSize.width,
                                      row * self.assetSize.height,
                                      self.assetSize.width,
                                      self.assetSize.height);
            CGContextDrawImage(contextRef, frame, asset.thumbnail);
        }
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (imagePatches != self.imagePatches) {
                NSLog(@"throwing image patch away because it became obsolete in the meantime");
                return;
            }
            
            NSAssert(self.imagePatches[indexSet] == nil, @"we have drawn an image patch twice. Room for optimizations");
            self.imagePatches[indexSet] = image;
            callback(image);
        });
    });
}

- (void)loadAndDrawAssetsAtIndexes:(NSIndexSet *)indexSet callback:(void(^)(UIImage *image))callback
{
    if (self.imagePatches[indexSet]) {
        callback(self.imagePatches[indexSet]);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray *assets = [[NSMutableArray alloc] init];

        [self.assetsGroup enumerateAssetsAtIndexes:indexSet
                                           options:0
                                        usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                            if (result == nil) {
                                                [self drawAssets:assets
                                                     withIndexes:indexSet
                                                        callback:callback];
                                                return;
                                            }
                                            
                                            [assets addObject:result];
                                        }];
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
    DAAssetGroupSection *section = [self sectionGroupForSection:indexPath.section];
    NSIndexSet *sectionIndexSet = section.assetIndexSet;
    
    NSUInteger loc = self.assetsPerCell * indexPath.row + sectionIndexSet.firstIndex;
    NSUInteger length = MIN(self.assetsPerCell, sectionIndexSet.lastIndex - loc);
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(loc, length)];
    NSAssert(indexSet.lastIndex < self.assetsGroup.numberOfAssets, @"index set is to big for assetGroup");
    return indexSet;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DAMultiAssetsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell"
                                                                            forIndexPath:indexPath];
    
    [self loadAndDrawAssetsAtIndexes:[self indexSetForIndexPath:indexPath]
                            callback:^(UIImage *image) {
                                cell.imageView.image = image;
                            }];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    DAAssetGroupCollectionViewSectionHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                         withReuseIdentifier:@"SectionHeader"
                                                                                                forIndexPath:indexPath];
    DAAssetGroupSection *section = [self sectionGroupForSection:indexPath.section];
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
    return CGSizeMake(CGRectGetWidth(self.view.bounds), 30);
}

@end
