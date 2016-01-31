//
//  GNTScrollItemView.m
//  GNTCommonUI
//
//  Created by Han Korea on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GNTScrollItemView.h"
#import <QuartzCore/QuartzCore.h>
#import "macro.h"
#define DOUBLE_TAP_DELAY 0.2
@interface GNTScrollItemView() {
}
@end

@implementation GNTScrollItemView

- (void)initial {
    self.selected = NO;
    hightlightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    hightlightView.backgroundColor = [UIColor blackColor];
    hightlightView.alpha = 0.3;
    hightlightView.hidden = YES;
    [self addSubview:hightlightView];
    [self sendSubviewToBack:hightlightView];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.delegate = self;
    tapGesture.cancelsTouchesInView = NO;
    [self addGestureRecognizer:tapGesture];


}


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithFrame:frame];
    if (self) {
        self.reuseIndentifier = reuseIdentifier;
        [self initial];
    }
    return self;
}



- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initial];
    }
    return self;
}


- (void)awakeFromNib {
    [self initial];
}


- (void)prepareToReuse {
    /* To reuse must reset cell. */
    self.transform = CGAffineTransformIdentity;
    _viewIndex = -1;
    hightlightView.hidden = YES;
}


- (void)setHightLight:(BOOL)hightLight {
    if (hightLight) {
        hightlightView.alpha = 0.0f;
        [UIView animateWithDuration:0.1 animations:^{
            hightlightView.hidden = NO;
            hightlightView.alpha = 1.0f;
        }];
    } else {
        [UIView animateWithDuration:0.1 animations:^{
            hightlightView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            if (finished) {
                hightlightView.hidden = YES;
            }
        }];
    }
}





- (void)tapped:(UIGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if (_itemViewDelegate && [_itemViewDelegate respondsToSelector:@selector(scrollItemViewDidTapped:)]) {
            [_itemViewDelegate scrollItemViewDidTapped:self];
        }
    }
}

//#pragma mark === Handle Touch Event ===
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    _cancel = NO;
//    UITouch *touch = [touches anyObject];
//    _tapLocation = [touch locationInView:self];
//    if (_delegate && [_delegate respondsToSelector:@selector(scrollItemViewWillTapped:)]) {
//        [_delegate scrollItemViewWillTapped:self];
//    }
//    [self setHightLight:YES];
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    if (!_cancel) {
//        [self tapped];
//    } else {
//        [self setHightLight:NO];
//    }
//}
//
//
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
//    _cancel = YES;
//    [self setHightLight:NO];
//}
//
//
//#pragma mark === UIEvent === 
//- (void)tapped {
//    if (_delegate && [_delegate respondsToSelector:@selector(scrollItemViewDidTapped:)]) {
//        [_delegate scrollItemViewDidTapped:self];
//    }
//}
//
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIControl class]]) {
        return NO;
    }
    return YES;
}


- (void)dealloc {
    self.itemViewDelegate = nil;
}

@end
