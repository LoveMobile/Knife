//
//  KNIInfoCollectionViewController.m
//  The Knife
//
//  Created by Brian Drell on 2/28/15.
//  Copyright (c) 2015 The Knife App Co. All rights reserved.
//

#import "KNIInfoCollectionViewController.h"
#import "KNICloudKitController.h"

@interface KNIInfoCollectionViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@end

@implementation KNIInfoCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.doneButton.enabled = NO;
    self.doneButton.alpha = 0.2;
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 30)];
    UIView *leftView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 30)];
    self.nameTextField.leftView = leftView;
    self.emailTextField.leftView = leftView2;
    self.nameTextField.leftViewMode = UITextFieldViewModeAlways;
    self.emailTextField.leftViewMode = UITextFieldViewModeAlways;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction)doneTapped:(UIButton *)sender
{
    [[KNICloudKitController sharedInstance] updateUserRecordWithName:self.nameTextField.text email:self.emailTextField.text];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)skipTapped:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)viewTapped:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self.view endEditing:YES];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!self.nameTextField.text.length || !self.emailTextField.text.length) {
            self.doneButton.enabled = NO;
            self.doneButton.alpha = 0.2;
        } else {
            self.doneButton.enabled = YES;
            self.doneButton.alpha = 1;
        }
    });
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

@end
