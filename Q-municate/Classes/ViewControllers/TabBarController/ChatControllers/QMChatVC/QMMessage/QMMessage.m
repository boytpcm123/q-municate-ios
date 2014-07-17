//
//  QMMessage.m
//  Q-municate
//
//  Created by Andrey on 12.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMMessage.h"
#import "QMChatLayoutConfigs.h"
#import "NSString+UsedSize.h"
#import "UIColor+Hex.h"

typedef NS_ENUM(NSUInteger, QMChatNotificationsType) {
    
    QMChatNotificationsTypeNone,
    QMChatNotificationsTypeRoomCreated,
    QMChatNotificationsTypeRoomUpdated,
};

NSString *const kQMNotificationTypeKey = @"notification_type";

@interface QMMessage()

@property (assign, nonatomic) CGSize messageSize;
@property (assign, nonatomic) QMMessageType type;
@property (strong, nonatomic) UIImage *balloonImage;
@property (strong, nonatomic) UIColor *balloonColor;

@end

@implementation QMMessage

- (instancetype)initWithChatHistoryMessage:(QBChatHistoryMessage *)historyMessage {
    
    self = [super init];
    if (self) {
        
        self.text = historyMessage.text;
        self.ID = historyMessage.ID;
        self.recipientID = historyMessage.recipientID;
        self.senderID = historyMessage.senderID;
        self.datetime = historyMessage.datetime;
        self.customParameters = historyMessage.customParameters;
        self.attachments = historyMessage.attachments;
        
        NSNumber *notificationType = self.customParameters[kQMNotificationTypeKey];
        
        if (self.attachments.count > 0) {
            
            self.type = QMMessageTypePhoto;
            self.layout = QMMessageAttachmentLayout;
            
        } else if (notificationType) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"Need update it"
                                         userInfo:@{}];
            self.layout = QMMessageQmunicateLayout;
            self.type = QMMessageTypeSystem;
            
        } else {
            
            self.type = QMMessageTypeText;
            self.layout = QMMessageQmunicateLayout;
        }
        
    }
    return self;
}

- (CGSize)calculateMessageSize {
    
    QMMessageLayout layout = self.layout;
    QMChatBalloon balloon = self.balloonSettings;
    UIEdgeInsets insets = balloon.imageCapInsets;
    CGSize contentSize = CGSizeZero;
    /**
     Calculate content size
     */
    if (self.type == QMMessageTypePhoto) {
        
        contentSize = CGSizeMake(150, 150);
        
    } else if (self.type == QMMessageTypeText) {
        
        UIFont *font = UIFontFromQMMessageLayout(self.layout);
        
        CGFloat textWidth = layout.messageMaxWidth - layout.userImageSize.width - insets.left - insets.right;
        
        contentSize = [self.text usedSizeForWidth:textWidth
                                             font:font
                                   withAttributes:self.attributes];
        if (layout.messageMinWidth > 0) {
            if (contentSize.width < layout.messageMinWidth) {
                contentSize.width = layout.messageMinWidth;
            }
        }
    }
    
    layout.contentSize = contentSize;   //Set Content size
    self.layout = layout;               //Save Content size for reuse
    
    /**
     *Calculate message size
     */
    CGSize messageSize = contentSize;
    
    messageSize.height += layout.messageMargin.top + layout.messageMargin.bottom + insets.top + insets.bottom;
    messageSize.width += layout.messageMargin.left + layout.messageMargin.right;
    
    if (!CGSizeEqualToSize(layout.userImageSize, CGSizeZero)) {
        if (messageSize.height - (layout.messageMargin.top + layout.messageMargin.bottom) < layout.userImageSize.height) {
            messageSize.height = layout.userImageSize.height + layout.messageMargin.top + layout.messageMargin.bottom;
        }
    }
    
    return messageSize;
}

- (CGSize)messageSize {
    
    if (CGSizeEqualToSize(_messageSize, CGSizeZero)) {
        
        _messageSize = [self calculateMessageSize];
    }
    
    return _messageSize;
}

- (UIImage *)balloonImage {
    
    if (!_balloonImage) {
        
        NSAssert(self, @"Check it");
        
        QMChatBalloon balloon = [self balloonSettings];
        
        NSString *imageName = balloon.imageName;
        UIImage *balloonImage = [UIImage imageNamed:imageName];
        
        balloonImage = [balloonImage resizableImageWithCapInsets:balloon.imageCapInsets];
        _balloonImage = [balloonImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return _balloonImage;
}

- (QMChatBalloon)balloonSettings {
    
    if (self.align == QMMessageContentAlignLeft) {
        return self.layout.leftBalloon;
    } else if (self.align == QMMessageContentAlignRight) {
        return self.layout.rightBalloon;
    }
    
    return QMChatBalloonNull;
}

- (UIColor *)textColor {
    
    QMChatBalloon balloonSettings = [self balloonSettings];
    NSString *hexString = balloonSettings.textColor;
    
    if (hexString.length > 0) {
        
        UIColor *color = [UIColor colorWithHexString:hexString];
        NSAssert(color, @"Check it");
        return color;
    }
    
    return nil;
}

- (UIColor *)balloonColor {
    
    if (!_balloonColor) {
        
        QMChatBalloon balloonSettings = [self balloonSettings];
        NSString *hexString = balloonSettings.hexTintColor;
        
        if (hexString.length > 0) {
            
            UIColor *color = [UIColor colorWithHexString:hexString];
            NSAssert(color, @"Check it");
            
            _balloonColor = color;
        }
    }
    
    return _balloonColor;
}

@end
