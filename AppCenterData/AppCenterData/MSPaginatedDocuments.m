// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import "MSPaginatedDocuments.h"
#import "MSCosmosDb.h"
#import "MSData.h"
#import "MSDataInternal.h"
#import "MSPageInternal.h"
#import "MSPaginatedDocumentsInternal.h"
#import "MSSerializableDocument.h"
#import "MSTokenExchange.h"

@implementation MSPaginatedDocuments

@synthesize currentPage = _currentPage;
@synthesize continuationToken = _continuationToken;
@synthesize partition = _partition;
@synthesize documentType = _documentType;

- (instancetype)initWithPage:(MSPage *)page
                   partition:(NSString *)partition
                documentType:(Class)documentType
           continuationToken:(NSString *_Nullable)continuationToken {
  if ((self = [super init])) {
    _currentPage = page;
    _partition = partition;
    _documentType = documentType;
    _continuationToken = continuationToken;
  }
  return self;
}

- (instancetype)initWithError:(MSDataError *)error partition:(NSString *)partition documentType:(Class)documentType {
  return [self initWithPage:[[MSPage alloc] initWithError:error] partition:partition documentType:documentType continuationToken:nil];
}

- (BOOL)hasNextPage {
  return [self.continuationToken length] != 0;
}

- (void)nextPageWithCompletionHandler:(void (^)(MSPage *page))completionHandler {
  if ([self hasNextPage]) {
    [MSData listDocumentsWithType:self.documentType
                        partition:self.partition
                continuationToken:self.continuationToken
                completionHandler:^(MSPaginatedDocuments *documents) {
                  // Update current page and continuation token.
                  self.currentPage = documents.currentPage;
                  self.continuationToken = documents.continuationToken;

                  // Notify completion handler.
                  completionHandler(documents.currentPage);
                }];
  } else {
    completionHandler(nil);
  }
}

@end
