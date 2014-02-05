//
//  PBListViewController.h
//  Bedrock
//
//  Created by Nick Bolton on 11/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBListViewControllerItem.h"

@class TCTimePeriodSelectorView;
@class PBListItem;
@class PBActionDelegate;

extern NSString * const kPBListCellID;
extern NSString * const kPBListSpacerCellID;
extern NSString * const kPBListActionCellID;

@interface PBListViewController : UIViewController <PBListViewControllerItemProtocol>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, readonly) NSArray *dataSource;
@property (nonatomic, strong) PBActionDelegate *actionDelegate;
@property (nonatomic) BOOL initialized;
@property (nonatomic, getter = isModal) BOOL modal;
@property (nonatomic, assign) id doneTarget;
@property (nonatomic) SEL doneSelector;
@property (nonatomic) BOOL dismissOnDone;
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
@property (nonatomic, getter = isMultiSelect) BOOL multiSelect;
@property (nonatomic) BOOL showRoundedGroups;
@property (nonatomic) Class headerViewClass;
@property (nonatomic) Class footerViewClass;
@property (nonatomic) CGFloat listViewItemHeight;

- (id)initWithItems:(NSArray *)items;
- (id)initWithNib;

- (void)selectItems:(NSArray *)items inSection:(NSInteger)section;

- (void)commonInit;
- (void)setupNotifications;
- (void)setupTableView;
- (NSArray *)buildDataSource;
- (void)reloadDataSource;
- (void)reloadData;
- (void)setupNavigationBar;
- (void)reloadTableRowAtIndexPath:(NSIndexPath *)indexPath
                    withAnimation:(UITableViewRowAnimation)animation;
- (void)reloadTableRow:(NSUInteger)row;
- (void)reloadTableRow:(NSUInteger)row
         withAnimation:(UITableViewRowAnimation)animation;
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
- (void)dismissKeyboard;
- (IBAction)cancelPressed:(id)sender;
- (void)updateListViewItemHeight;

@end
