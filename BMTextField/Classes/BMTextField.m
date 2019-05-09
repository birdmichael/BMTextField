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

@property (nonatomic, strong) CALayer *circleBorderLayer;
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
    if (self.style == BMTextFieldStyleLine) {
        self.animationLineView.backgroundColor = [UIColor redColor];
    } else if (self.style == BMTextFieldStyleCircleBorder) {
        [self.circleBorderLayer.sublayers enumerateObjectsUsingBlock:^(__kindof CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [(CAShapeLayer *)obj setStrokeColor:[UIColor redColor].CGColor];
        }];
    }
    self.errorLabel.hidden = NO;
    [self.errorLabel sizeToFit];
    CGRect frame = self.animationLineView.frame;
    frame.size.width = self.frame.size.width;
    self.animationLineView.frame = frame;
    CALayer *viewLayer = self.animationLineView.layer;
    CGPoint position = viewLayer.position;
    CGPoint x = CGPointMake(position.x , position.y);
    CGPoint y = CGPointMake(position.x , position.y);
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

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
- (void)starDrawCircleBorder {
    CALayer *circleBorderLayer = [[CALayer alloc] initWithLayer:self.layer];
    self.circleBorderLayer = circleBorderLayer;
    [self.layer addSublayer:circleBorderLayer];
    
    CAShapeLayer *leftLayer = [CAShapeLayer layer];
    leftLayer.fillColor = [UIColor clearColor].CGColor;
    leftLayer.strokeColor = self.lineSelectedColor.CGColor;
    leftLayer.lineWidth = self.animationLineView.frame.size.height;
    [circleBorderLayer addSublayer:leftLayer];
    CGPoint arc = CGPointMake(self.animationLineView.frame.origin.x, self.animationLineView.frame.origin.y/2.0);
    UIBezierPath *leftPath = [UIBezierPath bezierPath];
    [leftPath moveToPoint:CGPointMake(0, self.frame.size.height)];
    [leftPath addArcWithCenter:arc radius:self.frame.size.height/2.0 startAngle:DEGREES_TO_RADIANS(90) endAngle:DEGREES_TO_RADIANS(270) clockwise:YES];
    leftLayer.path = leftPath.CGPath;
    
    CABasicAnimation *leftLayerAnimat = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    leftLayerAnimat.duration = 0.3;
    leftLayerAnimat.fromValue = @0;
    leftLayerAnimat.toValue = @1;
    leftLayerAnimat.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    leftLayerAnimat.removedOnCompletion=NO;
    leftLayerAnimat.fillMode=kCAFillModeForwards;
    [leftLayer addAnimation:leftLayerAnimat forKey:@"path"];
    
    CAShapeLayer *rightLayer = [CAShapeLayer layer];
    rightLayer.fillColor = [UIColor clearColor].CGColor;
    rightLayer.strokeColor = self.lineSelectedColor.CGColor;
    rightLayer.lineWidth = self.animationLineView.frame.size.height;
    [circleBorderLayer addSublayer:rightLayer];
    CGPoint rightArc = CGPointMake(self.frame.size.width, self.animationLineView.frame.origin.y/2.0);
    UIBezierPath *rigthPath = [UIBezierPath bezierPath];
    [rigthPath moveToPoint:CGPointMake(0, self.frame.size.height)];
    [rigthPath addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
    [rigthPath addArcWithCenter:rightArc radius:self.frame.size.height/2.0  startAngle:DEGREES_TO_RADIANS(90) endAngle:DEGREES_TO_RADIANS(270) clockwise:NO];
    [self.placeholderCacheLabel sizeToFit];
    
    [rigthPath addLineToPoint:CGPointMake(self.placeholderCacheLabel.bounds.size.width *self.scale, 0)];
    rightLayer.path = rigthPath.CGPath;
    [rightLayer addAnimation:leftLayerAnimat forKey:@"path"];
}

- (void)removeCircleBorderAnimation {
    CAKeyframeAnimation *kfAnimation2 = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    kfAnimation2.fillMode = kCAFillModeForwards;
    kfAnimation2.removedOnCompletion = NO;
    kfAnimation2.values = @[@1,@0];
    kfAnimation2.duration = 0.25f;
    kfAnimation2.delegate = self;
    [self.circleBorderLayer addAnimation:kfAnimation2 forKey:kBMLineViewAnimationOpacity];
}


#pragma mark - NSNotification And Methods
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bm_textFieldDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bm_textFieldDidEndEditing:) name:UITextFieldTextDidEndEditingNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bm_textFieldChangedEditing:) name:UITextFieldTextDidChangeNotification object:self];
}

- (void)bm_textFieldDidBeginEditing:(NSNotification *)notification {
    if (!_cachedPlaceholder) {
        [self addSubview:self.placeholderCacheLabel];
        self.placeholderCacheLabel.attributedText = self.attributedPlaceholder;
        self.cachedPlaceholder = self.attributedPlaceholder;
    }
    
    if (self.errorLabel.hidden) {
        if (self.style == BMTextFieldStyleLine) {
            [self addAnimationLineViewAnimation];
        } else if (self.style == BMTextFieldStyleCircleBorder) {
            [self starDrawCircleBorder];
        }
    }
    
    if (!self.text || [self.text isEqualToString:@""]) {
        [self addPlaceholderAnimation];
    }
}

- (void)bm_textFieldDidEndEditing:(NSNotification *)notification {
    // Restore settings about Placeholder
    if (!self.text || [self.text isEqualToString:@""]) {
        [self removePlaceholderAnimation];
    }
    
    if (self.verifyText && !self.verifyText(self.text,self.errorLabel)) {
        [self addErrorAnimation];
    } else {
        self.errorLabel.hidden = YES;
        if (self.style == BMTextFieldStyleLine) {
            [self removeAnimationLineViewAnimation];
        } else if (self.style == BMTextFieldStyleCircleBorder) {
            [self removeCircleBorderAnimation];
        }
    }
    
}

- (void)bm_textFieldChangedEditing:(NSNotification *)notification {
    // 输入过程修改errorLabel
    if (!self.errorLabel.hidden) {
        if (self.verifyText && self.verifyText(self.text,self.errorLabel)) {
            self.errorLabel.hidden = YES;
            if (self.style == BMTextFieldStyleLine) {
                self.animationLineView.backgroundColor = self.lineSelectedColor;
            } else if (self.style == BMTextFieldStyleCircleBorder) {
                [self.circleBorderLayer.sublayers enumerateObjectsUsingBlock:^(__kindof CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [(CAShapeLayer *)obj setStrokeColor:self.lineSelectedColor.CGColor];
                }];
            }
        }
    }
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
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
