//
//  ViewController.m
//  Example5
//
//  Created by HiddenBrains 001 on 02/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize documentInteractionController;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    jsonParser=[[JSONParser alloc] init];
    [jsonParser setDelegate:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    isRecentPost=NO;
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"INSTAGRAM_POST"] isEqualToString:@"YES"])
    {
        NSLog(@"HERE WE HAVE TO GET THE RECENT FEEDS");
        isRecentPost=YES;
        recentInstagramFeedUrlString=@"";
        HUD=[MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
        HUD.labelText = @"Please wait";
        [HUD show:YES];
        [self performSelector:@selector(getRecentInstagramFeeds) withObject:nil afterDelay:0.1];
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"INSTAGRAM_POST"];
    }        
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

#pragma Mark - IBAction Methods

-(IBAction)instagramButtonPressed:(id)sender
{
    HUD=[MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
    HUD.labelText = @"Please wait";
    [HUD show:YES];
    AppDelegate *appDelegate =(AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.instagram.accessToken=[[NSUserDefaults standardUserDefaults] objectForKey:@"INSTAGRAM_ACCESS_TOKEN"];
    NSLog(@"%@",appDelegate.instagram.accessToken);
    [appDelegate.instagram setSessionDelegate:self];
    if(![appDelegate.instagram isSessionValid])
        [appDelegate.instagram authorize:nil];
    else
    {
        [HUD setHidden:YES];
        [self showAlertMessage:@"INSTAGRAM" ofMessage:@"Instagram already authorized"];
    }
}

-(IBAction)postButtonPressed:(id)sender
{
    HUD=[MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
    HUD.labelText = @"Please wait";
    [HUD show:YES];
    
    [self performSelector:@selector(postImageInInstagram) withObject:nil afterDelay:0.1];
}

-(void)postImageInInstagram
{
    AppDelegate *appDelegate =(AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.instagram.accessToken=[[NSUserDefaults standardUserDefaults] objectForKey:@"INSTAGRAM_ACCESS_TOKEN"];
    if([appDelegate.instagram isSessionValid])
    {
        NSFileManager *fileManager=[NSFileManager defaultManager];
        NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3629/3339128908_7aecabc34b_b.jpg"]];
        UIImage *image=[self scaleImage:[UIImage imageWithData:data] toSize:CGSizeMake(700, 700)];
        
        NSString *filePath=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/test.jpg"];
        if([fileManager fileExistsAtPath:filePath isDirectory:NO])
            [fileManager removeItemAtPath:filePath error:nil];
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:filePath atomically:YES];
        
        filePath=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/test.igo"];
        if([fileManager fileExistsAtPath:filePath isDirectory:NO])
            [fileManager removeItemAtPath:filePath error:nil];
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:filePath atomically:YES];
        
        NSURL *igImageHookFileUrl=[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"file://%@",filePath]];
        self.documentInteractionController.UTI=@"com.instagram.photo";
        self.documentInteractionController.annotation = [NSDictionary dictionaryWithObject:@"INSTAGRAM FROM IPHONE" forKey:@"InstagramCaption"];
        self.documentInteractionController=[self setupControllerWithURL:igImageHookFileUrl usingDelegate:self];
        self.documentInteractionController=[UIDocumentInteractionController interactionControllerWithURL:igImageHookFileUrl];
        if(![self.documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES])
        {
            [HUD setHidden:YES];
            [self showAlertMessage:@"Message" ofMessage:@"Please download instagram to post"];
        }
        else
        {
            [HUD setHidden:YES];
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"INSTAGRAM_POST"];
        }
    }
    else
    {
        [HUD setHidden:YES];
        [self showAlertMessage:@"INSTAGRAM" ofMessage:@"Authorize first"];
    }
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate 
{
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
}

-(IBAction)getButtonPressed:(id)sender
{
    if(isRecentPost)
    {
        recentInstagramFeedUrlString=@"";
        HUD=[MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
        HUD.labelText = @"Please wait";
        [HUD show:YES];
        [self performSelector:@selector(getRecentInstagramFeeds) withObject:nil afterDelay:0.1];
    }
    else
        [self showAlertMessage:@"INSTAGRAM" ofMessage:@"You are not posted yet"];
}

#pragma Mark - IGSessionDelegate Methods

-(void)igDidLogin 
{
    AppDelegate *appDelegate =(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[NSUserDefaults standardUserDefaults] setObject:appDelegate.instagram.accessToken forKey:@"INSTAGRAM_ACCESS_TOKEN"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    if([appDelegate.instagram isSessionValid])
    {
        serviceNumber=1;
        NSString *strURL=[NSString stringWithFormat:@"%@users/self?access_token=%@",INSTGRAM_BASE_URL,appDelegate.instagram.accessToken];
        [jsonParser setRequestMethod:@"GET"];
        [jsonParser getArrayFromUrl:strURL];
    }
    else
    {
        [HUD setHidden:YES];
        [self showAlertMessage:@"INSTAGRAM" ofMessage:@"Session invalid"];
    }
}

-(void)igDidNotLogin:(BOOL)cancelled 
{
    NSLog(@"Instagram did not login");
    NSString* message = nil;
    if (cancelled) {
        message = @"Access cancelled!";
    } else {
        message = @"Access denied!";
    }
    [self showAlertMessage:@"Error" ofMessage:message];
    [HUD hide:YES];
}

-(void)igDidLogout 
{
    NSLog(@"Instagram did logout");
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"accessToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)igSessionInvalidated 
{
    NSLog(@"Instagram session was invalidated");
}

#pragma mark - Instance methods

-(void)getRecentInstagramFeeds
{
    AppDelegate *appDelegate =(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[NSUserDefaults standardUserDefaults] setObject:appDelegate.instagram.accessToken forKey:@"INSTAGRAM_ACCESS_TOKEN"];
    if([appDelegate.instagram isSessionValid])
    {
        serviceNumber=2;
        NSString *strURL=[NSString stringWithFormat:@"%@users/self/media/recent?access_token=%@",INSTGRAM_BASE_URL,appDelegate.instagram.accessToken];
        [jsonParser setRequestMethod:@"GET"];
        [jsonParser getArrayFromUrl:strURL];
    }
    else
    {
        [HUD setHidden:YES];
        [self showAlertMessage:@"INSTAGRAM" ofMessage:@"Session invalid"];
    }
}

-(UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize
{  
    double width=newSize.width;
    double height=newSize.height;
    
    if(image.size.width<newSize.width)
        width=image.size.width;
    if(image.size.height<newSize.height)
        height=image.size.height;
    
    newSize=CGSizeMake(width, height);
    
    UIGraphicsBeginImageContext(newSize);  
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];  
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();  
    UIGraphicsEndImageContext();    
    return newImage;  
}

-(void)showAlertMessage:(NSString*)title ofMessage:(NSString *)message
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - JSONParser Delegate Methods

-(void)parserDidFinishLoadingReturnData:(NSMutableArray *)responseArray
{
    [HUD hide:YES];
    
    NSString *responseString=[NSString stringWithFormat:@"[%@]",jsonParser.responseString];
    SBJSON *json = [SBJSON new];
    NSArray *resultArray= [[NSArray alloc] initWithArray:[json objectWithString:responseString error:nil]];
    
    if(resultArray!=nil && [resultArray count]!=0)
    {
        NSDictionary *dict=[[resultArray objectAtIndex:0] objectForKey:@"meta"];
        if([[dict objectForKey:@"code"] intValue]==200)//success;
        {
            if(serviceNumber==1)//AFTER LOGIN
            {
                NSDictionary *dict=[[resultArray objectAtIndex:0] objectForKey:@"data"];
                [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"id"] forKey:@"INSTAGRAM_USER_ID"];
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"PREVIOUS_POST_TIME"];
                [self showAlertMessage:@"INSTAGRAM" ofMessage:@"Instagram authorized successfully"];
            }
            else//serviceNumber=2;
            {
                NSArray *array=[[resultArray objectAtIndex:0] objectForKey:@"data"];
                if(array!=nil && [array count]!=0)
                {
                    NSDictionary *recentPostDict=[array objectAtIndex:0];
                    NSDictionary *dict1=[recentPostDict objectForKey:@"caption"];
                    
                    NSLog(@"==============================");
                    NSLog(@"POSTED LINK: %@",[recentPostDict objectForKey:@"link"]);
                    NSLog(@"CREATED TIME: %@",[dict1 objectForKey:@"created_time"]);
                    NSLog(@"POST USER NAME: %@",[[dict1 objectForKey:@"from"] objectForKey:@"username"]);
                    NSLog(@"POST USER ID: %@",[[dict1 objectForKey:@"from"] objectForKey:@"id"]);                    
                    NSLog(@"POST TITLE: %@",[dict1 objectForKey:@"text"]);
                    NSLog(@"==============================");
                    
                    NSString *previousPostTime=[[NSUserDefaults standardUserDefaults] objectForKey:@"PREVIOUS_POST_TIME"];
                    if([previousPostTime isEqualToString:@"0"] || ![previousPostTime isEqualToString:[dict1 objectForKey:@"created_time"]])
                    {
                        NSLog(@"RECENT POST");
                        [[NSUserDefaults standardUserDefaults] setObject:[dict1 objectForKey:@"created_time"] forKey:@"PREVIOUS_POST_TIME"];
                    }
                    else
                    {                        
                        NSLog(@"PREVIOUS POST");
                    }
                    
                    recentInstagramFeedUrlString=[recentPostDict objectForKey:@"link"];
                    NSURL *url=[NSURL URLWithString:recentInstagramFeedUrlString];
                    if([[UIApplication sharedApplication] canOpenURL:url])
                        [[UIApplication sharedApplication] openURL:url];
                    else
                        [self showAlertMessage:@"INSTAGRAM" ofMessage:@"Unable to open Feed"]; 
                }
                else
                    [self showAlertMessage:@"INSTAGRAM" ofMessage:NO_DATA_FOUND];
            }
        }
        else
            [self showAlertMessage:@"INSTAGRAM" ofMessage:NO_DATA_FOUND];
    }
    else
        [self showAlertMessage:@"INSTAGRAM" ofMessage:NO_DATA_FOUND];
}

-(void)parserDidFailWithRestoreError:(NSError *)error
{
    [HUD hide:YES];
    [self showAlertMessage:@"ERROR" ofMessage:ERROR_MESSAGE];
}

@end

