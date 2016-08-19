//
//  ZLoadingView.h
//  ZAccountKit
//
//  Created by Gantulga on 4/13/16.
//  Copyright © 2016 Gantulga. All rights reserved.
//

#define STROKE_ANIMATION @"stroke_animation"
#define ROTATE_ANIMATION @"rotate_animation"

#import "GSLoadingIndicator.h"

typedef NS_ENUM(NSUInteger, PullState) {
	PullStateReady = 0,
	PullStateDragging,
	PullStateRefreshing,
	PullStateFinished
};

@interface GSLoadingIndicator()
{
	dispatch_once_t initConstraits;
	CAShapeLayer *pathLayer;
	CAShapeLayer *arrowLayer;
	UIView *container;
	BOOL isDragging;
	BOOL isFullyPulled;
	PullState pullState;
	NSInteger colorIndex;
}

@end

@implementation GSLoadingIndicator

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSelf];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initSelf];
    }
    return self;
}
- (id)init {
	if (self = [super init]) {
        [self initSelf];
	}
	return self;
}
- (void)initSelf {
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.backgroundColor = [UIColor clearColor];
    
    self.layer.opacity = 0;
    
    self.colors = @[[UIColor blueColor], [UIColor redColor], [UIColor orangeColor], [UIColor greenColor]];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [view addSubview:container];
    
    view.layer.backgroundColor = [UIColor whiteColor].CGColor;
    view.layer.cornerRadius = 20.0;
    
    view.layer.shadowOffset = CGSizeMake(0, .7f);
    view.layer.shadowColor = [[UIColor blackColor] CGColor];
    view.layer.shadowRadius = 1.f;
    view.layer.shadowOpacity = .12f;
    
    pathLayer = [CAShapeLayer layer];
    pathLayer.strokeStart = 0;
    pathLayer.strokeEnd = 10;
    pathLayer.fillColor = nil;
    pathLayer.lineWidth = 2.5;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(20, 20) radius:9 startAngle:0 endAngle:2 * M_PI clockwise:YES];
    pathLayer.path = path.CGPath;
    pathLayer.strokeStart = 1;
    pathLayer.strokeEnd = 1;
    pathLayer.lineCap = kCALineCapSquare;
    
    arrowLayer = [CAShapeLayer layer];
    arrowLayer.strokeStart = 0;
    arrowLayer.strokeEnd = 1;
    arrowLayer.fillColor = nil;
    arrowLayer.lineWidth = 3;
    arrowLayer.strokeColor = [UIColor blueColor].CGColor;
    UIBezierPath *arrow = [GSLoadingIndicator bezierArrowFromPoint:CGPointMake(20, 20) toPoint:CGPointMake(20, 21) width:1];
    arrowLayer.path = arrow.CGPath;
    arrowLayer.transform = CATransform3DMakeTranslation(8.5, 0, 0);
    
    [container.layer addSublayer:pathLayer];
    [container.layer addSublayer:arrowLayer];
    
    [self setAnchorPoint:CGPointMake(0.5, 0.5) forView:container];
    
    [self addSubview:view];
}

- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view{
	CGPoint oldOrigin = view.frame.origin;
	view.layer.anchorPoint = anchorPoint;
	CGPoint newOrigin = view.frame.origin;
	
	CGPoint transition;
	transition.x = newOrigin.x - oldOrigin.x;
	transition.y = newOrigin.y - oldOrigin.y;
	
	view.center = CGPointMake (view.center.x - transition.x, view.center.y - transition.y);
}


