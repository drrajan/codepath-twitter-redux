//
//  MasterViewController.m
//  codepath-twitter
//
//  Created by David Rajan on 2/24/15.
//  Copyright (c) 2015 David Rajan. All rights reserved.
//

#import "MasterViewController.h"
#import <objc/runtime.h>

@interface MasterViewController ()

@property (nonatomic, strong) UIView *masterContentView;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, assign) BOOL menuOpen;

@end

@implementation MasterViewController

CGFloat const scaleFactor = 0.7f;
static CGFloat const edgeTranslate = 20.0f;
static NSTimeInterval const animateDuration = 1;
static NSTimeInterval const animateDelay = 0.2;
static NSTimeInterval const animateCloseDuration = 0.3;
static NSTimeInterval const animateSwitchDuration = 0.3;

CGPoint mainOriginalCenter;
CGPoint mainClosedCenter;
CGRect mainOriginalFrame;
CGRect menuOriginalFrame;
CGAffineTransform mainOpenTransform;
CGAffineTransform newTransform;
CGAffineTransform menuClosedTransform;
CGFloat translateMax;
CGFloat currScale;

- (id)initWithMainViewController:(UIViewController *)mainViewController menuViewController:(UIViewController *)menuViewController {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _mainViewController = mainViewController;
        _menuViewController = menuViewController;
        
        [self addViewController:self.menuViewController];
        [self addViewController:self.mainViewController];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:85/255.0 green:172/255.0 blue:238/255.0 alpha:1];
    
    [self addChildViewController:self.mainViewController];
    self.masterContentView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.masterContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.mainViewController.view.frame = self.masterContentView.bounds;
    [self.masterContentView addSubview:self.mainViewController.view];
    [self.view addSubview:self.masterContentView];
    [self.mainViewController didMoveToParentViewController:self];
    
    [self addChildViewController:self.menuViewController];
    [self.view insertSubview:self.menuViewController.view belowSubview:self.masterContentView];
    [self.menuViewController didMoveToParentViewController:self];
    
    mainOpenTransform = [self openTransformForView:self.masterContentView];
    menuClosedTransform = [self transformForClosedMenu];
    mainOriginalCenter = self.mainViewController.view.center;
//    menuOriginalCenter = self.menuViewController.view.center;
    menuOriginalFrame = self.menuViewController.view.frame;
    translateMax = CGRectGetMidX(self.masterContentView.bounds) + edgeTranslate;
    [self updateMenuViewWithTransform:menuClosedTransform];
    
    self.view.userInteractionEnabled = YES;
    self.masterContentView.userInteractionEnabled = YES;
    self.mainViewController.view.userInteractionEnabled = YES;
    self.menuViewController.view.userInteractionEnabled = YES;

    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleSwipe:(id)sender {
    [self toggleMenuAnimated:YES completion:nil];
}

- (void)handlePan:(UIPanGestureRecognizer *)panGesture {
    CGPoint translation = [panGesture translationInView:panGesture.view];
    CGPoint velocity = [panGesture velocityInView:panGesture.view];

    if (panGesture.state == UIGestureRecognizerStateBegan) {

    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        
        CGFloat scale = 1;
        CGFloat currCenter = mainOriginalCenter.x;
        if (self.menuOpen) {
            currCenter = self.view.frame.size.width;
            scale = self.masterContentView.transform.a;
        }
        
        self.masterContentView.center = CGPointMake(currCenter + translation.x, panGesture.view.center.y);
        self.masterContentView.transform = CGAffineTransformMakeScale(scale - (translation.x / 650), scale - (translation.x / 650));
        
    } else if (panGesture.state == UIGestureRecognizerStateEnded) {
        CGAffineTransform tmp;
        if (self.menuOpen) {
            tmp = CGAffineTransformInvert(menuClosedTransform);
        } else {
            tmp = CGAffineTransformInvert(mainOpenTransform);
        }

        if ((self.menuOpen && velocity.x < 0) || (!self.menuOpen && velocity.x > 0)) {
            newTransform = CGAffineTransformMake(tmp.a - panGesture.view.transform.a, tmp.b - panGesture.view.transform.b,
                                                 tmp.c - panGesture.view.transform.c, tmp.d - panGesture.view.transform.d,
                                                 mainOpenTransform.tx - translation.x, 0);
            [self toggleMenuAnimated:YES completion:nil];
        }
    }
}


- (void)updateMenuViewWithTransform:(CGAffineTransform)transform {
    self.menuViewController.view.transform = transform;
    self.menuViewController.view.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    self.menuViewController.view.bounds = self.view.bounds;
}

