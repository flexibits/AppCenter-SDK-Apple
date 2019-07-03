// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>

#import "MSChannelDelegate.h"

/**
 * One Collector channel delegate that is used to redirect selected traffic to One Collector.
 */
@interface MSOneCollectorChannelDelegate : NSObject <MSChannelDelegate>

/**
 * Init a `MSOneCollectorChannelDelegate` with an install Id.
 *
 * @param installId A device install Id.
 * @param baseUrl base url to use for backend communication.
 *
 * @return A `MSOneCollectorChannelDelegate` instance.
 */
- (instancetype)initWithInstallId:(NSUUID *)installId baseUrl:(NSString *)baseUrl;

/**
 * Change the base URL (schema + authority + port only) that is used to communicate with the backend.
 *
 * @param logUrl base URL to use for backend communication.
 */
- (void)setLogUrl:(NSString *)logUrl;

@end
