//
//  ViewController.h
//  Example5
//
//  Created by HiddenBrains 001 on 02/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirstViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "SBJSON.h"

@interface ViewController : UIViewController<IGSessionDelegate,UIDocumentInteractionControllerDelegate,JSONParserDelegate>
{
    MBProgressHUD *HUD;
    JSONParser *jsonParser;
    NSInteger serviceNumber;
    BOOL isRecentPost;
    NSString *recentInstagramFeedUrlString;
}

-(UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize;
@property(nonatomic,retain) UIDocumentInteractionController *documentInteractionController;

-(IBAction)instagramButtonPressed:(id)sender;
-(IBAction)postButtonPressed:(id)sender;
-(IBAction)getButtonPressed:(id)sender;

-(void)showAlertMessage:(NSString*)title ofMessage:(NSString *)message;

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate;

@end
