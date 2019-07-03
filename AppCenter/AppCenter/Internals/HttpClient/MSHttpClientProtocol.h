// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^MSHttpRequestCompletionHandler)(NSData *_Nullable responseBody, NSHTTPURLResponse *_Nullable response,
                                               NSError *_Nullable error);

@protocol MSHttpClientProtocol

@required

/**
 * Make an HTTP call.
 *
 * @param url The endpoint to use in the HTTP request.
 * @param method The HTTP method (verb) to use for the HTTP request (e.g. GET, POST, etc.).
 * @param headers HTTP headers.
 * @param data A data instance that will be transformed request body.
 * @param completionHandler Completion handler.
 */
- (void)sendAsync:(NSURL *)url
               method:(NSString *)method
              headers:(nullable NSDictionary<NSString *, NSString *> *)headers
                 data:(nullable NSData *)data
    completionHandler:(nullable MSHttpRequestCompletionHandler)completionHandler;

/**
 * Pause the HTTP client.
 * The client is automatically paused when it becomes disabled or on network issues. A paused state doesn't impact the current enabled
 * state.
 *
 * @see resume.
 */
- (void)pause;

/**
 * Resume the HTTP client.
 *
 * @see pause.
 */
- (void)resume;

/**
 * Enables or disables the client. All pending requests are canceled and discarded upon disabling.
 *
 * @param isEnabled The desired enabled state of the client - pass `YES` to enable, `NO` to disable.
 */
- (void)setEnabled:(BOOL)isEnabled;

@end

NS_ASSUME_NONNULL_END
