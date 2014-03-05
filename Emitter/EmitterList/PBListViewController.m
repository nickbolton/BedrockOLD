//
//  PBListViewController.m
//  Bedrock
//
//  Created by Nick Bolton on 11/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBListViewController.h"
#import "PBListItem.h"
#import "PBListCell.h"
#import "PBTitleCell.h"
#import "PBSectionItem.h"
#import "PBListItemRenderer.h"

NSString * const kPBListCellID = @"default-cell-id";
NSString * const kPBListSpacerCellID = @"spacer-cell-id";
NSString * const kPBListActionCellID = @"action-cell-id";
NSString * const kPBListTitleCellID = @"title-cell-id";

static NSInteger const kPBListSeparatorCellTag = 98;
static NSInteger const kPBListSeparatorTag = 99;
static NSInteger const kPBListActionTag = 101;
static NSInteger const kPBListCheckedTag = 103;
static NSInteger const kPBListDefaultTag = 105;

@interface PBListViewController () <UITableViewDataSource, UITableViewDelegate> {

    BOOL _setupNotificationsCalled;
    BOOL _setupNavigationBarCalled;
    BOOL _setupTableViewCalled;
    BOOL _reloadDataSourceCalled;
}

@property (nonatomic, readwrite) NSArray *dataSource;
@property (nonatomic, strong) NSArray *providedDataSource;
@property (nonatomic, strong) PBListItem *selectAllItem;
@property (nonatomic, strong) NSArray *selectedRowIndexes;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGesture;

@end

@implementation PBListViewController

- (id)initWithCoder:(NSCoder *)decoder {

    self = [super initWithCoder:decoder];
    if (self) {
        self.reloadDataOnViewLoad = YES;
        [self commonInit];
    }
    return self;
}

- (id)initWithNib {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.reloadDataOnViewLoad = YES;
        [self commonInit];
    }
    return self;
}

- (id)initWithItems:(NSArray *)items {

    self = [super init];
    if (self) {
        self.providedDataSource = items;
        self.reloadDataOnViewLoad = YES;
        [self commonInit];
    }
    return self;
}

- (id)init {
    return [self initWithItems:nil];
}

- (void)commonInit {
}

- (void)preLoadSetup {
    [self createTableViewIfNecessary];
    if (self.reloadDataOnViewLoad) {
        [self reloadDataSource];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setup

- (void)setupNotifications {

    _setupNotificationsCalled = YES;

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillHide:)
     name:UIKeyboardWillHideNotification
     object:nil];

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillShow:)
     name:UIKeyboardWillShowNotification
     object:nil];
}

- (void)setupNavigationBar {

    _setupNavigationBarCalled = YES;

    if (self.hasCancelNavigationBarItem) {

        UIBarButtonItem *cancelItem =
        [[UIBarButtonItem alloc]
         initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
         target:self
         action:@selector(cancelPressed:)];

        self.navigationItem.leftBarButtonItem = cancelItem;
    }

    if (self.isMultiSelect || self.tableView.allowsMultipleSelection) {

        if (self.doneTarget != nil &&
            self.doneSelector != nil) {

            UIBarButtonItem *doneItem =
            [[UIBarButtonItem alloc]
             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
             target:self.doneTarget
             action:self.doneSelector];

            self.navigationItem.rightBarButtonItem = doneItem;

        } else if (self.dismissOnDone) {

            UIBarButtonItem *doneItem =
            [[UIBarButtonItem alloc]
             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
             target:self
             action:@selector(cancelPressed:)];

            self.navigationItem.rightBarButtonItem = doneItem;
        }
    }
}

- (void)createTableViewIfNecessary {

    if (self.tableView == nil) {
        self.tableView = [[UITableView alloc] init];
        self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;

        [self.view addSubview:self.tableView];
        [NSLayoutConstraint expandToSuperview:self.tableView];
    }
}

