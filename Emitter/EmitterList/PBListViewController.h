//
//  PBListViewController.h
//  Bedrock
//
//  Created by Nick Bolton on 11/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBListViewControllerItem.h"

typedef NS_ENUM (NSInteger, PBListViewAutoSelectionType) {

    PBListViewAutoSelectionTypeNone = 0,
    PBListViewAutoSelectionTypeAnimated,
    PBListViewAutoSelectionTypeNonAnimated,
};

@class TCTimePeriodSelectorView;
@class PBSectionItem;
@class PBListItem;
@class PBActionDelegate;

extern NSString * const kPBListCellID;
extern NSString * const kPBListSpacerCellID;
extern NSString * const kPBListActionCellID;

@interface PBListViewController : UIViewController <PBListViewControllerItemProtocol, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *tableViewLeftSpace;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *tableViewRightSpace;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *tableViewTopSpace;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *tableViewBottomSpace;

@property (nonatomic, readonly) NSArray *dataSource;
@property (nonatomic, strong) PBActionDelegate *actionDelegate;
@property (nonatomic) BOOL initialized;
@property (nonatomic, getter = isModal) BOOL modal;
@property (nonatomic, readonly, getter = isDragging) BOOL dragging;
@property (nonatomic, assign) id doneTarget;
@property (nonatomic) SEL doneSelector;
@property (nonatomic) BOOL dismissOnDone;
@property (nonatomic) BOOL addSwipeDownToDismissKeyboard;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *valueColor;
@property (nonatomic, strong) UIColor *actionColor;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIFont *valueFont;
@property (nonatomic, strong) UIFont *actionFont;
@property (nonatomic, strong) UIColor *cellBackgroundColor;
@property (nonatomic, strong) UIColor *spacerCellBackgroundColor;
@property (nonatomic, strong) UIColor *tableBackgroundColor;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic) BOOL reloadDataOnViewLoad;
@property (nonatomic) BOOL hasCancelNavigationBarItem;
@property (nonatomic) PBListViewAutoSelectionType autoSelectionType;
@property (nonatomic, getter = isMultiSelect) BOOL multiSelect;
@property (nonatomic) Class headerViewClass;
@property (nonatomic) Class footerViewClass;
@property (nonatomic) CGFloat listViewItemHeight;
@property (nonatomic, strong) NSArray *renderers;
@property (nonatomic, weak) id firstResponder;

- (id)initWithItems:(NSArray *)items;
- (id)initWithItems:(NSArray *)items separatorColor:(UIColor *)separatorColor;
- (id)initWithNib;

- (void)selectItems:(NSArray *)items inSection:(NSInteger)section;

- (void)commonInit;
- (void)cleanUp;
- (void)setupNotifications;
- (void)setupTableView;
- (NSArray *)buildDataSource;
- (void)reloadDataSource;
- (void)reloadData;
- (void)updateItemStates;
- (void)preRegisterCellNibsAndClasses;
- (void)setupNavigationBar;
- (void)reloadTableRowAtIndexPath:(NSIndexPath *)indexPath
                    withAnimation:(UITableViewRowAnimation)animation;
- (void)reloadTableRowAtIndexPaths:(NSArray *)indexPathArray
                     withAnimation:(UITableViewRowAnimation)animation;
- (void)reloadTableRow:(NSUInteger)row;
- (void)reloadTableRow:(NSUInteger)row
         withAnimation:(UITableViewRowAnimation)animation;
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
- (void)dismissKeyboard;
- (IBAction)cancelPressed:(id)sender;
- (void)updateListViewItemHeight;
- (PBListItem *)itemAtIndexPath:(NSIndexPath *)indexPath;

- (void)insertSectionItem:(PBSectionItem *)sectionItem atSection:(NSInteger)section commitUpdates:(BOOL)commitUpdates;
- (void)replaceSectionItem:(PBSectionItem *)sectionItem atSection:(NSInteger)section commitUpdates:(BOOL)commitUpdates;
- (void)removeSectionItemAtSection:(NSInteger)section commitUpdates:(BOOL)commitUpdates;
- (void)insertSectionItem:(PBSectionItem *)sectionItem atSection:(NSInteger)section;
- (void)replaceSectionItem:(PBSectionItem *)sectionItem atSection:(NSInteger)section;
- (void)removeSectionItemAtSection:(NSInteger)section;
- (void)appendItemsToDataSource:(NSArray *)items;
- (void)appendItemsToDataSource:(NSArray *)items inSection:(NSInteger)section;
- (void)removeItemsAtIndexPaths:(NSArray *)indexPathArray;
- (BOOL)removeItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)insertItem:(PBListItem *)item atIndexPath:(NSIndexPath *)indexPath;
- (void)replaceItem:(PBListItem *)item atIndexPath:(NSIndexPath *)indexPath;

@end
