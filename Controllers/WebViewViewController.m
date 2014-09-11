//
//  WebViewViewController.m
//  SDKSandbox
//
//  Created by Mukesh Patil on 09/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import "WebViewViewController.h"
#import "MerchantConstants.h"
#import "CitrusSdk.h"

@interface WebViewViewController ()

@property(nonatomic,strong) UIWebView *webview;

@end

@implementation WebViewViewController
@synthesize redirectURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.webview = [[UIWebView alloc] init];
    self.webview.delegate = self;
    self.webview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.webview.backgroundColor = [UIColor redColor];
    indicator = [[UIActivityIndicatorView alloc]
                 initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(160, 300, 30, 30);
    [self.view addSubview:self.webview];
    [self.webview addSubview:indicator];
    
    
    [self.webview loadRequest:[[NSURLRequest alloc]
                                                initWithURL:[NSURL URLWithString:redirectURL]]];
}


#pragma mark - webview delegates

- (void)webViewDidStartLoad:(UIWebView*)webView {
    [indicator startAnimating];
}

- (BOOL)webView:(UIWebView*)webView
shouldStartLoadWithRequest:(NSURLRequest*)request
 navigationType:(UIWebViewNavigationType)navigationType {
    NSDictionary* responseDict =
    [CTSUtility getResponseIfTransactionIsFinished:request.HTTPBody];
    if (responseDict != nil) {
        [self transactionComplete:responseDict];
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView*)webView {
    [indicator stopAnimating];
}


- (void)transactionComplete:(NSDictionary*)transactionResult {
    LogTrace(@" transactionResult %@ ",
             [transactionResult objectForKey:@"TxStatus"]);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