- (void)setupTableView {

    _setupTableViewCalled = YES;

    UINib *nib =
    [UINib
     nibWithNibName:NSStringFromClass([PBListCell class])
     bundle:nil];

    UINib *titleNib =
    [UINib
     nibWithNibName:NSStringFromClass([PBTitleCell class])
     bundle:nil];

    [self.tableView
     registerNib:nib
     forCellReuseIdentifier:kPBListCellID];

    [self.tableView
     registerNib:titleNib
     forCellReuseIdentifier:kPBListTitleCellID];

    [self.tableView
     registerClass:[PBListViewDefaultCell class]
     forCellReuseIdentifier:kPBListSpacerCellID];

    [self.tableView
     registerClass:[PBListViewDefaultCell class]
     forCellReuseIdentifier:kPBListActionCellID];

    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {

    [self preLoadSetup];

    [super viewDidLoad];

    if (self.backgroundColor != nil) {
        self.view.backgroundColor = self.backgroundColor;
    } else {
        self.view.backgroundColor = [UIColor clearColor];
    }

    [self setupNavigationBar];
    [self setupNotifications];
    [self setupTableView];
    [self preRegisterCellNibsAndClasses];

    NSAssert(_setupNavigationBarCalled, @"You must call [super setupNavigationBar]");
    NSAssert(_setupNotificationsCalled, @"You must call [super setupNotifications]");
    NSAssert(_setupTableViewCalled, @"You must call [super setupTableView]");

    if (self.tableBackgroundColor != nil) {
        self.tableView.backgroundColor = self.tableBackgroundColor;
    } else {
        self.tableView.backgroundColor = [UIColor clearColor];
    }

    if (self.reloadDataOnViewLoad) {
        [self reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    self.tableView.editing = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.autoSelectionType == PBListViewAutoSelectionTypeNonAnimated && self.selectedRowIndexes.count > 0) {
        NSIndexPath *indexPath =
        self.selectedRowIndexes.firstObject;

        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];

            if ([visibleIndexPaths containsObject:indexPath] == NO) {

                [self.tableView
                 scrollToRowAtIndexPath:indexPath
                 atScrollPosition:UITableViewScrollPositionMiddle
                 animated:NO];
            }
        });
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.autoSelectionType == PBListViewAutoSelectionTypeAnimated && self.selectedRowIndexes.count > 0) {
        NSIndexPath *indexPath =
        self.selectedRowIndexes.firstObject;

        NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];

        if ([visibleIndexPaths containsObject:indexPath] == NO) {

            [self.tableView
             scrollToRowAtIndexPath:indexPath
             atScrollPosition:UITableViewScrollPositionMiddle
             animated:YES];
        }
    }
}

#pragma mark - Getters and Setters

- (void)setRenderers:(NSArray *)renderers {

    for (id renderer in renderers) {
        NSAssert([renderer conformsToProtocol:@protocol(PBListItemRenderer)],
                 @"renderer doesn't conform to PBListItemRenderer");
    }

    _renderers = renderers;
}

- (void)setDataSource:(NSArray *)dataSource {

    if ([dataSource.firstObject isKindOfClass:[PBSectionItem class]]) {

        _dataSource = dataSource;

    } else {

        PBSectionItem *sectionItem =
        [PBSectionItem
         sectionItemWithHeaderTitle:nil
         footerTitle:nil
         items:dataSource];

        _dataSource = @[sectionItem];
    }

    NSMutableArray *selectedIndexes = [NSMutableArray array];

    NSInteger section = 0;

    for (PBSectionItem *sectionItem in self.dataSource) {

        NSAssert([sectionItem isKindOfClass:[PBSectionItem class]],
                 @"dataSource not a PBSectionItem class (or subclass): %@",
                 NSStringFromClass([sectionItem class]));

        NSInteger row = 0;

        for (PBListItem *item in sectionItem.items) {

            NSAssert([item isKindOfClass:[PBListItem class]],
                     @"section item not a PBListItem class (or subclass): %@",
                     NSStringFromClass([item class]));

            if (item.isSelected) {

                NSIndexPath *indexPath =
                [NSIndexPath indexPathForRow:row inSection:section];

                [selectedIndexes addObject:indexPath];
            }

            row++;
        }

        section++;
    }

    self.selectedRowIndexes = selectedIndexes;
}

