//
//  JSONParser.h
//  Scanner
//
//  Created by hb3 on 27/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
@protocol JSONParserDelegate <NSObject>
@optional
- (void)parserDidFinishLoadingReturnData:(NSMutableArray *)responseArray;
- (void)parserDidFailWithRestoreError:(NSError*)error;
@end

@interface JSONParser : NSObject 
{
	NSURLResponse *response;
	NSString *urlString;
	NSURLConnection *urlconnection;
	id <JSONParserDelegate> delegate;
	NSString *reasonToFail;
}

@property(nonatomic,retain) NSString *responseString;
@property(nonatomic,retain)NSMutableArray *arrayResponse;
@property(nonatomic,retain) NSString *requestMethod;
@property (retain) NSString *urlString;
@property (retain) id delegate;

- (NSMutableArray *) getArrayFromUrl:(NSString*)StrURL params:(NSDictionary*)parameters;
- (NSMutableArray *) getArrayFromUrl:(NSString*)StrURL;
- (void) getArrayFromUrlAsyn:(NSString*)StrURL params:(NSDictionary*)parameters;
- (void) getArrayFromUrlAsyn:(NSString*)StrURL;
+(JSONParser *)sharedInstance;
@end
