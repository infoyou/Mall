
#import "CommonWebViewController.h"

@interface CommonWebViewController ()
{
}

@end

@implementation CommonWebViewController
@synthesize strUrl;
@synthesize strTitle;
@synthesize mWebView;

- (id)initWithMOC:(NSManagedObjectContext *)MOC {
    
    self = [super init];
    
    if (self) {
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initWebView];
    
    [self addActivityIndicatorView];
    
}

- (void)initWebView
{
    self.title = self.strTitle;
    
    if (![self.strUrl hasPrefix:@"http://"]) {
        self.strUrl = [NSString stringWithFormat:@"http://%@", self.strUrl];
    }
    
    NSURL *url = [NSURL URLWithString:[self.strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    CGRect mWebFrame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64);
    mWebView = [[UIWebView alloc] initWithFrame:mWebFrame];
    
    mWebView.opaque = NO;
//    mWebView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    mWebView.delegate = self;
    mWebView.scalesPageToFit = YES;
//    mWebView.userInteractionEnabled = NO;
    mWebView.backgroundColor = [UIColor whiteColor];
    [mWebView loadRequest:[[NSURLRequest alloc] initWithURL:url]];
    
    [self.view addSubview:mWebView];
}

- (void)adjustView
{
    mWebView.alpha = 0;
    
    [self.view addSubview:self.noNetWorkView];
}

#pragma mark - UIWebViewController

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
    [self showActivityIndicatorView];
}

- (void)webViewDidFinishLoad: (UIWebView *)webView
{
    
    [self closeActivityIndicatorView];
    
    // 禁用用户选择
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    
    // 禁用长按弹出框
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{

}

@end
