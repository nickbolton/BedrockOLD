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
    }
    return self;
}

- (id)initWithNib {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.reloadDataOnViewLoad = YES;
    }
    return self;
}

- (id)initWithItems:(NSArray *)items {

    self = [super init];
    if (self) {
        self.providedDataSource = items;
    }
    return self;
}

- (id)init {
    return [self initWithItems:nil];
}

- (void)commonInit {
    self.reloadDataOnViewLoad = YES;
    [self createTableViewIfNecessary];
    [self reloadDataSource];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setup

- (void)setupNotifications {

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

    [self commonInit];

    [super viewDidLoad];

    if (self.backgroundColor != nil) {
        self.view.backgroundColor = self.backgroundColor;
    } else {
        self.view.backgroundColor = [UIColor clearColor];
    }

    [self setupNavigationBar];
    [self setupNotifications];
    [self setupTableView];

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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Getters and Setters

- (void)setDataSource:(NSArray *)dataSource {

    if ([dataSource.firstObject isKindOfClass:[PBSectionItem class]] == NO) {

        PBSectionItem *groupItem =
        [PBSectionItem
         sectionItemWithHeaderTitle:nil
         footerTitle:nil
         items:dataSource];

        _dataSource = @[groupItem];

    } else {

        _dataSource = dataSource;
    }

    NSMutableArray *selectedIndexes = [NSMutableArray array];

    NSInteger section = 0;

    for (PBSectionItem *sectionItem in self.dataSource) {

        NSAssert([sectionItem isKindOfClass:[PBSectionItem class]],
                 @"dataSource not a PBGroupItem class");

        NSInteger row = 0;

        for (PBListItem *item in sectionItem.items) {

            NSAssert([item isKindOfClass:[PBListItem class]],
                     @"section item not a PBListItem class");

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
                 @"item not a PBListItem");
    }

    return item;
}

- (void)reloadTableRow:(NSUInteger)row {
    [self reloadTableRow:row withAnimation:UITableViewRowAnimationAutomatic];
}

- (void)reloadTableRow:(NSUInteger)row
         withAnimation:(UITableViewRowAnimation)animation {

    [self.tableView
     reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]
     withRowAnimation:animation];
}

- (NSArray *)buildDataSource {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)reloadDataSource {

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

        } else if (item.cellID != nil) {

            [self.tableView
             registerClass:item.cellClass
             forCellReuseIdentifier:item.cellID];
        }

        if (item.itemType == PBItemTypeSelectAll) {

            self.selectAllItem = item;
            self.tableView.allowsMultipleSelection = YES;
        }
    }

    if (self.tableView.allowsMultipleSelection == NO && self.isMultiSelect) {
        self.tableView.allowsMultipleSelection = YES;
    }
}

- (void)reloadData {

    [self reloadDataSource];

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

    if (item.isSelected) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
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

#pragma mark - Keyboard Handling

- (void)keyboardWillShow:(NSNotification *)notification {

    self.swipeGesture =
    [[UISwipeGestureRecognizer alloc]
     initWithTarget:self action:@selector(dismissKeyboard:)];

    self.tableView.scrollEnabled = NO;
    self.swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self.tableView addGestureRecognizer:self.swipeGesture];
}

- (void)keyboardWillHide:(NSNotification *)notification {

    [self.tableView removeGestureRecognizer:self.swipeGesture];
    self.swipeGesture = nil;
    self.tableView.scrollEnabled = YES;
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

        case PBItemTypeSelectAll:
        case PBItemTypeChecked: {

            if (cellID == nil) {
                cellID = kPBListCellID;
            }

            cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            [self configureCheckedCell:(id)cell withItem:item];

        } break;

        default: {

            if (cellID == nil) {
                cellID = kPBListCellID;
            }

            cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            [self configureDefaultCell:(id)cell withItem:item];
            
        } break;
    }

    if ([cell isKindOfClass:[PBListViewDefaultCell class]]) {

        PBListViewDefaultCell *defaultCell = (id)cell;

        if (item.configureBlock != nil) {

            if (defaultCell.cellConfigured == NO) {
                item.configureBlock(self, item, cell);
                defaultCell.cellConfigured = YES;
            }
        }

        if (item.bindingBlock != nil) {
            item.bindingBlock(self, indexPath, item, cell);
        }

        defaultCell.item = item;
        defaultCell.viewController = self;
    }

    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate Conformance

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    PBListItem *item = [self itemAtIndexPath:indexPath];

    if (self.tableView.allowsMultipleSelection == NO) {

        if (item.itemType != PBItemTypeChecked && item.itemType != PBItemTypeSelectAll) {
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

    if (self.showRoundedGroups) {
        
        PBListItem *item = [self itemAtIndexPath:indexPath];

        if (item != nil && tableView.style == UITableViewStyleGrouped && [cell respondsToSelector:@selector(tintColor)]) {
            if (tableView == self.tableView) {
                CGFloat cornerRadius = 4.f;
                cell.backgroundColor = UIColor.clearColor;
                CAShapeLayer *layer = [[CAShapeLayer alloc] init];
                CGMutablePathRef pathRef = CGPathCreateMutable();
                CGRect bounds = CGRectInset(cell.bounds, 10, 0);
                BOOL addLine = NO;
                if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                    CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
                } else if (indexPath.row == 0) {
                    CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
                    CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
                    CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                    CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
                    addLine = YES;
                } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                    CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
                    CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
                    CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                    CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
                } else {
                    CGPathAddRect(pathRef, nil, bounds);
                    addLine = YES;
                }
                layer.path = pathRef;
                CFRelease(pathRef);
                layer.fillColor = item.backgroundColor.CGColor;

                if (addLine == YES) {
                    CALayer *lineLayer = [[CALayer alloc] init];
                    CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
                    lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+10, bounds.size.height-lineHeight, bounds.size.width-10, lineHeight);
                    lineLayer.backgroundColor = tableView.separatorColor.CGColor;
                    [layer addSublayer:lineLayer];
                }
                UIView *testView = [[UIView alloc] initWithFrame:bounds];
                [testView.layer insertSublayer:layer atIndex:0];
                testView.backgroundColor = UIColor.clearColor;
                cell.backgroundView = testView;
            }
        }
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

@end
