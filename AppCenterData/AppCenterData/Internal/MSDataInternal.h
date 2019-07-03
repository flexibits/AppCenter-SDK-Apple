// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>

#import "MSDBDocumentStore.h"
#import "MSData.h"
#import "MSDataOperationProxy.h"
#import "MSDocumentStore.h"
#import "MSServiceInternal.h"
#import "MS_Reachability.h"

@protocol MSDocumentStore;

NS_ASSUME_NONNULL_BEGIN

@protocol MSHttpClientProtocol;

@interface MSData () <MSServiceInternal>

/**
 * A token exchange url that is used to get resource tokens.
 */
@property(nonatomic, copy) NSURL *tokenExchangeUrl;

/**
 * An ingestion instance that is used to send a request to CosmosDb.
 * HTTP client.
 */
@property(nonatomic, nullable) id<MSHttpClientProtocol> httpClient;

@property(nonatomic) MS_Reachability *reachability;

/**
 * Data operation proxy instance (for offline/online scenarios).
 */
@property(nonatomic) MSDataOperationProxy *dataOperationProxy;

/**
 * Retrieve a paginated list of the documents in a partition.
 *
 * @param documentType The object type of the documents in the partition. Must conform to MSSerializableDocument protocol.
 * @param partition The CosmosDB partition key.
 * @param continuationToken The continuation token for the page to retrieve (if any).
 * @param completionHandler Callback to accept documents.
 */
+ (void)listDocumentsWithType:(Class)documentType
                    partition:(NSString *)partition
            continuationToken:(NSString *_Nullable)continuationToken
            completionHandler:(MSPaginatedDocumentsCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
