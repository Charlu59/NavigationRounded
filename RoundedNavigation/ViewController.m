//
//  ViewController.m
//  RoundedNavigation
//
//  Created by Charles-Hubert Basuiau on 24/01/2016.
//  Copyright © 2016 Appiway. All rights reserved.
//

#import "ViewController.h"

#define SCREEN_WIDTH    self.view.frame.size.width
#define SCREEN_HEIGHT   self.view.frame.size.height

#define COLOR_APP_YELLOW    [UIColor colorWithRed: 255.0/255.0 green: 195.0/255.0 blue:   0.0/255.0 alpha: 1.0]
#define COLOR_APP_BLUE      [UIColor colorWithRed:  50.0/255.0 green: 208.0/255.0 blue: 245.0/255.0 alpha: 1.0]
#define COLOR_APP_GREEN     [UIColor colorWithRed:  80.0/255.0 green: 227.0/255.0 blue: 194.0/255.0 alpha: 1.0]
#define COLOR_APP_RED       [UIColor colorWithRed: 255.0/255.0 green:  99.0/255.0 blue: 102.0/255.0 alpha: 1.0]
#define COLOR_APP_PURPLE    [UIColor colorWithRed: 166.0/255.0 green: 120.0/255.0 blue: 250.0/255.0 alpha: 1.0]

@interface ViewController () <UIScrollViewDelegate> {
    UIScrollView *contentScrollview;
    UIView *bg;
    UIView *transitionViewRight;
    UIView *transitionViewLeft;
    
    NSInteger contentState;
    NSArray *screensColors;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    contentState = 0;
    screensColors = @[COLOR_APP_YELLOW, COLOR_APP_BLUE, COLOR_APP_PURPLE, COLOR_APP_GREEN];
    
    bg = [[UIView alloc] initWithFrame:CGRectMake(-SCREEN_WIDTH, 0, 3*SCREEN_WIDTH, SCREEN_HEIGHT)];
    [bg setBackgroundColor:COLOR_APP_YELLOW];
    [self.view addSubview:bg];
    
    transitionViewRight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*1.9, SCREEN_WIDTH*1.9)];
    [transitionViewRight setCenter:CGPointMake(SCREEN_WIDTH*2.0, SCREEN_HEIGHT/2.0)];
    [transitionViewRight setBackgroundColor:COLOR_APP_BLUE];
    transitionViewRight.layer.cornerRadius = SCREEN_WIDTH;
    [self.view addSubview:transitionViewRight];
    
    transitionViewLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*1.9, SCREEN_WIDTH*1.9)];
    [transitionViewLeft setCenter:CGPointMake(-SCREEN_WIDTH, SCREEN_HEIGHT/2.0)];
    [transitionViewLeft setBackgroundColor:COLOR_APP_YELLOW];
    transitionViewLeft.layer.cornerRadius = SCREEN_WIDTH;
    [self.view addSubview:transitionViewLeft];
    
    contentScrollview = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    contentScrollview.delegate = self;
    contentScrollview.pagingEnabled = YES;
    [contentScrollview setContentSize:CGSizeMake(SCREEN_WIDTH*[screensColors count], SCREEN_HEIGHT)];
    [self.view addSubview:contentScrollview];
}


-(void)focusOnNewContentState {
    [self resetTransitionViewRight];
    [self resetTransitionViewLeft];
    
    [bg setBackgroundColor:screensColors[contentState]];
    [transitionViewRight setBackgroundColor:screensColors[MIN(contentState+1,[screensColors count]-1)]];
    [transitionViewLeft setBackgroundColor:screensColors[MAX(contentState-1, 0)]];
}

-(void)resetTransitionViewRight {
    [transitionViewRight setBounds:CGRectMake(0, 0, 2*SCREEN_WIDTH, 2*SCREEN_WIDTH)];
    transitionViewRight.layer.cornerRadius = SCREEN_WIDTH;
    [transitionViewRight setCenter:CGPointMake(2*SCREEN_WIDTH, SCREEN_HEIGHT/2.0)];
}

-(void)resetTransitionViewLeft {
    [transitionViewLeft setBounds:CGRectMake(0, 0, 2*SCREEN_WIDTH, 2*SCREEN_WIDTH)];
    transitionViewLeft.layer.cornerRadius = SCREEN_WIDTH;
    [transitionViewLeft setCenter:CGPointMake(-SCREEN_WIDTH, SCREEN_HEIGHT/2.0)];
}

#pragma UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
        CGFloat Rzoom = (scrollView.contentOffset.x-contentState*SCREEN_WIDTH)/(100.0);
        if (Rzoom>0) {
            
            //Force focus when user scroll to fast to the right
            if ((scrollView.contentOffset.x-contentState*SCREEN_WIDTH) > SCREEN_WIDTH) {
                contentState ++;
                Rzoom = (scrollView.contentOffset.x-contentState*SCREEN_WIDTH)/(100.0);
                [self focusOnNewContentState];
            }
            
            //Reset other side to avoid user to see 2 circles if he wiggle/shake
            [self resetTransitionViewLeft];
            
            //Anim the good side for the trnsition
            [transitionViewRight setBounds:CGRectMake(0, 0, 2*SCREEN_WIDTH*(1+Rzoom), 2*SCREEN_WIDTH*(1+Rzoom))];
            transitionViewRight.layer.cornerRadius = SCREEN_WIDTH*(1+Rzoom);
            [transitionViewRight setCenter:CGPointMake(2*SCREEN_WIDTH*(1+Rzoom*0.3), SCREEN_HEIGHT/2.0)];
            
        } else {
            
            //Force focus when user scroll to fast to the left
            if ((scrollView.contentOffset.x-contentState*SCREEN_WIDTH) < -SCREEN_WIDTH) {
                contentState --;
                Rzoom = (scrollView.contentOffset.x-contentState*SCREEN_WIDTH)/(100.0);
                [self focusOnNewContentState];
            }
            
            //Reset other side to avoid user to see 2 circles if he wiggle/shake
            [self resetTransitionViewRight];
            
            //Anim the good side for the trnsition
            Rzoom = -Rzoom;
            [transitionViewLeft setBounds:CGRectMake(0, 0, 2*SCREEN_WIDTH*(1+Rzoom), 2*SCREEN_WIDTH*(1+Rzoom))];
            transitionViewLeft.layer.cornerRadius = SCREEN_WIDTH*(1+Rzoom);
            [transitionViewLeft setCenter:CGPointMake(-SCREEN_WIDTH*(1+Rzoom*0.3), SCREEN_HEIGHT/2.0)];
        }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate) [self endOfScroll:scrollView];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self endOfScroll:scrollView];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self endOfScroll:scrollView];
}

-(void)endOfScroll:(UIScrollView *)scrollView {
    if (scrollView == contentScrollview) {
        contentState = (scrollView.contentOffset.x+SCREEN_WIDTH/2.0)/SCREEN_WIDTH;
        [self focusOnNewContentState];
    }
}



@end
