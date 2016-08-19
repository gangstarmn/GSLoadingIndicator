//
//  ZLoadingView.h
//  ZAccountKit
//
//  Created by Gantulga on 4/13/16.
//  Copyright © 2016 Gantulga. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSLoadingIndicator : UIView

@property (nonatomic, retain, setter=setColors:) NSArray *colors;

- (void)startRefreshing;
- (void)endRefreshing;

@end
