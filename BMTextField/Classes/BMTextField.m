//
//  BMTextField.m
//  TextField
//
//  Created by BirdMichael on 2019/4/25.
//  Copyright © 2019 Mac. All rights reserved.
//

#import "BMTextField.h"

static NSString * const kBMAnimationLineViewAnimationWidth = @"kBMAnimationLineViewAnimationWidth";
static NSString * const kBMAnimationLineViewAnimationOpacity = @"kBMAnimationLineViewAnimationOpacity";
static NSString * const kBMLineViewAnimationOpacity = @"kBMLineViewAnimationOpacity";
static NSString * const kBMPlaceholderCacheLabelAnimationIn = @"kBMPlaceholderCacheLabelAnimationIN";
static NSString * const kBMPlaceholderCacheLabelAnimationOut = @"kBMPlaceholderCacheLabelAnimationOut";

@interface BMTextField() <CAAnimationDelegate>

@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *animationLineView;
@property (nonatomic, strong) NSAttributedString *cachedPlaceholder;
@property (nonatomic, strong) UILabel *placeholderCacheLabel;
@property (nonatomic, strong) UILabel *errorLabel;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) CAShapeLayer *leftLayer;
@property (nonatomic, assign) CGFloat ds;
@end

@implementation BMTextField

#pragma mark - Lifecycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaultValue];
        [self addNotification];
        [self addSubView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setupSubViewFrame];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - PrivateMethods

- (void)setDefaultValue {
    self.scale = 0.7;
    self.titlePoint = CGPointMake(0, 15);
    self.borderStyle = UITextBorderStyleNone;
    self.backgroundColor = [UIColor clearColor];
    self.lineSelectedColor = [UIColor blackColor];
    self.defaultTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:13],NSForegroundColorAttributeName:[UIColor colorWithRed:33.0/255.0 green:33.0/255.0 blue:33.0/255.0 alpha:1.0]};
}
- (void)addSubView {
    [self addSubview:self.lineView];
    [self addSubview:self.animationLineView];
    [self addSubview:self.errorLabel];
}
- (void)setupSubViewFrame {
    self.lineView.frame = CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1);
    self.animationLineView.frame = CGRectMake(0, self.frame.size.height - 1, 0, 1);
    self.placeholderCacheLabel.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [self.errorLabel sizeToFit];
    self.errorLabel.frame = CGRectMake(self.errorLabelPoint.x, self.frame.size.height - self.errorLabel.frame.size.height - self.errorLabelPoint.y, self.errorLabel.frame.size.width,self.errorLabel.frame.size.height);
}

- (void)addAnimationLineViewAnimation {
    if (!self.errorLabel.hidden) {
        return;
    }
    self.animationLineView.backgroundColor = self.lineSelectedColor;
    CAKeyframeAnimation *kfAnimationLine = [CAKeyframeAnimation animationWithKeyPath:@"bounds.size.width"];
    kfAnimationLine.fillMode = kCAFillModeForwards;
    kfAnimationLine.removedOnCompletion = NO;
    kfAnimationLine.values = @[@0,@(self.bounds.size.width)];
    kfAnimationLine.duration = 0.25f;
    kfAnimationLine.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.animationLineView.layer addAnimation:kfAnimationLine forKey:kBMAnimationLineViewAnimationWidth];
}
- (void)removeAnimationLineViewAnimation {
    CAKeyframeAnimation *kfAnimation1 = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    kfAnimation1.fillMode = kCAFillModeForwards;
    kfAnimation1.removedOnCompletion = NO;
    kfAnimation1.values = @[@1,@0];
    kfAnimation1.duration = 0.25f;
    kfAnimation1.delegate = self;
    [self.animationLineView.layer addAnimation:kfAnimation1 forKey:kBMAnimationLineViewAnimationOpacity];
    
    CAKeyframeAnimation *kfAnimation2 = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    kfAnimation2.fillMode = kCAFillModeForwards;
    kfAnimation2.removedOnCompletion = NO;
    kfAnimation2.values = @[@0,@1];
    kfAnimation2.duration = 0.25f;
    kfAnimation2.delegate = self;
    [self.lineView.layer addAnimation:kfAnimation2 forKey:kBMLineViewAnimationOpacity];
}

