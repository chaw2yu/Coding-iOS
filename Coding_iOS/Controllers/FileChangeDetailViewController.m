//
//  FileChangeDetailViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "FileChangeDetailViewController.h"
#import "Coding_NetAPIManager.h"
#import "WebContentManager.h"
#import "CodeViewController.h"


@interface FileChangeDetailViewController ()<UIWebViewDelegate>
@property (strong, nonatomic) UIWebView *webContentView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end


@implementation FileChangeDetailViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = [[self.filePath componentsSeparatedByString:@"/"] lastObject];
    
    {
        //用webView显示内容
        _webContentView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _webContentView.delegate = self;
        _webContentView.backgroundColor = [UIColor clearColor];
        _webContentView.opaque = NO;
        _webContentView.scalesPageToFit = YES;
        [self.view addSubview:_webContentView];
        //webview加载指示
        _activityIndicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:
                              UIActivityIndicatorViewStyleGray];
        _activityIndicator.hidesWhenStopped = YES;
        [_activityIndicator setCenter:CGPointMake(CGRectGetWidth(_webContentView.frame)/2, CGRectGetHeight(_webContentView.frame)/2)];
        [_webContentView addSubview:_activityIndicator];
        [_webContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    NSString *contentStr = [WebContentManager diffPatternedWithContent:self.linkUrlStr];
    [self.webContentView loadHTMLString:contentStr baseURL:nil];
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"查看文件" target:self action:@selector(rightBarButtonClicked:)];
}

- (void)rightBarButtonClicked:(id)item{
    CodeFile *codeFile = [CodeFile codeFileWithRef:_commitId andPath:_filePath];
    CodeViewController *vc = [CodeViewController codeVCWithProject:_curProject andCodeFile:codeFile];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Orientations
- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    DebugLog(@"strLink=[%@]",request.URL.absoluteString);
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [_activityIndicator startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [_activityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    if([error code] == NSURLErrorCancelled)
        return;
    else
        DebugLog(@"%@", error.description);
}
@end
