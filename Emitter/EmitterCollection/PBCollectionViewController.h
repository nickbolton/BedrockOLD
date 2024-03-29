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
@class PBSectionItem;
@class PBCollectionLayout;

@interface PBCollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, readonly) NSArray *dataSource;
@property (nonatomic, strong) NSArray *providedDataSource;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *collectionViewLeftSpace;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *collectionViewRightSpace;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *collectionViewTopSpace;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *collectionViewBottomSpace;

@property (nonatomic) BOOL reloadDataOnViewLoad;
@property (nonatomic) BOOL hasCancelNavigationBarItem;
@property (nonatomic, weak) id doneTarget;
@property (nonatomic) SEL doneSelector;
@property (nonatomic) BOOL dismissOnDone;
@property (nonatomic, getter = isMultiSelect) BOOL multiSelect;
@property (nonatomic, getter = isDragging, readonly) BOOL dragging;
@property (nonatomic) BOOL addSwipeDownToDismissKeyboard;
@property (nonatomic, readonly) IBOutlet PBCollectionLayout *collectionLayout;

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *collectionBackgroundColor;
@property (nonatomic, strong) NSArray *renderers;

- (Class)collectionViewLayoutClass;
- (Class)collectionViewClass;

- (id)initWithNib;
- (id)initWithItems:(NSArray *)items;

- (void)setupNotifications;
- (void)setupCollectionView;
- (NSArray *)buildDataSource;
- (void)reloadDataSource;
- (void)reloadData;
- (void)reloadDataOnBackgroundThread;
- (void)preRegisterCellNibsAndClasses;
- (void)setupNavigationBar;
- (void)reloadCollectionItem:(PBCollectionItem *)item;
- (void)reloadCollectionItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
- (void)dismissKeyboard;
- (PBSectionItem *)sectionItemAtSection:(NSInteger)section;
- (PBCollectionItem *)itemAtIndexPath:(NSIndexPath *)indexPath;
- (void)updateLayout:(PBCollectionLayout *)layout;
- (void)updateLayout:(PBCollectionLayout *)layout
            animated:(BOOL)animated
          completion:(void(^)(void))completionBlock;
- (void)updateItemStates;
- (void)collectionLayoutChanged;
- (void)insertSectionItem:(PBSectionItem *)sectionItem
            performUpdate:(BOOL)performUpdate
               completion:(void(^)(void))completionBlock;
- (void)insertSectionItem:(PBSectionItem *)sectionItem
                atSection:(NSInteger)section
            performUpdate:(BOOL)performUpdate
               completion:(void(^)(void))completionBlock;
- (void)replaceSectionItem:(PBSectionItem *)sectionItem
                 atSection:(NSInteger)section
             performUpdate:(BOOL)performUpdate
                completion:(void(^)(void))completionBlock;
- (void)removeSectionItem:(PBSectionItem *)item
            performUpdate:(BOOL)performUpdate
                        completion:(void(^)(BOOL removed))completionBlock;
- (void)removeSectionItemAtSection:(NSInteger)section
                     performUpdate:(BOOL)performUpdate
                        completion:(void(^)(void))completionBlock;

@end