#pragma mark - Public

- (void)updateListViewItemHeight {

    // Setting listViewItemHeight triggers container view controllers to
    // update their height. The value is abitrary in our case because the
    // container view controller will use our data source to determine
    // our height.  If containing view controllers do not subclass from
    // PBListViewController, then they'll have to set an actual value.

    self.listViewItemHeight = self.listViewItemHeight;
}

- (void)insertSectionItem:(PBSectionItem *)sectionItem
                atSection:(NSInteger)section {
    [self insertSectionItem:sectionItem atSection:section commitUpdates:YES];
}

- (void)replaceSectionItem:(PBSectionItem *)sectionItem atSection:(NSInteger)section {
    [self replaceSectionItem:sectionItem atSection:section commitUpdates:YES];
}

- (void)removeSectionItemAtSection:(NSInteger)section {
    [self removeSectionItemAtSection:section commitUpdates:YES];
}

- (void)insertSectionItem:(PBSectionItem *)sectionItem
                atSection:(NSInteger)section
            commitUpdates:(BOOL)commitUpdates {

    NSAssert([sectionItem isKindOfClass:[PBSectionItem class]],
             @"dataSource not a PBSectionItem class (or subclass): %@",
             NSStringFromClass([sectionItem class]));

    if (commitUpdates) {
        [self.tableView beginUpdates];
    }

    NSMutableArray *dataSource = [self.dataSource mutableCopy];

    section = MIN(section, dataSource.count);
    [dataSource insertObject:sectionItem atIndex:section];
    self.dataSource = dataSource;

    [self.tableView
     insertSections:[NSIndexSet indexSetWithIndex:section]
     withRowAnimation:UITableViewRowAnimationAutomatic];

    if (commitUpdates) {
        [self.tableView endUpdates];
    }
}

- (void)replaceSectionItem:(PBSectionItem *)sectionItem
                 atSection:(NSInteger)section
             commitUpdates:(BOOL)commitUpdates {

    NSAssert([sectionItem isKindOfClass:[PBSectionItem class]],
             @"dataSource not a PBSectionItem class (or subclass): %@",
             NSStringFromClass([sectionItem class]));

    if (commitUpdates) {
        [self.tableView beginUpdates];
    }

    NSMutableArray *dataSource = [self.dataSource mutableCopy];

    section = MIN(section, dataSource.count);
    [dataSource replaceObjectAtIndex:section withObject:sectionItem];
    self.dataSource = dataSource;

    [self.tableView
     reloadSections:[NSIndexSet indexSetWithIndex:section]
     withRowAnimation:UITableViewRowAnimationAutomatic];

    if (commitUpdates) {
        [self.tableView endUpdates];
    }
}

- (void)removeSectionItemAtSection:(NSInteger)section
                     commitUpdates:(BOOL)commitUpdates {

    if (section < self.dataSource.count) {

        if (commitUpdates) {
            [self.tableView beginUpdates];
        }

        NSMutableArray *dataSource = [self.dataSource mutableCopy];
        [dataSource removeObjectAtIndex:section];
        self.dataSource = dataSource;

        [self.tableView
         deleteSections:[NSIndexSet indexSetWithIndex:section]
         withRowAnimation:UITableViewRowAnimationAutomatic];

        if (commitUpdates) {
            [self.tableView endUpdates];
        }

    } else {

        PBLog(@"WARN : tried to remove non-existent section %ld", (long)section);
    }
}

- (void)appendItemsToDataSource:(NSArray *)items {
    [self appendItemsToDataSource:items inSection:0];
}

