//
//  QMMediaController.h
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 2/19/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QMMediaViewDelegate.h"
#import "QMMediaPresenter.h"

@protocol QMMediaControllerDelegate;

@interface QMMediaController : NSObject <QMChatAttachmentServiceDelegate>

@property (copy, nonatomic) void(^onError)(QBChatMessage *message, NSError *error);
- (instancetype)initWithViewController:(UIViewController<QMMediaControllerDelegate> *)controller;
- (void)configureView:(id<QMMediaViewDelegate>)view withMessage:(QBChatMessage *)message attachmentID:(NSString *)attachmentID;

@end

@protocol QMMediaControllerDelegate <NSObject>

@required

- (id <QMMediaViewDelegate>)viewForMessage:(QBChatMessage *)message;
- (void)didUpdateMessage:(QBChatMessage *)message;

@optional


@end