- (void)startAnimating {
	float currentAngle = [(NSNumber*)[container.layer valueForKeyPath:@"transform.rotation.z"] floatValue];
	CABasicAnimation *animation = [CABasicAnimation animation];
	animation.keyPath = @"transform.rotation";
	animation.duration = 3.f;
	animation.fromValue = @(currentAngle);
	animation.toValue = @(2 * M_PI + currentAngle);
	animation.removedOnCompletion = NO;
	animation.repeatCount = INFINITY;
	[container.layer addAnimation:animation forKey:ROTATE_ANIMATION];
	
	CABasicAnimation *beginHeadAnimation = [CABasicAnimation animation];
	beginHeadAnimation.keyPath = @"strokeStart";
	beginHeadAnimation.duration = .5f;
	beginHeadAnimation.fromValue = @(.25f);
	beginHeadAnimation.toValue = @(1.f);
	beginHeadAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	
	CABasicAnimation *beginTailAnimation = [CABasicAnimation animation];
	beginTailAnimation.keyPath = @"strokeEnd";
	beginTailAnimation.duration = .5f;
	beginTailAnimation.fromValue = @(1.f);
	beginTailAnimation.toValue = @(1.f);
	beginTailAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	
	CABasicAnimation *endHeadAnimation = [CABasicAnimation animation];
	endHeadAnimation.keyPath = @"strokeStart";
	endHeadAnimation.beginTime = .5f;
	endHeadAnimation.duration = 1.f;
	endHeadAnimation.fromValue = @(.0f);
	endHeadAnimation.toValue = @(.25f);
	endHeadAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	
	CABasicAnimation *endTailAnimation = [CABasicAnimation animation];
	endTailAnimation.keyPath = @"strokeEnd";
	endTailAnimation.beginTime = .5f;
	endTailAnimation.duration = 1.f;
	endTailAnimation.fromValue = @(0.f);
	endTailAnimation.toValue = @(1.f);
	endTailAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	
	CAAnimationGroup *animations = [CAAnimationGroup animation];
	[animations setDuration:1.5f];
	[animations setRemovedOnCompletion:NO];
	[animations setAnimations:@[beginHeadAnimation, beginTailAnimation, endHeadAnimation, endTailAnimation]];
	animations.repeatCount = INFINITY;
	[pathLayer addAnimation:animations forKey:STROKE_ANIMATION];
	
	NSTimer *timer = [NSTimer timerWithTimeInterval:.5 target:self selector:@selector(changeColor) userInfo:nil repeats:NO];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)changeColor {

	[self hideArrow];
	
	if (pullState == PullStateRefreshing) {
		
		colorIndex++;
		if (colorIndex > self.colors.count - 1) {
			colorIndex = 0;
		}
		
		[CATransaction begin];
		[CATransaction setDisableActions:YES];
		pathLayer.strokeColor = ((UIColor*)self.colors[colorIndex]).CGColor;
		[CATransaction commit];
		
		NSTimer *timer = [NSTimer timerWithTimeInterval:1.5 target:self selector:@selector(changeColor) userInfo:nil repeats:NO];
		[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
	}
}

- (void)hideArrow {
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	arrowLayer.opacity = 0;
	[CATransaction commit];
}

- (void)showArrow {
	arrowLayer.opacity = 1;
}

- (void)endAnimating {
	[container.layer removeAnimationForKey:ROTATE_ANIMATION];
	[pathLayer removeAnimationForKey:STROKE_ANIMATION];
}

- (void)showView {
	self.layer.transform = CATransform3DMakeScale(1, 1, 1);
	[self showArrow];
}

- (void)hideView {
	
	[UIView animateWithDuration:.3f animations:^{
		self.layer.opacity = 0;
		self.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1);
		[self layoutIfNeeded];
	} completion:^(BOOL finished) {
		[self endAnimating];
        pullState = PullStateFinished;
		colorIndex = 0;
		pathLayer.strokeColor = ((UIColor*)self.colors[colorIndex]).CGColor;
	}];
}

- (void)startRefreshing {
    if (pullState == PullStateRefreshing) {
        return;
    }
	pullState = PullStateRefreshing;
	self.layer.transform = CATransform3DMakeScale(0, 0, 1);
	[self layoutIfNeeded];

	[UIView animateWithDuration:.6f animations:^{
		self.layer.opacity = 1;
		self.layer.transform = CATransform3DMakeScale(1, 1, 1);
		[self layoutIfNeeded];
		
	} completion:nil];
	
	[self startAnimating];
	[self hideArrow];
}

- (void)endRefreshing {
	[self hideView];
}

+ (UIBezierPath *)bezierArrowFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint width:(CGFloat)width {
	CGFloat length = hypotf(endPoint.x - startPoint.x, endPoint.y - startPoint.y);
	
	CGPoint points[3];
	[self getAxisAlignedArrowPoints:points width:width length:length];
	
	CGAffineTransform transform = [self transformForStartPoint:startPoint endPoint:endPoint length:length];
	
	CGMutablePathRef cgPath = CGPathCreateMutable();
	CGPathAddLines(cgPath, &transform, points, sizeof points / sizeof *points);
	CGPathCloseSubpath(cgPath);
	
	UIBezierPath * bezierPath = [UIBezierPath bezierPathWithCGPath:cgPath];
	CGPathRelease(cgPath);

    return bezierPath;
}

+ (void)getAxisAlignedArrowPoints:(CGPoint[3])points width:(CGFloat)width length:(CGFloat)length {
	points[0] = CGPointMake(0, width);
	points[1] = CGPointMake(length, 0);
	points[2] = CGPointMake(0, -width);
}

+ (CGAffineTransform)transformForStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint length:(CGFloat)length {
	CGFloat cosine = (endPoint.x - startPoint.x) / length;
	CGFloat sine = (endPoint.y - startPoint.y) / length;
	return (CGAffineTransform){ cosine, sine, -sine, cosine, startPoint.x, startPoint.y };
}

@end