-(CGAffineTransform)transformForClosedMenu {
    CGFloat transformValue = 1.0f / scaleFactor;
    CGAffineTransform transformScale = CGAffineTransformScale(self.menuViewController.view.transform, transformValue, transformValue);
    return CGAffineTransformTranslate(transformScale, -(CGRectGetMidX(self.view.bounds)) - edgeTranslate, 0);
}

- (CGAffineTransform)openTransformForView:(UIView *)view
{
    CGFloat transformSize = scaleFactor;
    CGAffineTransform transformTranslate = CGAffineTransformTranslate(view.transform, CGRectGetMidX(view.bounds) + edgeTranslate, 0);
    return CGAffineTransformScale(transformTranslate, transformSize, transformSize);
}

- (void)openMenuAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    if (self.menuOpen) {
        return;
    }

    self.menuOpen = YES;
    self.menuViewController.view.transform = [self transformForClosedMenu];
    
    [UIView animateWithDuration:animateDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.menuViewController.view.transform = CGAffineTransformIdentity;
                         self.masterContentView.transform = newTransform;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             mainClosedCenter = self.masterContentView.center;
                             [self addOverlayButtonToMainViewController];
                         }
                     }
     ];
}

- (void)closeMenuAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    if (!self.menuOpen) {
        return;
    }
    
    self.menuOpen = NO;
    
    [self removeOverlayButtonFromMainViewController];
    self.masterContentView.center = mainOriginalCenter;
    
    
    [UIView animateWithDuration:animateDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.menuViewController.view.transform = newTransform;
                         self.masterContentView.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {
                         self.menuViewController.view.transform = CGAffineTransformIdentity;
                     }
     ];
}

- (void)toggleMenuAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    if (self.menuOpen) {
        [self closeMenuAnimated:animated completion:completion];
    } else {
        [self openMenuAnimated:animated completion:completion];
    }
}

- (void)addOverlayButtonToMainViewController {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.opaque = NO;
    button.frame = self.masterContentView.frame;
    
    [button addTarget:self action:@selector(closeButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(closeButtonTouchedDown) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(closeButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    
    [self.view addSubview:button];
    self.closeButton = button;
}

- (void)removeOverlayButtonFromMainViewController {
    [self.closeButton removeFromSuperview];
}

- (void)closeButtonTouchUpInside {
    [self closeMenuAnimated:YES completion:nil];
}

- (void)closeButtonTouchedDown {
    self.closeButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
}

- (void)closeButtonTouchUpOutside {
    self.closeButton.backgroundColor = [UIColor clearColor];
}

- (void)setMainViewController:(UIViewController *)mainViewController animated:(BOOL)animated closeMenu:(BOOL)closeMenu {
    UIViewController *from = self.mainViewController;
    UIViewController *to = mainViewController;
    
    UIView *overlayView = [[UIView alloc] initWithFrame:from.view.frame];
    overlayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8f];
    [self.masterContentView addSubview:overlayView];
    
    NSTimeInterval changeTimeInterval = animateSwitchDuration;
    NSTimeInterval delayInterval = animateDelay;
    if (!self.menuOpen) {
        changeTimeInterval = animateCloseDuration;
        delayInterval = 0.0;
    }
    
    [self addViewController:to];
    [self.masterContentView addSubview:to.view];
    
    to.view.frame = self.masterContentView.bounds;
    
    to.view.alpha = 0.6f;
    UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseOut;
    
    if (closeMenu) {
        [self closeMenuAnimated:animated completion:nil];
    }
    
    [UIView animateWithDuration:changeTimeInterval
                          delay:delayInterval
                        options:options
                     animations:^{
                         to.view.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         [to didMoveToParentViewController:self];
                         
                         [from removeFromParentViewController];
                         [from.view removeFromSuperview];
                         [from didMoveToParentViewController:nil];
                         [overlayView removeFromSuperview];
                         [self.closeButton removeFromSuperview];
                         self.menuOpen = NO;
                     }];
    
    self.mainViewController = mainViewController;
    self.mainViewController.masterViewController = self;
}

- (void)addViewController:(UIViewController *)viewController {
    viewController.masterViewController = self;
    [self addChildViewController:viewController];
    [viewController didMoveToParentViewController:self];
}


@end

@implementation UIViewController (MasterViewController)

- (void)setMasterViewController:(MasterViewController *)masterViewController {
    objc_setAssociatedObject(self, @selector(masterViewController), masterViewController, OBJC_ASSOCIATION_ASSIGN);
}

- (MasterViewController *)masterViewController {
    MasterViewController *masterViewController = objc_getAssociatedObject(self, @selector(masterViewController));
    if (!masterViewController) {
        masterViewController = self.parentViewController.masterViewController;
    }
    return masterViewController;
}


@end
