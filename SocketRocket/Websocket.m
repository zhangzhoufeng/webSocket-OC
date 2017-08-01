//
//  Websocket.m
//  ubereasycontrol
//
//  Created by devpltc on 15/9/28.
//  Copyright © 2015年 devpltc. All rights reserved.
//

#import "Websocket.h"

@implementation Websocket
@synthesize srwebsocket;

static Websocket *instance=nil;
+ (Websocket*)sharedWebSocketInstance{
    if (instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[self alloc]init];
        });
    }
    return instance;
}

+(id)initWithZone:(NSZone *)zone{
    if (instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance =[super allocWithZone:zone];
        });
    }
    return instance;
}

- (id)copyWithZone:(NSZone *)zone{
    return instance;
}

- (void)reconnect;
{
    if (self.srwebsocket) {
        self.srwebsocket.delegate = nil;
        [self.srwebsocket close];
    }
    NSLog(@"reconnect ---->%p,%@<---------",[HotelInfo sharedInstance],[HotelInfo sharedInstance].hotelID);
    NSString *websocketPath = [[NSString alloc]init];
    if([HotelInfo sharedInstance].connetLocalServer && [HotelInfo sharedInstance].serviceIP != nil){
        websocketPath = [NSString stringWithFormat:@"ws://%@:%d",[HotelInfo sharedInstance].serviceIP,WEBSOCKETPORT];
        
    }else if([HotelInfo sharedInstance].cloudIP != nil){
        websocketPath = [NSString stringWithFormat:@"ws://%@:%d",[HotelInfo sharedInstance].cloudIP,WEBSOCKETPORT];
    }
    if (websocketPath != nil && ![websocketPath isEqual:@""]) {
        self.srwebsocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:websocketPath]]];
        self.srwebsocket.delegate = self;
        [self.srwebsocket open];
        NSLog(@"srwebsocket 对象地址 %p －－－－－－－||||||%@|||||||||－－－－－－－－－－－",self.srwebsocket,websocketPath);
    }
}

#pragma mark - SRWebSocketDelegate
-(void)webSocketDidOpen:(SRWebSocket *)srWebSocket
{
    NSLog(@"srwebsocket ---------- 对象地址 %p",srWebSocket);
    NSLog(@"webSocketDidOpen ---->%p,%@<--------",[HotelInfo sharedInstance],[HotelInfo sharedInstance].hotelID);
    NSString *message =[NSString stringWithFormat:  @"atte:phone-%@-%@",[HotelInfo sharedInstance].hotelID,[HotelInfo sharedInstance].roomNum];
    NSLog(@"当前建立的连接是 %@++++++++++++++++++++++++++++++++++++++++",message);
    [srWebSocket send:message];
}

-(void)webSocket:(SRWebSocket *)srWebSocket didFailWithError:(NSError *)error{
    NSLog(@"连接错误 %@+++++++++++++++++++++++++++++++++++++++%@",error,srWebSocket);
    srWebSocket = nil;
}
-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    
    NSLog(@"收到数据了了了了了哈 %@------",message);
    message = [message stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
    NSData *jsonData = [(NSString *)message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *keys =   [NSJSONSerialization JSONObjectWithData:(NSData*)jsonData options:NSJSONReadingMutableContainers error:nil];
    if(message != nil && [message length]>0){

        if ([[keys valueForKey:@"light"] count] >0) {            
            if ([self.delegateLight respondsToSelector:@selector(changeValue:deviceType:)]) {
                 NSLog(@"收到灯光代理协议 %@",self.delegateLight);
                [self.delegateLight changeValue:keys deviceType:LIGHTTYPE];
            }else{
                 NSLog(@"收到灯光代理协议为空DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD");
            }
        }
        if ([[keys valueForKey:@"scene"] count] >0) {
            
            if ([self.delegateScene respondsToSelector:@selector(changeValue:deviceType:)]) {
                NSLog(@"收到场景代理协议 %@",self.delegateScene);
                [self.delegateScene changeValue:keys deviceType:LIGHTTYPE];
            }else{
                NSLog(@"收到场景代理协议为空jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj");
            }
        }
        if ([[keys valueForKey:@"curtain"] count] >0) {
            if ([self.delegateCurtain respondsToSelector:@selector(changeValue:deviceType:)]) {
                NSLog(@"收到窗帘代理协议 %@",self.delegateCurtain);
                [self.delegateCurtain changeValue:keys deviceType:CURTAIN];
            }else{
                NSLog(@"收到窗帘代理协议为空CCCCCCCCCCCCCCCCCCCCCCCCCCCCCC");
            }
            
            //代理
        }
        if ([[keys valueForKey:@"air"] count] >0) {
            if ([self.delegateAir respondsToSelector:@selector(changeValue:deviceType:)]) {
                NSLog(@"收到空调代理协议 %@",self.delegateAir);
                [self.delegateAir changeValue:keys deviceType:AIR];
            }else{
                 NSLog(@"收到空调代理协议为空KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK");
            }
           
        }
    }
}

-(void)webSocket:(SRWebSocket *)srWebSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    NSLog(@"WebSocket closed");
    NSLog(@"-----------------------WebSocket closed--------------------------------");
    srWebSocket = nil;
}

-(void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload{
    NSLog(@"Websocket received pong");
}

@end
