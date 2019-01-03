//
//  WhatsNewView.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-05-25.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import "WhatsNewView.h"

@implementation WhatsNewView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [self setBackgroundColor:[UTIL blueColor]];
    [self setAlpha:0.85f];
    
    CGFloat top = 64.0f;
    
    UILabel *label = [[UILabel alloc] init];
    [label setText:NSLocalizedStringFromTable(@"whats_new", [UTIL getLanguage], @"")];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont systemFontOfSize:17]];
    [label sizeToFit];
    [label setFrame:CGRectMake(15, top, self.frame.size.width, label.frame.size.height)];
    top += label.frame.size.height + 24;
    
    [self addSubview:label];
    
    NSString *appDate = @"";
    NSString *appBuild = @"";
    
    NSURL *legalUrl = [[NSBundle mainBundle] URLForResource:@"Legal" withExtension:@"plist" subdirectory:@"Settings.bundle"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfURL:legalUrl];
    NSMutableArray *array = [dictionary objectForKey:@"PreferenceSpecifiers"];
    
    for (id val in array) {
        if ([[val objectForKey:@"Key"] isEqualToString:@"appBuild"]) {
            appBuild = [val objectForKey:@"DefaultValue"];
        } else {
            if ([[val objectForKey:@"Key"] isEqualToString:@"appDate"]) {
                appDate = [val objectForKey:@"DefaultValue"];
            }
        }
    }
    
    if (![appBuild isEqualToString:@""]) {
        label = [[UILabel alloc] init];
        [label setText:[NSString stringWithFormat:@"%@: %@", NSLocalizedStringFromTable(@"build", [UTIL getLanguage], @""), appBuild]];
        [label setTextColor:[UIColor whiteColor]];
        [label setFont:[UIFont systemFontOfSize:15]];
        [label sizeToFit];
        [label setFrame:CGRectMake(15, top, self.frame.size.width, label.frame.size.height)];
        top += label.frame.size.height + 4;
        [self addSubview:label];
    }
    
    if (![appDate isEqualToString:@""]) {
        label = [[UILabel alloc] init];
        [label setText:[NSString stringWithFormat:@"%@: %@", NSLocalizedStringFromTable(@"release_date", [UTIL getLanguage], @""), appDate]];
        [label setTextColor:[UIColor whiteColor]];
        [label setFont:[UIFont systemFontOfSize:15]];
        [label sizeToFit];
        [label setFrame:CGRectMake(15, top, self.frame.size.width, label.frame.size.height)];
        top += label.frame.size.height + 4;
        [self addSubview:label];
    }
    
    top += 12;
    NSString *changes = NSLocalizedStringFromTable(@"changes", [UTIL getLanguage], @"");
    NSArray *items = [changes componentsSeparatedByString:@"|"];
    
    for (NSString *item in items) {
        label = [[UILabel alloc] init];
        [label setText:[NSString stringWithFormat:@"- %@", item]];
        [label setTextColor:[UIColor whiteColor]];
        [label setFont:[UIFont systemFontOfSize:15]];
        [label setLineBreakMode:NSLineBreakByWordWrapping];
        [label setNumberOfLines:-1];
        [label setFrame:CGRectMake(15, top, self.frame.size.width, 100)];
        [label sizeToFit];
        [label setFrame:CGRectMake(15, top, self.frame.size.width, label.frame.size.height)];
        top += label.frame.size.height + 6;
        [self addSubview:label];
    }
    
    _dismissButton = [[UIButton alloc] init];
    [_dismissButton setTitle:NSLocalizedStringFromTable(@"dismiss", [UTIL getLanguage], @"") forState:UIControlStateNormal];
    [_dismissButton setBackgroundColor:[UIColor whiteColor]];
    [_dismissButton setTitleColor:[UTIL darkBlueColor] forState:UIControlStateNormal];
    [_dismissButton setTintColor:[UTIL darkBlueColor]];
    [_dismissButton.titleLabel setFont:[UIFont systemFontOfSize:17.0]];
    
    [_dismissButton.layer setCornerRadius:5.0f];
    [_dismissButton setTitleEdgeInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    [_dismissButton sizeToFit];
    [_dismissButton addTarget:self action:@selector(dismissPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_dismissButton setFrame:CGRectMake((self.bounds.size.width - (_dismissButton.bounds.size.width + 80))/2, self.bounds.size.height - _dismissButton.bounds.size.height - 60, _dismissButton.bounds.size.width + 80, _dismissButton.bounds.size.height + 10)];
    [self addSubview:_dismissButton];
    
    //add contraints(justin)
    [_dismissButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    //distance between child and parent view (left)
    NSLayoutConstraint *contraint2 = [NSLayoutConstraint constraintWithItem:_dismissButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:40.0];
    //distance between child and parent view (bottom)
    NSLayoutConstraint *contraint3 = [NSLayoutConstraint constraintWithItem:_dismissButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-40.0];
    //distance between child and parent view (right)
    NSLayoutConstraint *contraint4 = [NSLayoutConstraint constraintWithItem:_dismissButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-40.0];
    //add contraints
    NSArray *arrayConstraints = [NSArray arrayWithObjects:contraint2, contraint3, contraint4, nil];
    [self addConstraints:arrayConstraints];
}

- (void)dismissPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"whatsNewDismissed" object:nil userInfo:nil];
}

@end