- (void)addPlaceholderAnimation {
    if (!_cachedPlaceholder) {
        [self addSubview:self.placeholderCacheLabel];
        self.placeholderCacheLabel.attributedText = self.attributedPlaceholder;
        
        self.cachedPlaceholder = self.attributedPlaceholder;
    }
    self.placeholder = nil;
    _placeholderCacheLabel.hidden = NO;
    CAKeyframeAnimation *kfAnimation1 = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    kfAnimation1.fillMode = kCAFillModeForwards;
    kfAnimation1.removedOnCompletion = NO;
    CATransform3D scale1 = CATransform3DMakeScale(1.0, 1.0, 1);
    CATransform3D scale2 = CATransform3DMakeScale(1.1, 1.1, 1);
    CATransform3D scale3 = CATransform3DMakeScale(self.scale, self.scale, 1);
    kfAnimation1.values = @[[NSValue valueWithCATransform3D:scale1],
                            [NSValue valueWithCATransform3D:scale2],
                            [NSValue valueWithCATransform3D:scale3]];
    
    CAKeyframeAnimation *kfAnimation2 = [CAKeyframeAnimation animationWithKeyPath:@"bounds.origin"];
    kfAnimation2.fillMode = kCAFillModeForwards;
    kfAnimation2.removedOnCompletion = NO;
    kfAnimation2.values = @[[NSValue valueWithCGPoint:CGPointMake(0, 0)],[NSValue valueWithCGPoint:CGPointMake(self.titlePoint.x, self.titlePoint.y)]];
    
    CAAnimationGroup *grouoAnimation = [CAAnimationGroup animation];
    grouoAnimation.animations = @[kfAnimation1,kfAnimation2];
    grouoAnimation.fillMode = kCAFillModeForwards;
    grouoAnimation.removedOnCompletion = NO;
    grouoAnimation.duration = 0.25;
    grouoAnimation.delegate = self;
    [_placeholderCacheLabel.layer addAnimation:grouoAnimation forKey:kBMPlaceholderCacheLabelAnimationIn];
}

- (void)removePlaceholderAnimation {
    CAKeyframeAnimation *kfAnimation1 = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    kfAnimation1.fillMode = kCAFillModeForwards;
    kfAnimation1.removedOnCompletion = NO;
    CATransform3D scale1 = CATransform3DMakeScale(0.9, 0.9, 1);
    CATransform3D scale2 = CATransform3DMakeScale(1.1, 1.1, 1);
    CATransform3D scale3 = CATransform3DMakeScale(1.0, 1.0, 1);
    kfAnimation1.values = @[[NSValue valueWithCATransform3D:scale1],
                            [NSValue valueWithCATransform3D:scale2],
                            [NSValue valueWithCATransform3D:scale3]];
    
    CAKeyframeAnimation *kfAnimation2 = [CAKeyframeAnimation animationWithKeyPath:@"bounds.origin"];
    kfAnimation2.fillMode = kCAFillModeForwards;
    kfAnimation2.removedOnCompletion = NO;
    kfAnimation2.values = @[[NSValue valueWithCGPoint:CGPointMake(0, 22)],[NSValue valueWithCGPoint:CGPointMake(0, 0)]];
    
    CAAnimationGroup *grouoAnimation = [CAAnimationGroup animation];
    grouoAnimation.animations = @[kfAnimation1,kfAnimation2];
    grouoAnimation.fillMode = kCAFillModeForwards;
    grouoAnimation.removedOnCompletion = NO;
    grouoAnimation.duration = 0.25;
    grouoAnimation.delegate = self;
    [_placeholderCacheLabel.layer addAnimation:grouoAnimation forKey:kBMPlaceholderCacheLabelAnimationOut];
}

