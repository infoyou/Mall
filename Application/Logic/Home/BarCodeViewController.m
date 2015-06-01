//
//  BarCodeViewController.m
//  Aladdin
//
//  Created by Adam on 14-12-17.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import "BarCodeViewController.h"

@interface BarCodeViewController ()

@end

@implementation BarCodeViewController

@synthesize readerView;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"二维码/条码";
    
    ZBarImageScanner *imageScanner = [[ZBarImageScanner alloc] init];
    readerView = [[ZBarReaderView alloc] initWithImageScanner:imageScanner];
    [readerView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [readerView setTracksSymbols:NO];
    readerView.readerDelegate = self;
    [self.view addSubview:readerView];
    
    //扫一扫底图
    UIImageView *bgImgV=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sweep.png"]];
    [self.view addSubview:bgImgV];
    
    
    UIImageView *barScanImgV=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"barScan.png"]];
    [barScanImgV setFrame:CGRectMake(SCREEN_WIDTH/2-110, 100, 219, 11)];
    [self.view addSubview:barScanImgV];
    
    [UIView beginAnimations:@"scanner" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:1.5];
    [UIView setAnimationDelay:0.2];
    [UIView setAnimationRepeatCount:HUGE_VALF];
    [barScanImgV setFrame:CGRectMake(SCREEN_WIDTH/2-110, 329, 219, 11)];
    
    [UIView commitAnimations];
    
    if(TARGET_IPHONE_SIMULATOR) {
        cameraSim = [[ZBarCameraSimulator alloc]
                     initWithViewController: self];
        cameraSim.readerView = readerView;
    }
}

- (void) readerView: (ZBarReaderView*) readerView
     didReadSymbols: (ZBarSymbolSet*) symbols
          fromImage: (UIImage*) image
{
    
    for (ZBarSymbol *sym in symbols) {
        
        NSString *result = sym.data;
        
        if (result && result.length > 0) {
            
            NSLog(@"bar code result = %@", result);
            [self showAlert:result];
        } else {
            [self showAlert:@"无效二维码"];
        }
        
    }
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) orient
{
    return YES;
}

- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) orient
                                 duration: (NSTimeInterval) duration
{
    // compensate for view rotation so camera preview is not rotated
    [readerView willRotateToInterfaceOrientation: orient
                                        duration: duration];
}

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear:animated];
    // run the reader when the view is visible
    [readerView start];
}

- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear:animated];
    [readerView stop];
}

- (void) willMoveToParentViewController:(UIViewController *)parent
{
    [self.navigationController setNavigationBarHidden:NO];
}


@end