- (void)appendItemsToDataSource:(NSArray *)addedItems inSection:(NSInteger)section {

    if (section >= self.dataSource.count) {
        return;
    }

    [self.tableView beginUpdates];
    [self doAppendItems:addedItems toSection:section];
    [self.tableView endUpdates];
}

- (void)doAppendItems:(NSArray *)addedItems toSection:(NSInteger)section {

    PBSectionItem *sectionItem = self.dataSource[section];

    NSInteger startIndex = sectionItem.items.count;

    NSMutableArray *sectionItems = [sectionItem.items mutableCopy];

    for (PBListItem *item in addedItems) {

        NSAssert([item isKindOfClass:[PBListItem class]],
                 @"list view item is not a PBListItem: %@",
                 NSStringFromClass([item class]));

        item.sectionItem = sectionItem;
        [sectionItems addObject:item];
    }

    sectionItem.items = sectionItems;

    if (self.providedDataSource.count > 0) {

        NSMutableArray *providedDataSource =
        [self.providedDataSource mutableCopy];

        [providedDataSource addObjectsFromArray:addedItems];
        self.providedDataSource = providedDataSource;
    }

    NSMutableArray *indexPaths = [NSMutableArray array];

    for (NSInteger index = startIndex; index < startIndex + addedItems.count; index++) {

        [indexPaths
         addObject:
         [NSIndexPath
          indexPathForRow:index
          inSection:section]];
    }

    [self.tableView
     insertRowsAtIndexPaths:indexPaths
     withRowAnimation:UITableViewRowAnimationBottom];
}

- (void)insertItem:(PBListItem *)item atIndexPath:(NSIndexPath *)indexPath {

    NSAssert([item isKindOfClass:[PBListItem class]],
             @"list view item is not a PBListItem: %@",
             NSStringFromClass([item class]));

    PBSectionItem *sectionItem = [self sectionItemAtSection:indexPath.section];

    if (sectionItem != nil) {

        NSInteger row = MIN(sectionItem.items.count, indexPath.row);

        item.sectionItem = sectionItem;

        NSMutableArray *sectionItems = [sectionItem.items mutableCopy];
        [sectionItems insertObject:item atIndex:row];
        sectionItem.items = sectionItems;


    }
}

- (BOOL)removeItemAtIndexPath:(NSIndexPath *)indexPath {

    PBSectionItem *sectionItem = [self sectionItemAtSection:indexPath.section];

    if (sectionItem != nil) {

        PBListItem *item = [self itemAtIndexPath:indexPath];

        if (item != nil) {

            item.sectionItem = nil;
            NSMutableArray *sectionItems = [sectionItem.items mutableCopy];
            [sectionItems removeObjectAtIndex:indexPath.row];
            sectionItem.items = sectionItems;

            return YES;
        }
    }

    return NO;
}

- (void)removeItemsAtIndexPaths:(NSArray *)indexPathArray {

    [self.tableView beginUpdates];

    NSMutableArray *removedIndexPaths = [NSMutableArray array];

    for (NSIndexPath *indexPath in indexPathArray) {

        if ([self removeItemAtIndexPath:indexPath]) {
            [removedIndexPaths addObject:indexPath];
        }
    }

    if (removedIndexPaths.count > 0) {

        [self.tableView
         deleteRowsAtIndexPaths:removedIndexPaths
         withRowAnimation:UITableViewRowAnimationFade];
    }

    [self.tableView endUpdates];
}

#pragma mark - Actions

