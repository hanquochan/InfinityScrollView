//
//  GNTScrollItemView.h
//  GNTCommonUI
//
//  Created by Han Korea on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GNTScrollItemViewDelegate;
@interface GNTScrollItemView : UIView <UIGestureRecognizerDelegate> {
    UIView      *hightlightView;
    
}

@property (nonatomic, retain) NSString  *reuseIndentifier;
@property (nonatomic, assign) id        itemViewDelegate;
@property (nonatomic, assign) BOOL      selected;
@property (nonatomic, assign) NSInteger viewIndex;
@property (nonatomic, assign) BOOL selectionEnable;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;
- (void)prepareToReuse;
- (void)setHightLight:(BOOL)hightLight;
@end

@protocol GNTScrollItemViewDelegate 
@optional 
- (void)scrollItemViewWillTapped:(GNTScrollItemView *)sender;
- (void)scrollItemViewDidTapped:(GNTScrollItemView *)sender;
@end