- (void)addErrorAnimation {
    self.animationLineView.backgroundColor = [UIColor redColor];
    self.errorLabel.hidden = NO;
    [self.errorLabel sizeToFit];
    CGRect frame = self.animationLineView.frame;
    frame.size.width = self.frame.size.width;
    self.animationLineView.frame = frame;
    CALayer *viewLayer = self.animationLineView.layer;
    CGPoint position = viewLayer.position;
    CGPoint x = CGPointMake(position.x + 10, position.y);
    CGPoint y = CGPointMake(position.x - 10, position.y);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [animation setFromValue:[NSValue valueWithCGPoint:x]];
    [animation setToValue:[NSValue valueWithCGPoint:y]];
    [animation setAutoreverses:YES];
    [animation setDuration:.06];
    [animation setRepeatCount:3];
    [viewLayer addAnimation:animation forKey:nil];
}

// 动画绘制相关
- (void)starDrawCircleBorder {
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    // 启动同步渲染绘制波纹
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(setCircleBorder:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    CAShapeLayer *leftLayer = [CAShapeLayer layer];
    self.leftLayer = leftLayer;
    self.ds = 0;
    [self.animationLineView.layer addSublayer:leftLayer];
}

- (void)setCircleBorder:(CADisplayLink *)displayLink {
    self.ds += 0.1;
    UIColor *color = [UIColor redColor];
    [color set];
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.animationLineView.frame.origin radius:self.ds startAngle:0 endAngle:3.1415926 *3/2 clockwise:YES];
    path.lineWidth = 2;
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    [path stroke];
    self.leftLayer.path = path.CGPath;
}

#pragma mark - NSNotification And Methods
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bm_textFieldDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bm_textFieldDidEndEditing:) name:UITextFieldTextDidEndEditingNotification object:self];
}

- (void)bm_textFieldDidBeginEditing:(NSNotification *)notification {
    [self addAnimationLineViewAnimation];
    
    if (!self.text || [self.text isEqualToString:@""]) {
        [self addPlaceholderAnimation];
    }
}

- (void)bm_textFieldDidEndEditing:(NSNotification *)notification {
    if (!self.text || [self.text isEqualToString:@""]) {
        [self removePlaceholderAnimation];
    }
    if (self.verifyText && !self.verifyText(self.text,self.errorLabel)) {
        [self addErrorAnimation];
    } else {
        self.errorLabel.hidden = YES;
        [self removeAnimationLineViewAnimation];
    }
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (!flag) {
        return;
    }
    if (anim == [self.placeholderCacheLabel.layer animationForKey:kBMPlaceholderCacheLabelAnimationOut]) {
        _placeholderCacheLabel.hidden = YES;
        self.attributedPlaceholder = self.cachedPlaceholder;
    } else if ([self.animationLineView.layer animationForKey:kBMAnimationLineViewAnimationOpacity]) {
        CGRect frame = self.animationLineView.frame;
        frame.size.width = 0;
        self.animationLineView.frame = frame;
        self.animationLineView.alpha = 1;
        self.lineView.alpha = 0;
        [self.animationLineView.layer removeAllAnimations];
    } else if ([self.animationLineView.layer animationForKey:kBMAnimationLineViewAnimationWidth]){
        [self starDrawCircleBorder];
    }
}

#pragma mark - Setter And Getter
- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    }
    return _lineView;
}

- (UIView *)animationLineView {
    if (!_animationLineView) {
        _animationLineView = [UIView new];
        _animationLineView.layer.anchorPoint = CGPointMake(0, 0.5);
        _animationLineView.backgroundColor = [UIColor redColor];
    }
    return _animationLineView;
}
- (UILabel *)placeholderCacheLabel {
    if (!_placeholderCacheLabel) {
        _placeholderCacheLabel = [[UILabel alloc] init];
        _placeholderCacheLabel.layer.anchorPoint = CGPointZero;
    }
    return _placeholderCacheLabel;
}
- (UILabel *)errorLabel {
    if (!_errorLabel) {
        _errorLabel = [UILabel new];
        _errorLabel.textColor = [UIColor redColor];
        _errorLabel.font = [UIFont systemFontOfSize:11];
        _errorLabel.hidden = YES;
        _errorLabel.text = @"输入错误";
        [_errorLabel sizeToFit];
    }
    return _errorLabel;
}
- (void)setLineSelectedColor:(UIColor *)lineSelectedColor {
    _lineSelectedColor = lineSelectedColor;
    self.animationLineView.backgroundColor = lineSelectedColor;
}


@end