- (IBAction)cancelPressed:(id)sender {

    if (self.navigationController != nil && self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark -

- (void)selectItems:(NSArray *)items inSection:(NSInteger)section {

    for (PBListItem *item in items) {

        PBSectionItem *sectionItem = [self sectionItemAtSection:section];

        NSInteger index =
        [sectionItem.items indexOfObject:item];

        NSIndexPath *indexPath =
        [NSIndexPath indexPathForRow:index inSection:section];

        [self.tableView
         selectRowAtIndexPath:indexPath
         animated:YES
         scrollPosition:UITableViewScrollPositionNone];

        index++;
    }
}

- (void)deselectItems:(NSArray *)items inSection:(NSInteger)section {

    for (PBListItem *item in items) {

        PBSectionItem *sectionItem = [self sectionItemAtSection:section];

        NSInteger index =
        [sectionItem.items indexOfObject:item];

        NSIndexPath *indexPath =
        [NSIndexPath indexPathForRow:index inSection:section];

        [self.tableView
         deselectRowAtIndexPath:indexPath
         animated:YES];

        index++;
    }
}

- (void)delselectOtherItems:(PBListItem *)targetItem inSection:(NSInteger)section {

    NSMutableArray *items = [NSMutableArray array];

    PBSectionItem *sectionItem = [self sectionItemAtSection:section];

    for (PBListItem *item in sectionItem.items) {

        if (item != targetItem) {
            [items addObject:item];
        }
    }

    [self deselectItems:items inSection:section];
}

- (PBSectionItem *)sectionItemAtSection:(NSInteger)section {
    if (section < self.dataSource.count) {
        return self.dataSource[section];
    }
    return nil;
}

- (BOOL)itemExistsAtIndexPath:(NSIndexPath *)indexPath {

    PBSectionItem *sectionItem = [self sectionItemAtSection:indexPath.section];
    PBListItem *item = [self itemAtRow:indexPath.row inSectionItem:sectionItem];

    return item != nil;
}

- (PBListItem *)itemAtIndexPath:(NSIndexPath *)indexPath {
    PBSectionItem *sectionItem = [self sectionItemAtSection:indexPath.section];
    return [self itemAtRow:indexPath.row inSectionItem:sectionItem];
}

- (PBListItem *)itemAtRow:(NSInteger)row
            inSectionItem:(PBSectionItem *)sectionItem {

    PBListItem *item = nil;

    if (row < sectionItem.items.count) {
        item = sectionItem.items[row];

        NSAssert([item isKindOfClass:[PBListItem class]],
                 @"item not a PBListItem: %@",
                 NSStringFromClass([item class]));
    }

    return item;
}

- (void)reloadTableRow:(NSUInteger)row {
    [self reloadTableRow:row withAnimation:UITableViewRowAnimationAutomatic];
}

- (void)reloadTableRow:(NSUInteger)row
         withAnimation:(UITableViewRowAnimation)animation {

    [self
     reloadTableRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]
     withAnimation:animation];
}

- (void)reloadTableRowAtIndexPath:(NSIndexPath *)indexPath
                    withAnimation:(UITableViewRowAnimation)animation {

    if ([self itemExistsAtIndexPath:indexPath]) {
        [self.tableView
         reloadRowsAtIndexPaths:@[indexPath]
         withRowAnimation:animation];
    }
}

- (void)reloadTableRowAtIndexPaths:(NSArray *)indexPathArray
                     withAnimation:(UITableViewRowAnimation)animation {
    [self.tableView
     reloadRowsAtIndexPaths:indexPathArray
     withRowAnimation:animation];
}

- (NSArray *)buildDataSource {
    return nil;
}

- (void)reloadDataSource {

    _reloadDataSourceCalled = YES;

    if (self.providedDataSource.count > 0) {
        self.dataSource = self.providedDataSource;
    } else {
        self.dataSource = [self buildDataSource];
    }

    for (PBSectionItem *sectionItem in self.dataSource) {
        [self reloadDataSourceSectionItem:sectionItem];
    }
}

- (void)reloadDataSourceSectionItem:(PBSectionItem *)sectionItem {

    for (PBListItem *item in sectionItem.items) {

        item.sectionItem = sectionItem;

        if (item.cellNib != nil) {

            [self.tableView
             registerNib:item.cellNib
             forCellReuseIdentifier:item.cellID];

            NSArray *views =
            [item.cellNib instantiateWithOwner:self options:nil];

            if (views.count > 0) {
                UIView *cell = views[0];

                item.rowHeight = CGRectGetHeight(cell.frame);
            }

        } else if (item.cellID != nil && item.cellClass != NULL) {

            [self.tableView
             registerClass:item.cellClass
             forCellReuseIdentifier:item.cellID];
        }

        if (item.checkedType == PBItemCheckedTypeAll) {

            self.selectAllItem = item;
            self.tableView.allowsMultipleSelection = YES;
        }
    }

    if (self.tableView.allowsMultipleSelection == NO && self.isMultiSelect) {
        self.tableView.allowsMultipleSelection = YES;
    }
}

- (void)reloadData {

    _reloadDataSourceCalled = NO;
    [self reloadDataSource];

    NSAssert(_reloadDataSourceCalled, @"You must call [super reloadDataSource]");

    for (PBSectionItem *sectionItem in self.dataSource) {
        [self clearSectionConfigured:sectionItem];
    }

    [self.tableView reloadData];

    [self setSelectionDisabled:YES forItemIndexes:self.selectedRowIndexes];

    for (NSIndexPath *indexPath in self.selectedRowIndexes) {

        [self.tableView
         selectRowAtIndexPath:indexPath
         animated:NO
         scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)setSelectionDisabled:(BOOL)selectionDisabled
              forItemIndexes:(NSArray *)itemIndexes {

    for (NSIndexPath *indexPath in itemIndexes) {

        PBListItem *item = [self itemAtIndexPath:indexPath];
        item.selectionDisabled = selectionDisabled;
    }
}

- (void)clearSectionConfigured:(PBSectionItem *)sectionItem {

    for (PBListItem *item in sectionItem.items) {
        item.itemConfigured = NO;
    }
}

- (void)configureSpacerCell:(UITableViewCell *)cell
                   withItem:(PBListItem *)item {

    if (cell.tag != kPBListSeparatorCellTag) {

        cell.tag = kPBListSeparatorCellTag;

        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    cell.separatorInset = item.separatorInsets;
}

- (void)configureActionCell:(UITableViewCell *)cell
                   withItem:(PBListItem *)item {

    if (cell.tag != kPBListActionTag) {

        cell.tag = kPBListActionTag;

        cell.textLabel.textColor =
        item.titleColor != nil ? item.titleColor : self.actionColor;

        cell.textLabel.font =
        item.titleFont != nil ? item.titleFont : self.actionFont;

        cell.backgroundColor =
        item.backgroundColor != nil ? item.backgroundColor : self.cellBackgroundColor;

        cell.selectionStyle = item.selectionStyle;

        cell.textLabel.textAlignment = item.titleAlignment;
    }

    cell.separatorInset = item.separatorInsets;
    cell.textLabel.text = item.title;
}

- (void)configureCheckedCell:(PBListCell *)cell
                    withItem:(PBListItem *)item {

    if (cell.tag != kPBListCheckedTag) {

        cell.tag = kPBListCheckedTag;

        if ([cell isKindOfClass:[PBListCell class]]) {
            cell.titleLabel.textColor =
            item.titleColor != nil ? item.titleColor : self.titleColor;

            cell.titleLabel.font =
            item.titleFont != nil ? item.titleFont : self.titleFont;

            cell.titleLabel.textAlignment = item.titleAlignment;
        }

        cell.backgroundColor =
        item.backgroundColor != nil ? item.backgroundColor : self.cellBackgroundColor;

        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    }

    if ([cell isKindOfClass:[PBListCell class]]) {
        cell.titleLabel.text = item.title;
        cell.valueLabel.text = nil;
    }
    cell.separatorInset = item.separatorInsets;
}

- (void)configureDefaultCell:(PBListCell *)cell
                    withItem:(PBListItem *)item {

    if (cell.tag != kPBListDefaultTag) {

        cell.tag = kPBListDefaultTag;

        if ([cell isKindOfClass:[PBListCell class]]) {

            cell.titleLabel.textColor =
            item.titleColor != nil ? item.titleColor : self.titleColor;

            cell.valueLabel.textColor =
            item.valueColor != nil ? item.valueColor : self.valueColor;

            cell.titleLabel.font =
            item.titleFont != nil ? item.titleFont : self.titleFont;

            cell.valueLabel.font =
            item.valueFont != nil ? item.valueFont : self.valueFont;

            cell.titleLabel.textAlignment = item.titleAlignment;

            if (item.hasDisclosure == NO) {

                CGRect frame = cell.valueLabel.frame;
                frame.origin.x -= item.valueMargin;
                cell.valueLabel.frame = frame;
            }
        }

        cell.backgroundColor =
        item.backgroundColor != nil ? item.backgroundColor : self.cellBackgroundColor;

        cell.selectionStyle = item.selectionStyle;

        if (item.hasDisclosure) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }

    cell.separatorInset = item.separatorInsets;

    if ([cell isKindOfClass:[PBListCell class]]) {
        cell.titleLabel.text = item.title;
        cell.valueLabel.text = item.value;
    }
}

- (void)preRegisterCellNibsAndClasses {
}

#pragma mark - Keyboard Handling

- (void)keyboardWillShow:(NSNotification *)notification {

    if (self.addSwipeDownToDismissKeyboard) {

        self.swipeGesture =
        [[UISwipeGestureRecognizer alloc]
         initWithTarget:self action:@selector(dismissKeyboard:)];

        self.tableView.scrollEnabled = NO;
        self.swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
        [self.tableView addGestureRecognizer:self.swipeGesture];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {

    if (self.addSwipeDownToDismissKeyboard) {
        
        [self.tableView removeGestureRecognizer:self.swipeGesture];
        self.swipeGesture = nil;
        self.tableView.scrollEnabled = YES;
    }
}

- (void)dismissKeyboard:(UISwipeGestureRecognizer *)gesture {

    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self dismissKeyboard];
    }
}

- (void)dismissKeyboard {
}

#pragma mark -
#pragma mark UITableViewDataSource Conformance

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    PBListItem *item = [self itemAtIndexPath:indexPath];
    return item.isDeletable;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    PBSectionItem *sectionItem = [self sectionItemAtSection:section];
    return sectionItem.items.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    PBListItem *item = [self itemAtIndexPath:indexPath];
    item.indexPath = indexPath;

    UITableViewCell *cell;
    NSString *cellID = item.cellID;

    switch (item.itemType) {

        case PBItemTypeAction: {

            if (cellID == nil) {
                cellID = kPBListActionCellID;
            }

            cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            [self configureActionCell:cell withItem:item];

        } break;

        case PBItemTypeSpacer: {

            cell = [tableView dequeueReusableCellWithIdentifier:kPBListSpacerCellID];
            [self configureActionCell:cell withItem:item];

        } break;

        case PBItemTypeCustom: {

            cell = [tableView dequeueReusableCellWithIdentifier:item.cellID];

            if (item.itemConfigured == NO) {

                cell.selectionStyle = item.selectionStyle;
                cell.separatorInset = item.separatorInsets;

                item.itemConfigured = YES;
            }

        } break;

        case PBItemTypeTitle: {

            if (cellID == nil) {
                cellID = kPBListTitleCellID;
            }

            cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            [self configureDefaultCell:(id)cell withItem:item];

        } break;

        default: {

            if (cellID == nil) {
                cellID = kPBListCellID;
            }

            cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            [self configureDefaultCell:(id)cell withItem:item];
            
        } break;
    }

    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate Conformance

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    PBListItem *item = [self itemAtIndexPath:indexPath];

    if (item.itemType == PBItemTypeSpacer) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }

    if (self.tableView.allowsMultipleSelection == NO) {

        if (item.checkedType == PBItemCheckedTypeNone) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }

    if (item == self.selectAllItem) {

        [self
         delselectOtherItems:self.selectAllItem
         inSection:indexPath.section];

    } else if (self.selectAllItem != nil) {

        NSInteger selectionCount = 0;

        PBSectionItem *sectionItem =
        [self sectionItemAtSection:indexPath.section];

        for (PBListItem *item in sectionItem.items) {

            if (item.isSelected) {
                selectionCount++;
            }
        }

        if (selectionCount == 0) {
            [self selectItems:@[self.selectAllItem] inSection:indexPath.section];
        } else {
            [self deselectItems:@[self.selectAllItem] inSection:indexPath.section];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (self.selectAllItem != nil) {

        NSInteger selectionCount = 0;

        PBSectionItem *sectionItem =
        [self sectionItemAtSection:indexPath.section];

        for (PBListItem *item in sectionItem.items) {

            if (item.isSelected) {
                selectionCount++;
            }
        }

        if (selectionCount == 0) {
            [self selectItems:@[self.selectAllItem] inSection:indexPath.section];
        } else {
            [self deselectItems:@[self.selectAllItem] inSection:indexPath.section];
        }
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    PBListItem *item = [self itemAtIndexPath:indexPath];

    if (item != nil) {

        if (item.isSelected) {

            if (item.isDeselectable == NO) {
                return nil;
            }

            if (tableView.allowsMultipleSelection == NO) {

                PBListViewDefaultCell *cell =
                (id)[tableView cellForRowAtIndexPath:indexPath];

                if ([cell isKindOfClass:[PBListViewDefaultCell class]]) {
                    [cell updateForSelectedState];
                    return nil;
                }
            }
        }
    }

    return indexPath;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {

    PBListItem *item = [self itemAtIndexPath:indexPath];

    if (item != nil &&
        item.isSelected &&
        item.isDeselectable == NO) {
        return nil;
    }

    return indexPath;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {

        PBListItem *item = [self itemAtIndexPath:indexPath];
        item.deleteActionBlock(self);
        [tableView setEditing:NO animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    PBListItem *item = [self itemAtIndexPath:indexPath];

    if (item.rowHeightBasedOnTitleSize) {

        NSDictionary *attributes =
        @{
          NSFontAttributeName : item.titleFont,
          NSParagraphStyleAttributeName : item.titleParagraphStyle,
          };

        CGSize size = CGSizeMake(CGRectGetWidth(self.tableView.frame), MAXFLOAT);

        CGRect boundingRect =
        [item.title
         boundingRectWithSize:size
         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
         attributes:attributes
         context:nil];

        return boundingRect.size.height + item.heightPadding;
    }

    return item.rowHeight + item.heightPadding;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PBListItem *item = [self itemAtIndexPath:indexPath];

    if ([cell isKindOfClass:[PBListViewDefaultCell class]]) {

        PBListViewDefaultCell *defaultCell = (id)cell;

        if (item.configureBlock != nil) {

            if (defaultCell.cellConfigured == NO) {
                item.configureBlock(self, item, cell);
                defaultCell.cellConfigured = YES;
            }
        }

        defaultCell.item = item;
        defaultCell.viewController = self;

        if (item.bindingBlock != nil) {
            item.bindingBlock(self, indexPath, item, cell);
        }

        [defaultCell willDisplayCell];
    }

    for (id <PBListItemRenderer> renderer in self.renderers) {
        [renderer
         renderItem:item
         atIndexPath:indexPath
         inCell:cell
         withListView:self];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([cell isKindOfClass:[PBListViewDefaultCell class]]) {

        PBListViewDefaultCell *defaultCell = (id)cell;
        [defaultCell didEndDisplayingCell];
    }
}

#pragma mark - Headers and Footers

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    PBSectionItem *sectionItem = [self sectionItemAtSection:section];
    return sectionItem.headerTitle;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    PBSectionItem *sectionItem = [self sectionItemAtSection:section];
    return sectionItem.footerTitle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    PBSectionItem *sectionItem = [self sectionItemAtSection:section];
    return sectionItem.headerHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    PBSectionItem *sectionItem = [self sectionItemAtSection:section];
    return sectionItem.footerHeight;
}

@end
