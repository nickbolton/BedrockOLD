//
//  PBCollectionViewController.h
//  Bedrock
//
//  Created by Nick Bolton on 11/12/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kPBCollectionViewCellKind;
extern NSString * const kPBCollectionViewSupplimentaryKind;
extern NSString * const kPBCollectionViewDecorationKind;

@class PBCollectionItem;
@class PBCollectionLayout;

@interface PBCollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, readonly) NSArray *dataSource;
@property (nonatomic, strong) NSArray *providedDataSource;

@property (nonatomic) BOOL reloadDataOnViewLoad;
@property (nonatomic) BOOL hasCancelNavigationBarItem;
@property (nonatomic, weak) id doneTarget;
@property (nonatomic) SEL doneSelector;
@property (nonatomic) BOOL dismissOnDone;
@property (nonatomic, getter = isSectioned, readonly) BOOL sectioned;
@property (nonatomic, readonly) IBOutlet PBCollectionLayout *collectionLayout;

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *collectionBackgroundColor;

+ (Class)collectionViewLayoutClass;

- (id)initWithNib;
- (id)initWithItems:(NSArray *)items;

- (void)setupNotifications;
- (void)setupCollectionView;
- (NSArray *)buildDataSource;
- (void)reloadDataSource;
- (void)reloadData;
- (void)setupNavigationBar;
- (void)reloadCollectionItem:(PBCollectionItem *)item;
- (void)reloadCollectionItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
- (void)dismissKeyboard;
- (PBCollectionItem *)itemAtIndexPath:(NSIndexPath *)indexPath;

@end
