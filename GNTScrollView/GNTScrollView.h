//
//  GNTScrollView.h
//  GNTCommonUI
//
//  Created by Han Korea on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GNTScrollItemView.h"
#import "NPInfiniteScrollView.h"
@class GNTScrollView;

/* Datasource */
@protocol GNTScrollViewDatasource <NSObject>
@required
- (NSInteger)numberOfViewInScrollView:(GNTScrollView *)scrollView;
- (GNTScrollItemView *)scrollView:(GNTScrollView *)scrollView viewForRowAtIndex:(NSInteger)index;     
- (CGSize)scrollView:(GNTScrollView *)scrollView sizeForViewAtIndex:(NSInteger)index;
@end /* GNTScrollViewDatasource */


/* Delegate */
@protocol GNTScrollViewDelegate <NSObject>
@optional
/* Called before the user changes the selection. */
- (void)scrollView:(GNTScrollView *)scrollView willSelectPageAtIndex:(NSInteger)index;
- (void)scrollView:(GNTScrollView *)scrollView willDeselectPageAtIndex:(NSInteger)index;

/* Called after the user changes the selection. */
- (void)scrollView:(GNTScrollView *)scrollView didSelectPageAtIndex:(NSInteger)index;
- (void)scrollView:(GNTScrollView *)scrollView didDeselectPageAtIndex:(NSInteger)index;
@end /* GNTScrollViewDelegate */


@interface GNTScrollView : UIScrollView <UIScrollViewDelegate> {
    NSInteger                        _visibleIndex;
    NSMutableArray                  *_visiblePages;
    NSMutableArray                  *_reusePages;
    NSMutableArray                  *_sizeDic;
    int                             _numberOfViews;
    int                             _currentSelectedIndex;
    BOOL                            _rowAlreadySelected;
    BOOL hasHorizontalScroll;
    BOOL hasVerticalScroll;
    NSMutableArray *placeholderSubviews;
    
}

@property (nonatomic, assign) id<GNTScrollViewDatasource>       dataSource;
@property (nonatomic, assign) id<GNTScrollViewDelegate>         dataDelegate;
@property (nonatomic, weak) id <UIScrollViewDelegate> originalDelegate;
@property (nonatomic, assign) BOOL selectionEnable;
/* Public method */
- (void)reloadData; /* reload all subview call it when you change datasource */
- (GNTScrollItemView *)dequeueReusablePageWithIdentifier:(NSString *)identifier; /* get view from reuse page */
- (NSInteger)indexForRowAtPoint:(CGPoint)point; /* get index of view at point */                        
- (NSInteger)indexForView:(GNTScrollItemView *)itemView;                      
- (NSArray *)indexForRowsInRect:(CGRect)rect;               
- (GNTScrollItemView *)viewForRowAtIndex:(int)index;           
- (NSArray *)visibleViews;
- (NSArray *)indexsForVisibleViews;
- (void)scrollToRowAtIndex:(NSInteger)index animated:(BOOL)animated;
- (NSInteger)numberOfViews;
- (void)deselectViewAtIndex:(NSInteger)index;
- (void)reloadRowAtIndex:(int)index;
@end
