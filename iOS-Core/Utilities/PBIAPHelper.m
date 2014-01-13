//
//  PBIAPHelper.m
//  Bedrock
//
//  Created by Nick Bolton on 1/12/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBIAPHelper.h"

NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";

@interface PBIAPHelper() <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic, strong) SKProductsRequest *productsRequest;
@property (nonatomic, copy) void (^completionHandler)(BOOL success, NSArray * products);
@property (nonatomic, copy) void (^purchaseCompletionHandler)(BOOL success, NSError *error);
@property (nonatomic, strong) NSSet *productIdentifiers;
@property (nonatomic, strong) NSMutableSet *purchasedProductIdentifiers;
@property (nonatomic, readwrite) NSArray *products;

@end

@implementation PBIAPHelper

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {

    if ((self = [super init])) {

        self.productIdentifiers = productIdentifiers;

        self.purchasedProductIdentifiers = [NSMutableSet set];

        for (NSString * productIdentifier in self.productIdentifiers) {

            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {

                [self.purchasedProductIdentifiers addObject:productIdentifier];
                PBLog(@"Previously purchased: %@", productIdentifier);

            } else {
                PBLog(@"Not purchased: %@", productIdentifier);
            }
        }

        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)requestProductsWithCompletionHandler:(void (^)(BOOL success, NSArray * products))completionHandler {

    self.completionHandler = completionHandler;

    self.productsRequest =
    [[SKProductsRequest alloc]
     initWithProductIdentifiers:self.productIdentifiers];

    self.productsRequest.delegate = self;
    [self.productsRequest start];
}

- (SKProduct *)productWithIdentifier:(NSString *)productIdentifier {

    SKProduct *result = nil;

    for (SKProduct *product in self.products) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            result = product;
            break;
        }
    }

    return result;
}

- (BOOL)productPurchased:(NSString *)productIdentifier {
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product
        completion:(void(^)(BOOL success, NSError *error))completionHandler {

    self.purchaseCompletionHandler = completionHandler;

    PBLog(@"Buying %@...", product.productIdentifier);

    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restoreCompletedTransactions {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"completeTransaction...");

    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];

    if (self.purchaseCompletionHandler != nil) {
        self.purchaseCompletionHandler(YES, nil);
        self.purchaseCompletionHandler = nil;
    }
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"restoreTransaction...");

    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {

    NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }

    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];

    if (self.purchaseCompletionHandler != nil) {
        self.purchaseCompletionHandler(NO, transaction.error);
        self.purchaseCompletionHandler = nil;
    }
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {

    [self.purchasedProductIdentifiers addObject:productIdentifier];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
}

#pragma mark - SKPaymentTransactionObserver Conformance

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {

    PBLog(@"Loaded list of products...");
    self.productsRequest = nil;

    NSArray *skProducts = response.products;

    self.products = skProducts;

    for (SKProduct *skProduct in skProducts) {

        PBLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }

    if (self.completionHandler != nil) {
        self.completionHandler(YES, skProducts);
        self.completionHandler = nil;
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {

    PBLog(@"Failed to load list of products.");
    self.productsRequest = nil;

    if (self.completionHandler != nil) {
        self.completionHandler(NO, nil);
        self.completionHandler = nil;
    }
}

@end
