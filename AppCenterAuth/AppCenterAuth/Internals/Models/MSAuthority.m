// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import "MSAuthority.h"

@implementation MSAuthority

static NSString *const kMSType = @"type";

static NSString *const kMSDefault = @"default";

static NSString *const kMSAuthorityUrl = @"authority_url";

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
  if (!dictionary) {
    return nil;
  }
  if ((self = [super init])) {
    if (dictionary[kMSType]) {
      self.type = (NSString * _Nonnull) dictionary[kMSType];
    }
    if (dictionary[kMSDefault]) {
      self.defaultAuthority = [(NSNumber *)dictionary[kMSDefault] boolValue];
    }
    if (dictionary[kMSAuthorityUrl]) {
      if (![(NSObject *)dictionary[kMSAuthorityUrl] isKindOfClass:[NSNull class]]) {
        NSString *_Nonnull authorityUrl = (NSString * _Nonnull) dictionary[kMSAuthorityUrl];
        self.authorityUrl = (NSURL * _Nonnull)[NSURL URLWithString:authorityUrl];
      }
    }
  }
  return self;
}

- (BOOL)isValid {
  return self.type && self.authorityUrl;
}

@end
