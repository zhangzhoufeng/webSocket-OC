//
//  Websocket.h
//  ubereasycontrol
//
//  Created by devpltc on 15/9/28.
//  Copyright © 2015年 devpltc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"
#import "Comunication.h"
#import "Constants.h"
#import "HotelInfo.h"


@class Websocket;
@protocol WebSocketDelegate <NSObject>
    - (void)changeValue:(NSDictionary *)value deviceType:(DEVICETYPE)type;
@end

@interface Websocket : NSObject<SRWebSocketDelegate>

@property (nonatomic,strong) SRWebSocket *srwebsocket;
@property (nonatomic,  weak) id<WebSocketDelegate>delegateLight;
@property (nonatomic,  weak) id<WebSocketDelegate>delegateCurtain;
@property (nonatomic,  weak) id<WebSocketDelegate>delegateScene;
@property (nonatomic,  weak) id<WebSocketDelegate>delegateAir;
+ (Websocket *)sharedWebSocketInstance;
- (void)reconnect;

@end
