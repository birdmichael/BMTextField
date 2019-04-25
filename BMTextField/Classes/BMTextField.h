//
//  BMTextField.h
//  TextField
//
//  Created by BirdMichael on 2019/4/25.
//  Copyright © 2019 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMTextField : UITextField
/** 验证输入文字合法性。 */
typedef BOOL (^verifyTextBlock)(NSString *text , UILabel *errorLabel);

@property (nonatomic, strong) UIColor *lineSelectedColor;
/** title 根据TextAttributes缩放，默认:0.7 */
@property (nonatomic, assign) CGFloat scale;
/** title 偏移。默认 CGPointMake(0, 20) X为右，Y为上，负值反之 */
@property (nonatomic, assign) CGPoint titlePoint;
@property (nonatomic, copy) verifyTextBlock verifyText;

@end

NS_ASSUME_NONNULL_END
