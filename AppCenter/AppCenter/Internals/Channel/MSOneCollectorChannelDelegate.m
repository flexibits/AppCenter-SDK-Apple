#import "MSAbstractLogInternal.h"
#import "MSAppCenterInternal.h"
#import "MSChannelProtocol.h"
#import "MSChannelGroupProtocol.h"
#import "MSChannelUnitConfiguration.h"
#import "MSChannelUnitProtocol.h"
#import "MSCommonSchemaLog.h"
#import "MSCSEpochAndSeq.h"
#import "MSLog.h"
#import "MSLogConversion.h"
#import "MSLogger.h"
#import "MSOneCollectorChannelDelegatePrivate.h"
#import "MSOneCollectorIngestion.h"
#import "MSUtility.h"

static NSString *const kMSOneCollectorGroupIdSuffix = @"/one";
static NSString *const kMSOneCollectorBaseUrl = @"https://mobile.events.data.microsoft.com"; // TODO: move to constants?

@implementation MSOneCollectorChannelDelegate

- (instancetype)init {
  self = [super init];
  if (self) {
    _oneCollectorChannels = [NSMutableDictionary new];
    _oneCollectorSender = [[MSOneCollectorIngestion alloc] initWithBaseUrl:kMSOneCollectorBaseUrl];
    _epochsAndSeqsByIKey = [NSMutableDictionary new];
  }

  return self;
}

- (instancetype)initWithInstallId:(NSUUID *)installId {
  self = [self init];
  if (self) {
    _installId = installId;
  }
  return self;
}

- (void)channelGroup:(id<MSChannelGroupProtocol>)channelGroup didAddChannelUnit:(id<MSChannelUnitProtocol>)channel {

  // Add OneCollector group based on the given channel's group id.
  NSString *groupId = channel.configuration.groupId;
  if (![self isOneCollectorGroup:groupId]) {
    NSString *oneCollectorGroupId =
        [NSString stringWithFormat:@"%@%@", channel.configuration.groupId, kMSOneCollectorGroupIdSuffix];
    MSChannelUnitConfiguration *channelUnitConfiguration =
        [[MSChannelUnitConfiguration alloc] initDefaultConfigurationWithGroupId:oneCollectorGroupId];

    id<MSChannelUnitProtocol> channelUnit =
        [channelGroup addChannelUnitWithConfiguration:channelUnitConfiguration withSender:self.oneCollectorSender];
    self.oneCollectorChannels[groupId] = channelUnit;
  }
}

- (BOOL)channelUnit:(id<MSChannelUnitProtocol>)channelUnit shouldFilterLog:(id<MSLog>)log {

  // Do not filter the log from one collector channels.
  if ([self isOneCollectorGroup:channelUnit.configuration.groupId]) {
    return NO;
  }
  return [[log transmissionTargetTokens] count] > 0;
}

- (void)channel:(id<MSChannelProtocol>)__unused channel prepareLog:(id<MSLog>)log {

  // Prepare Common Schema logs.
  if ([log isKindOfClass:[MSCommonSchemaLog class]]) {
    MSCommonSchemaLog *csLog = (MSCommonSchemaLog *)log;

    // Set epoch and seq to SDK.
    MSCSEpochAndSeq *epochAndSeq = self.epochsAndSeqsByIKey[csLog.iKey];
    if (!epochAndSeq) {
      epochAndSeq = [[MSCSEpochAndSeq alloc] initWithEpoch:MS_UUID_STRING];
    }
    csLog.ext.sdkExt.epoch = epochAndSeq.epoch;
    csLog.ext.sdkExt.seq = ++epochAndSeq.seq;
    self.epochsAndSeqsByIKey[csLog.iKey] = epochAndSeq;

    // Set install ID to SDK.
    csLog.ext.sdkExt.installId = self.installId;
  }
}

- (void)channel:(id<MSChannelProtocol>)channel didSetEnabled:(BOOL)isEnabled andDeleteDataOnDisabled:(BOOL)deletedData {
  if ([channel conformsToProtocol:@protocol(MSChannelUnitProtocol)]) {
    NSString *groupId = ((id<MSChannelUnitProtocol>)channel).configuration.groupId;
    if (![self isOneCollectorGroup:groupId]) {

      // Mirror disabling state to OneCollector channels.
      [self.oneCollectorChannels[groupId] setEnabled:isEnabled andDeleteDataOnDisabled:deletedData];
    }
  } else if ([channel conformsToProtocol:@protocol(MSChannelGroupProtocol)] && !isEnabled && deletedData) {

    // Reset epoch and seq values when SDK is disabled as a whole.
    [self.epochsAndSeqsByIKey removeAllObjects];
  }
}

- (void)channel:(id<MSChannelProtocol>)channel didPrepareLog:(id<MSLog>)log withInternalId:(NSString *)__unused internalId {
  if (![self shouldSendLogToOneCollector:log] ||
      ![channel conformsToProtocol:@protocol(MSChannelUnitProtocol)]) {
    return;
  }
  id<MSChannelUnitProtocol> channelUnit = (id<MSChannelUnitProtocol>)channel;
  NSString *groupId = channelUnit.configuration.groupId;
  id<MSChannelUnitProtocol> oneCollectorChannelUnit = [self.oneCollectorChannels objectForKey:groupId];
  if (!oneCollectorChannelUnit) {
    return;
  }
  id<MSLogConversion> logConversion = (id<MSLogConversion>)log;
  NSArray<MSCommonSchemaLog *> *commonSchemaLogs = [logConversion toCommonSchemaLogs];
  for (MSCommonSchemaLog *commonSchemaLog in commonSchemaLogs) {
    [oneCollectorChannelUnit enqueueItem:commonSchemaLog];
  }
}

- (BOOL)isOneCollectorGroup:(NSString *)groupId {
  return [groupId hasSuffix:kMSOneCollectorGroupIdSuffix];
}

- (BOOL)shouldSendLogToOneCollector:(id<MSLog>)log {
  NSObject *logObject = (NSObject *)log;
  return [[log transmissionTargetTokens] count] > 0 && [log conformsToProtocol:@protocol(MSLogConversion)] && ![logObject isKindOfClass:[MSCommonSchemaLog class]];
}

@end
