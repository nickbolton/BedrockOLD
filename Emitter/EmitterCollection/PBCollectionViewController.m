//
//  PBCollectionViewController.m
//  Bedrock
//
//  Created by Nick Bolton on 11/12/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBCollectionViewController.h"
#import "PBCollectionLayout.h"
#import "PBCollectionItem.h"
#import "PBSectionItem.h"
#import "PBCollectionDefaultCell.h"
#import "PBCollectionItemRenderer.h"

NSString * const kPBCollectionViewCellKind = @"kPBCollectionViewCellKind";
NSString * const kPBCollectionViewSupplimentaryKind = @"kPBCollectionViewSupplimentaryKind";
NSString * const kPBCollectionViewDecorationKind = @"kPBCollectionViewDecorationKind";

@interface PBCollectionViewController () {

    BOOL _setupNotificationsCalled;
    BOOL _setupNavigationBarCalled;
    BOOL _setupCollectionViewCalled;
    BOOL _reloadDataSourceCalled;
}

@property (nonatomic, readwrite) IBOutlet PBCollectionLayout *collectionLayout;
@property (nonatomic, readwrite) NSArray *dataSource;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGesture;
@property (nonatomic, strong) NSMutableArray *selectedItemIndexes;
@property (nonatomic, strong) PBCollectionItem *selectAllItem;
@property (nonatomic, getter = isDragging, readwrite) BOOL dragging;

@end

@implementation PBCollectionViewController

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
        self.reloadDataOnViewLoad = YES;
    }
    return self;
}

