//
//  QKYDelayButton.m
//  qikeyun
//
//  Created by 马超 on 16/6/4.
//  Copyright © 2016年 Jerome. All rights reserved.
//

#import "QKYDelayButton.h"

static NSTimeInterval defaultDuration = 1.0f;

static BOOL _isIgnoreEvent = NO;

static void resetState() {
    
    _isIgnoreEvent = NO;
}


@implementation QKYDelayButton

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    if ([self isKindOfClass:[UIButton class]]) {
        
        self.clickDurationTime = self.clickDurationTime == 0 ? defaultDuration : self.clickDurationTime;
        
        if (_isIgnoreEvent) {
            
            return;
        }
        else if (self.clickDurationTime > 0) {
            
            _isIgnoreEvent = YES;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.clickDurationTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                resetState();
            });
            
            [super sendAction:action to:target forEvent:event];
        }
    }
    else {
        
         [super sendAction:action to:target forEvent:event];
    }
}

@end
