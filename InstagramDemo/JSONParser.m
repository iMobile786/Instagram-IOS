//
//  JSONParser.m
//  Scanner
//
//  Created by hb3 on 27/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "JSONParser.h"
#import "ASIHTTPRequest.h"
#import "SBJSON.h"
#import "AppDelegate.h"
#define DELEGATE_CALLBACK(X, Y) if (self.delegate && [self.delegate respondsToSelector:@selector(X)]) [self.delegate performSelector:@selector(X) withObject:Y];

@implementation JSONParser

@synthesize urlString;
@synthesize delegate;
@synthesize arrayResponse;
@synthesize requestMethod;
@synthesize responseString;
JSONParser *jsonParser;


-(id)init
{
    self = [super init];
    if(self)
    {
        arrayResponse=[[NSMutableArray alloc] init];
        requestMethod=@"POST";
        responseString=[[NSString alloc]init];
    }
    return self;
}

- (NSMutableArray *) getArrayFromUrl:(NSString*)StrURL params:(NSDictionary*)parameters
{
	self.urlString = StrURL;
//	NSLog(@"%@",self.urlString);
    
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = YES;	
  	
	NSString *httpBody = @"";
	NSArray *KeyArray = [parameters allKeys];
	for ( int i = 0 ; i < [KeyArray count]; i++ )
	{
		httpBody = [httpBody stringByAppendingFormat:@"&%@=%@" , [KeyArray objectAtIndex:i] , [parameters objectForKey:[KeyArray objectAtIndex:i] ]];
	}
//    NSLog(@"%@",httpBody);
	ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:self.urlString]];
	[request appendPostData:[httpBody dataUsingEncoding:NSUTF8StringEncoding]];
	[request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
	[request setRequestMethod:self.requestMethod];
	[request setDelegate:self];
	//[request setTimeOutSeconds:60]; 
	[request startSynchronous];
    return self.arrayResponse;
}
- (NSMutableArray *) getArrayFromUrl:(NSString*)StrURL {
    return [self getArrayFromUrl:StrURL params:nil];
}
#pragma mark -
#pragma mark Asynchronous delegate 

- (void) getArrayFromUrlAsyn:(NSString*)StrURL params:(NSDictionary*)parameters
{
	self.urlString = StrURL;
//	NSLog(@"%@",self.urlString);
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = YES;	
  	
	NSString *httpBody = @"";
	NSArray *KeyArray = [parameters allKeys];
	for ( int i = 0 ; i < [KeyArray count]; i++ )
	{
		httpBody = [httpBody stringByAppendingFormat:@"&%@=%@" , [KeyArray objectAtIndex:i] , [parameters objectForKey:[KeyArray objectAtIndex:i] ]];
	}
	ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:self.urlString]];
	[request appendPostData:[httpBody dataUsingEncoding:NSUTF8StringEncoding]];
	[request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
	[request setRequestMethod:self.requestMethod];
	[request setDelegate:self];
	//[request setTimeOutSeconds:60]; 
	[request startAsynchronous];
    
}

- (void) getArrayFromUrlAsyn:(NSString*)StrURL
{
    [self getArrayFromUrlAsyn:StrURL params:nil];
}

#pragma mark - ASIHTTPRequest delegate 

- (void)requestFinished:(ASIHTTPRequest *)request 
{
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = NO;	
	// Use when fetching text data
	NSData *webData = [[NSData alloc] initWithData:[request responseData]];
	NSString *strEr =  [[[NSString alloc] initWithData:webData encoding:NSUTF8StringEncoding] autorelease];
    self.responseString=[[NSString alloc] initWithFormat:strEr];
	[webData release];
	//DO something with webData
    SBJSON *json = [[SBJSON new] autorelease];	
    
	self.arrayResponse = (NSMutableArray*) [json objectWithString:strEr error:nil];
	[self.arrayResponse retain];
	[delegate parserDidFinishLoadingReturnData:self.arrayResponse];
}

/*
 The async request to get new data failed
 */
- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	//NSLog(@"%@", error);
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = NO;
	
	//notify
	//[delegate loadingFailed:[error localizedDescription]];
	[delegate parserDidFailWithRestoreError:error];	
}
+(JSONParser *) sharedInstance
{
    if (!jsonParser) {
        jsonParser = [[JSONParser alloc]init];
    }
    jsonParser.arrayResponse = [[NSMutableArray alloc]init];
    return jsonParser;
}
@end