- (id)init {
    return [self initWithItems:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (Class)collectionViewLayoutClass {
    return [PBCollectionLayout class];
}

- (Class)collectionViewClass {
    return [UICollectionView class];
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

    if (self.collectionView.allowsMultipleSelection) {

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

- (void)createCollectionViewIfNecessary {

    if (self.collectionView == nil) {
        self.collectionView =
        [[[self collectionViewClass] alloc]
         initWithFrame:CGRectZero
         collectionViewLayout:self.collectionLayout];
        self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;

        [self.view addSubview:self.collectionView];
        
        self.collectionViewTopSpace =
        [NSLayoutConstraint alignToTop:self.collectionView withPadding:0.0f];
        
        self.collectionViewBottomSpace =
        [NSLayoutConstraint alignToBottom:self.collectionView withPadding:0.0f];
        
        self.collectionViewLeftSpace =
        [NSLayoutConstraint alignToLeft:self.collectionView withPadding:0.0f];
        
        self.collectionViewRightSpace =
        [NSLayoutConstraint alignToRight:self.collectionView withPadding:0.0f];
    }
}

- (void)setupCollectionView {

    _setupCollectionViewCalled = YES;

    self.collectionView.collectionViewLayout = self.collectionLayout;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionLayout.viewController = self;

    if (self.collectionBackgroundColor != nil) {
        self.collectionView.backgroundColor = self.collectionBackgroundColor;
    } else {
        self.collectionView.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.backgroundColor != nil) {
        self.view.backgroundColor = self.backgroundColor;
    } else {
        self.view.backgroundColor = [UIColor clearColor];
    }

    PBCollectionLayout *layout =
    [[[self collectionViewLayoutClass] alloc] init];

    NSAssert([layout isKindOfClass:[PBCollectionLayout class]],
             @"collection view layout must subclass PBCollectionLayout");

    self.collectionLayout = layout;
    [self createCollectionViewIfNecessary];
    [self setupNavigationBar];
    [self setupNotifications];
    [self setupCollectionView];
    [self preRegisterCellNibsAndClasses];

    NSAssert(_setupNavigationBarCalled, @"You must call [super setupNavigationBar]");
    NSAssert(_setupNotificationsCalled, @"You must call [super setupNotifications]");
    NSAssert(_setupCollectionViewCalled, @"You must call [super setupCollectionView]");

    if (self.reloadDataOnViewLoad) {
        [self reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (void)cancelPressed:(id)sender {

    if (self.navigationController != nil && self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Keyboard Handling

- (void)keyboardWillShow:(NSNotification *)notification {

    if (self.addSwipeDownToDismissKeyboard) {

        self.swipeGesture =
        [[UISwipeGestureRecognizer alloc]
         initWithTarget:self action:@selector(dismissKeyboard:)];

        self.collectionView.scrollEnabled = NO;
        self.swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
        [self.collectionView addGestureRecognizer:self.swipeGesture];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {

    if (self.addSwipeDownToDismissKeyboard) {
        
        [self.collectionView removeGestureRecognizer:self.swipeGesture];
        self.swipeGesture = nil;
        self.collectionView.scrollEnabled = YES;
    }
}

- (void)dismissKeyboard:(UISwipeGestureRecognizer *)gesture {

    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self dismissKeyboard];
    }
}

- (void)dismissKeyboard {
}

#pragma mark - Getters and Setters

- (void)setRenderers:(NSArray *)renderers {

    for (id renderer in renderers) {
        NSAssert([renderer conformsToProtocol:@protocol(PBCollectionItemRenderer)],
                 @"renderer doesn't conform to PBCollectionItemRenderer");
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
                 @"dataSource not a PBGroupItem class (or subclass)");

        NSInteger itemIndex = 0;

        for (PBCollectionItem *item in sectionItem.items) {

            NSAssert([item isKindOfClass:[PBCollectionItem class]],
                     @"section item not a PBCollectionItem class (or subclass)");

            [self
             configureItem:item
             section:section
             item:itemIndex
             selectedIndexes:self.selectedItemIndexes];

            itemIndex++;
        }

        section++;
    }

    self.selectedItemIndexes = selectedIndexes;

    [self.collectionLayout invalidateLayout];
}

- (void)configureItem:(PBCollectionItem *)item
              section:(NSInteger)section
                 item:(NSInteger)itemIndex
  selectedIndexes:(NSMutableArray *)selectedIndexes {

    NSIndexPath *indexPath =
    [NSIndexPath indexPathForRow:itemIndex inSection:section];
    item.indexPath = indexPath;

    if (item.isSelected) {

        [selectedIndexes addObject:indexPath];
    }

    if ([item.supplimentaryItem.kind isEqualToString:kPBCollectionViewSupplimentaryKind]) {
        [self.collectionView
         registerClass:[PBCollectionDefaultCell class]
         forSupplementaryViewOfKind:kPBCollectionViewSupplimentaryKind
         withReuseIdentifier:item.supplimentaryItem.reuseIdentifier];

        if (item.supplimentaryItem.backgroundImage != nil) {
            item.supplimentaryItem.size = item.supplimentaryItem.backgroundImage.size;
        }
    }

    if ([item.decorationItem.kind isEqualToString:kPBCollectionViewDecorationKind]) {
        [self.collectionView
         registerClass:[PBCollectionDefaultCell class]
         forSupplementaryViewOfKind:kPBCollectionViewDecorationKind
         withReuseIdentifier:item.decorationItem.reuseIdentifier];

        if (item.decorationItem.backgroundImage != nil) {
            item.decorationItem.size = item.decorationItem.backgroundImage.size;
        }
    }

    if (item.useBackgroundImageSize && item.backgroundImage != nil) {
        item.size = item.backgroundImage.size;
    }
}

- (void)setCollectionLayout:(PBCollectionLayout *)collectionLayout {

    BOOL changed = _collectionLayout != collectionLayout;
    _collectionLayout = collectionLayout;

    if (changed) {
        [self collectionLayoutChanged];
    }
}

#pragma mark - Public

- (void)collectionLayoutChanged {
}

- (void)updateLayout:(PBCollectionLayout *)layout
            animated:(BOOL)animated
         completion:(void(^)(void))completionBlock {

    NSAssert([layout isKindOfClass:[PBCollectionLayout class]],
             @"layout not a subclass of %@", NSStringFromClass([PBCollectionLayout class]));

    self.collectionLayout = layout;

    [self.collectionView
     setCollectionViewLayout:layout
     animated:animated
     completion:^(BOOL finished) {
         if (completionBlock != nil) {
             completionBlock();
         }
     }];
}

- (void)updateLayout:(PBCollectionLayout *)layout {

    NSAssert([layout isKindOfClass:[PBCollectionLayout class]],
             @"layout not a subclass of %@", NSStringFromClass([PBCollectionLayout class]));

    self.collectionLayout = layout;
    self.collectionView.collectionViewLayout = layout;
}

- (void)insertSectionItem:(PBSectionItem *)sectionItem
            performUpdate:(BOOL)performUpdate
               completion:(void(^)(void))completionBlock {

    [self
     insertSectionItem:sectionItem
     atSection:self.dataSource.count
     performUpdate:performUpdate
     completion:completionBlock];
}

- (void)insertSectionItem:(PBSectionItem *)sectionItem
                atSection:(NSInteger)section
            performUpdate:(BOOL)performUpdate
               completion:(void(^)(void))completionBlock {

    NSAssert([sectionItem isKindOfClass:[PBSectionItem class]],
             @"dataSource not a PBSectionItem class (or subclass): %@",
             NSStringFromClass([sectionItem class]));

    NSMutableArray *dataSource = [self.dataSource mutableCopy];

    section = MIN(section, dataSource.count);
    [dataSource insertObject:sectionItem atIndex:section];
    self.dataSource = dataSource;

    [self updateItemStates];

    if (performUpdate) {

        [self.collectionView performBatchUpdates:^{

            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
            [self.collectionView insertSections:indexSet];

        } completion:^(BOOL finished) {

            if (completionBlock != nil) {
                completionBlock();
            }
        }];

    } else {

        if (completionBlock != nil) {
            completionBlock();
        }
    }
}

- (void)replaceSectionItem:(PBSectionItem *)sectionItem
                 atSection:(NSInteger)section
             performUpdate:(BOOL)performUpdate
                completion:(void(^)(void))completionBlock {

    NSAssert([sectionItem isKindOfClass:[PBSectionItem class]],
             @"dataSource not a PBSectionItem class (or subclass): %@",
             NSStringFromClass([sectionItem class]));

    NSMutableArray *dataSource = [self.dataSource mutableCopy];

    section = MIN(section, dataSource.count);
    [dataSource replaceObjectAtIndex:section withObject:sectionItem];

    self.dataSource = dataSource;

    [self updateItemStates];

    if (performUpdate) {

        [self.collectionView performBatchUpdates:^{

            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
            [self.collectionView reloadSections:indexSet];

        } completion:^(BOOL finished) {

            if (completionBlock != nil) {
                completionBlock();
            }
        }];
        
    } else {

        if (completionBlock != nil) {
            completionBlock();
        }
    }
}

- (void)removeSectionItem:(PBSectionItem *)item
            performUpdate:(BOOL)performUpdate
               completion:(void(^)(BOOL removed))completionBlock {

    NSInteger section = [self.dataSource indexOfObject:item];

    if (section != NSNotFound) {

        [self
         removeSectionItemAtSection:section
         performUpdate:performUpdate
         completion:^{

             if (completionBlock != nil) {
                 completionBlock(performUpdate);
             }
         }];

    } else {

        if (completionBlock != nil) {
            completionBlock(NO);
        }
    }
}

- (void)removeSectionItemAtSection:(NSInteger)section
                     performUpdate:(BOOL)performUpdate
                        completion:(void(^)(void))completionBlock {

    if (section < self.dataSource.count) {

        NSMutableArray *dataSource = [self.dataSource mutableCopy];
        [dataSource removeObjectAtIndex:section];

        self.dataSource = dataSource;

        if (performUpdate) {

            [self.collectionView performBatchUpdates:^{

                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
                [self.collectionView deleteSections:indexSet];

            } completion:^(BOOL finished) {

                if (completionBlock != nil) {
                    completionBlock();
                }
            }];
        } else {

            if (completionBlock != nil) {
                completionBlock();
            }
        }

    } else {
        
        PBLog(@"WARN : tried to remove non-existent section %ld", (long)section);
    }
}

#pragma mark -

- (void)selectItems:(NSArray *)items inSection:(NSInteger)section {

    for (PBCollectionItem *item in items) {

        PBSectionItem *sectionItem = [self sectionItemAtSection:section];

        NSInteger index =
        [sectionItem.items indexOfObject:item];

        NSIndexPath *indexPath =
        [NSIndexPath indexPathForRow:index inSection:section];

        [self.collectionView
         selectItemAtIndexPath:indexPath
         animated:YES
         scrollPosition:item.scrollPosition];

        index++;
    }
}

- (void)deselectItems:(NSArray *)items inSection:(NSInteger)section {

    for (PBCollectionItem *item in items) {

        item.selected = NO;
        
        PBSectionItem *sectionItem = [self sectionItemAtSection:section];

        NSInteger index =
        [sectionItem.items indexOfObject:item];

        NSIndexPath *indexPath =
        [NSIndexPath indexPathForRow:index inSection:section];
        
        UICollectionViewCell *cell =
        [self.collectionView cellForItemAtIndexPath:indexPath];
        
        cell.selected = NO;

        [self.collectionView
         deselectItemAtIndexPath:indexPath
         animated:YES];

        index++;
    }
}

- (void)delselectOtherItems:(PBCollectionItem *)targetItem inSection:(NSInteger)section {

    NSMutableArray *items = [NSMutableArray array];

    PBSectionItem *sectionItem = [self sectionItemAtSection:section];

    for (PBCollectionItem *item in sectionItem.items) {

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

- (NSArray *)itemsAtSection:(NSInteger)section {

    PBSectionItem *sectionItem = [self sectionItemAtSection:section];
    return sectionItem.items;
}

- (PBCollectionItem *)itemAtIndexPath:(NSIndexPath *)indexPath {
    PBSectionItem *sectionItem = [self sectionItemAtSection:indexPath.section];
    return [self itemAtPosition:indexPath.row inSectionItem:sectionItem];
}

- (PBCollectionItem *)itemAtPosition:(NSInteger)position inSectionItem:(PBSectionItem *)sectionItem {

    PBCollectionItem *item = nil;

    if (position < sectionItem.items.count) {
        item = sectionItem.items[position];

        NSAssert([item isKindOfClass:[PBCollectionItem class]],
                 @"item not a PBCollectionItem (or subclass)");
    }

    return item;
}

- (void)reloadCollectionItem:(PBCollectionItem *)item {

    if (item.indexPath != nil) {
        [self.collectionView reloadItemsAtIndexPaths:@[item.indexPath]];
    }
}

- (void)reloadCollectionItemAtIndexPath:(NSIndexPath *)indexPath {

    PBCollectionItem *item = [self itemAtIndexPath:indexPath];

    if (item.indexPath != nil) {
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
}

- (void)preRegisterCellNibsAndClasses {
}

- (NSArray *)buildDataSource {
    return nil;
}

- (void)reloadDataSource {

    _reloadDataSourceCalled = YES;

    if (self.providedDataSource != nil) {
        self.dataSource = self.providedDataSource;
    } else {
        self.dataSource = [self buildDataSource];
    }

    for (PBSectionItem *sectionItem in self.dataSource) {
        [self reloadDataSourceSection:sectionItem];
    }
}

- (void)reloadDataSourceSection:(PBSectionItem *)sectionItem {

    for (PBCollectionItem *item in sectionItem.items) {

        NSAssert(item.reuseIdentifier != nil, @"No reuseIdentifier configured");
        NSAssert(item.cellNib != nil || item.cellClass != nil, @"No cellNib or cellClass configured");

        if (item.cellNib != nil) {

            [self.collectionView
             registerNib:item.cellNib
             forCellWithReuseIdentifier:item.reuseIdentifier];

            NSArray *views =
            [item.cellNib instantiateWithOwner:self options:nil];

            if (views.count > 0) {
                UIView *cell = views[0];
                item.size = cell.frame.size;
            }

        } else {

            [self.collectionView
             registerClass:item.cellClass
             forCellWithReuseIdentifier:item.reuseIdentifier];
        }

        if (item.selectAllItem) {

            NSAssert(self.selectAllItem == nil,
                     @"Multiple select all items are configured.");
            self.collectionView.allowsMultipleSelection = YES;
            self.selectAllItem = item;
        }
    }
}

- (void)reloadData {

    _reloadDataSourceCalled = NO;

    [self reloadDataSource];

    NSAssert(_reloadDataSourceCalled, @"You must call [super reloadDataSource]");

    for (PBSectionItem *sectionItem in self.dataSource) {
        [self clearSectionConfigured:sectionItem];
    }

    [self.collectionView reloadData];

    [self setSelectionDisabled:YES forItemIndexes:self.selectedItemIndexes];

    for (NSIndexPath *indexPath in self.selectedItemIndexes) {

        [self.collectionView
         selectItemAtIndexPath:indexPath
         animated:NO
         scrollPosition:UICollectionViewScrollPositionNone];
    }
}

- (void)reloadDataOnBackgroundThread {

    NSTimeInterval duration =
    self.collectionView.alpha > 0.0f ? .15f : 0.0f;

    __weak typeof(self) this = self;

    [UIView
     animateWithDuration:duration
     animations:^{
         self.collectionView.alpha = 0.0f;

     } completion:^(BOOL finished) {

         [this doReloadDataOnBackgroundThread:^{

             [UIView
              animateWithDuration:.15f
              animations:^{
                  
                  this.collectionView.alpha = 1.0f;
              }];
         }];
     }];
}

- (void)doReloadDataOnBackgroundThread:(void(^)(void))completionBlock {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        [self reloadDataSource];

        for (PBSectionItem *sectionItem in self.dataSource) {
            [self clearSectionConfigured:sectionItem];
        }

        dispatch_async(dispatch_get_main_queue(), ^{

            [self.collectionView reloadData];

            [self setSelectionDisabled:YES forItemIndexes:self.selectedItemIndexes];

            for (NSIndexPath *indexPath in self.selectedItemIndexes) {

                [self.collectionView
                 selectItemAtIndexPath:indexPath
                 animated:NO
                 scrollPosition:UICollectionViewScrollPositionNone];
            }

            if (completionBlock != nil) {
                completionBlock();
            }
        });
    });
}

- (void)setSelectionDisabled:(BOOL)selectionDisabled
              forItemIndexes:(NSArray *)itemIndexes {

    for (NSIndexPath *indexPath in itemIndexes) {
        PBCollectionItem *item = [self itemAtIndexPath:indexPath];
        item.selectionDisabled = selectionDisabled;
    }
}

- (void)clearSectionConfigured:(PBSectionItem *)sectionItem {
    
    for (PBCollectionItem *item in sectionItem.items) {
        item.itemConfigured = NO;
    }
}

- (void)updateItemStates {

    NSInteger section = 0;

    NSMutableDictionary *visibleCellsDict = [NSMutableDictionary dictionary];

    for (PBCollectionDefaultCell *cell in self.collectionView.visibleCells) {

        if ([cell isKindOfClass:[PBCollectionDefaultCell class]]) {
            visibleCellsDict[cell.indexPath] = cell;
        }
    }

    for (PBSectionItem *sectionItem in self.dataSource) {

        NSInteger itemCount = 0;

        for (PBCollectionItem *item in sectionItem.items) {

            NSIndexPath *oldIndexPath = item.indexPath;

            NSIndexPath *indexPath =
            [NSIndexPath
             indexPathForItem:itemCount
             inSection:section];

            if ([oldIndexPath isEqual:indexPath] == NO) {

                item.indexPath = indexPath;

                PBCollectionDefaultCell *cell = visibleCellsDict[oldIndexPath];
                cell.indexPath = indexPath;
            }
            itemCount++;
        }

        section++;
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataSource.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {

    PBSectionItem *sectionItem = [self sectionItemAtSection:section];
    return sectionItem.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    PBCollectionItem *item = [self itemAtIndexPath:indexPath];

    UICollectionViewCell *cell =
    [collectionView
     dequeueReusableCellWithReuseIdentifier:item.reuseIdentifier
     forIndexPath:indexPath];

    NSAssert([cell isKindOfClass:[PBCollectionDefaultCell class]],
             @"custom cells must extend from PBCollectionDefaultCell");

    PBCollectionDefaultCell *defaultCell = (id)cell;

    if (item.configureBlock != nil &&
        (defaultCell.cellConfigured == NO ||
         item.itemConfigured == NO)) {

        item.configureBlock(self, item, cell);
        defaultCell.cellConfigured = YES;
        item.itemConfigured = YES;
    }

    if ([cell isKindOfClass:[PBCollectionDefaultCell class]]) {

        PBCollectionDefaultCell *defaultCell = (id)cell;

        defaultCell.item = item;
        defaultCell.indexPath = indexPath;
        defaultCell.viewController = self;

        if (item.bindingBlock != nil) {
            item.bindingBlock(self, indexPath, item, cell);
        }

        [defaultCell willDisplayCell];
    }

    for (id <PBCollectionItemRenderer> renderer in self.renderers) {
        [renderer
         renderItem:item
         atIndexPath:indexPath
         inCell:cell
         withCollectionView:self];
    }

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {

    PBCollectionItem *item = [self itemAtIndexPath:indexPath];


    if ([item.supplimentaryItem.kind isEqualToString:kind]) {
        item = item.supplimentaryItem;
    } else if ([item.decorationItem.kind isEqualToString:kind]) {
        item = item.decorationItem;
    } else {
        NSAssert(NO, @"No PBCollectionItem supplimentaryItem or decorationItem specified");
    }

    UICollectionViewCell *cell =
    [collectionView
     dequeueReusableSupplementaryViewOfKind:kind
     withReuseIdentifier:item.reuseIdentifier
     forIndexPath:indexPath];

    NSAssert([cell isKindOfClass:[PBCollectionDefaultCell class]],
             @"custom cells must extend from PBCollectionDefaultCell");

    PBCollectionDefaultCell *defaultCell = (id)cell;

    if (item.configureBlock != nil &&
        (defaultCell.cellConfigured == NO ||
         item.itemConfigured == NO)) {

            item.configureBlock(self, item, cell);
            defaultCell.cellConfigured = YES;
            item.itemConfigured = YES;

        }

    if ([cell isKindOfClass:[PBCollectionDefaultCell class]]) {

        PBCollectionDefaultCell *defaultCell = (id)cell;

        defaultCell.item = item;
        defaultCell.indexPath = indexPath;
        defaultCell.viewController = self;
        defaultCell.backgroundImageView.image = item.backgroundImage;
    }

    if (item.bindingBlock != nil) {
        item.bindingBlock(self, indexPath, item, cell);
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {

    if ([cell isKindOfClass:[PBCollectionDefaultCell class]]) {

        PBCollectionDefaultCell *defaultCell = (id)cell;
        [defaultCell didEndDisplayingCell];
    }
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    PBCollectionItem *item = [self itemAtIndexPath:indexPath];
    PBSectionItem *sectionItem = [self sectionItemAtSection:indexPath.section];

    if (item == self.selectAllItem) {

        [self
         delselectOtherItems:self.selectAllItem
         inSection:indexPath.section];

    } else if (self.selectAllItem != nil) {

        NSInteger selectionCount = 0;

        PBSectionItem *sectionItem = [self sectionItemAtSection:indexPath.section];

        for (PBCollectionItem *item in sectionItem.items) {

            if (item.isSelected) {
                selectionCount++;
            }
        }

        if (selectionCount == 0) {
            [self selectItems:@[self.selectAllItem] inSection:indexPath.section];
        } else {
            [self deselectItems:@[self.selectAllItem] inSection:indexPath.section];
        }
        
    } else {

        if (self.isMultiSelect == NO) {
            
            NSMutableArray *deselectedItems = [NSMutableArray array];
            
            [sectionItem.items enumerateObjectsUsingBlock:^(PBCollectionItem *otherItem, NSUInteger idx, BOOL *stop) {
                
                if (item != otherItem && otherItem.isSelected) {
                    [deselectedItems addObject:otherItem];
                }
            }];
            
            [self deselectItems:deselectedItems inSection:indexPath.section];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.dragging = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.dragging = decelerate;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.dragging = NO;
}

@end
