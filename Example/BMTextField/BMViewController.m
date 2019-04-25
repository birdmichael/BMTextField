//
//  BMViewController.m
//  BMTextField
//
//  Created by birdmichael on 04/25/2019.
//  Copyright (c) 2019 birdmichael. All rights reserved.
//

#import "BMViewController.h"
#import <BMTextField.h>

@interface BMViewController () <UITextFieldDelegate>

@end

@implementation BMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    BMTextField *textField = [[BMTextField alloc] initWithFrame:CGRectMake(40, 200, [UIScreen mainScreen].bounds.size.width - 80, 30)];
    textField.placeholder = @"用户名";
    textField.titlePoint = CGPointMake(-5, 20);
    textField.lineSelectedColor = [UIColor blueColor];
    textField.returnKeyType = UIReturnKeyDone;
    textField.delegate = self;
    [self.view addSubview:textField];
    
    BMTextField *textField2 = [[BMTextField alloc] initWithFrame:CGRectMake(40, 300, [UIScreen mainScreen].bounds.size.width - 80, 30)];
    textField2.placeholder = @"用户名";
    textField2.lineSelectedColor = [UIColor blackColor];
    [textField2 setVerifyText:^BOOL(NSString * _Nonnull text, UILabel * _Nonnull errorLabel) {
        errorLabel.text = @"密码必须大于10位";
        if (text.length >10) {
            return YES;
        }else{
            return NO;
        }
    }];
    textField2.returnKeyType = UIReturnKeyDone;
    textField2.delegate = self;
    [self.view addSubview:textField2];
	// Do any additional setup after loading the view, typically from a nib.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
