//
//  GNTScrollView.m
//  GNTCommonUI
//
//  Created by Han Korea on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GNTScrollView.h"
#import "macro.h"
@implementation GNTScrollView
@synthesize dataSource  = _dataSource;
@synthesize originalDelegate = originalDelegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.pagingEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        
        _visiblePages = [[NSMutableArray alloc] init];
        _reusePages = [[NSMutableArray alloc] init];
        _visibleIndex = -1;
        _sizeDic = [[NSMutableArray alloc] init];
        self.multipleTouchEnabled=NO;
        self.exclusiveTouch =YES;
        placeholderSubviews = [NSMutableArray array];
        self.delegate = self;
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.pagingEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        
        _visiblePages = [[NSMutableArray alloc] init];
        _reusePages = [[NSMutableArray alloc] init];
        _visibleIndex = -1;
        _sizeDic = [[NSMutableArray alloc] init];
        self.multipleTouchEnabled=NO;
        self.exclusiveTouch =YES;
        placeholderSubviews = [NSMutableArray array];
        self.delegate = self;
    }
    return self;
}


-(void)setContentOffset:(CGPoint)contentOffset {
    //If size is not zero and we are dragging the scroll view
    if (!CGSizeEqualToSize(self.contentSize, CGSizeZero) && (!self.pagingEnabled || !self.decelerating)) {
        
        //if we scroll father than half of scroll size backwards with X coordinate
        if ((contentOffset.x<-self.frame.size.width/2) && hasHorizontalScroll) {
            contentOffset.x = ((int)contentOffset.x + (int)self.contentSize.width)%((int)self.contentSize.width);
        }
        
        //if we scroll father than half of scroll size forwards with X coordinate
        if ((contentOffset.x>self.contentSize.width-self.frame.size.width/2) && hasHorizontalScroll) {
            contentOffset.x = ((int)contentOffset.x - (int)self.contentSize.width)%((int)self.contentSize.width);
        }
        
        //if we scroll father than half of scroll size backwards with Y coordinate
        if ((contentOffset.y<-self.frame.size.height/2) && hasVerticalScroll) {
            contentOffset.y = ((int)contentOffset.y + (int)self.contentSize.height)%((int)self.contentSize.height);
        }
        
        //if we scroll father than half of scroll size forwards with Y coordinate
        if ((contentOffset.y>self.contentSize.height-self.frame.size.height/2) && hasVerticalScroll) {
            contentOffset.y = ((int)contentOffset.y - (int)self.contentSize.height)%((int)self.contentSize.height);
        }
    }
    [super setContentOffset:contentOffset];
}

-(void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
    
    hasHorizontalScroll = self.contentSize.width>self.frame.size.width;
    hasVerticalScroll = self.contentSize.height>self.frame.size.height;
    
    //Make insets the same size as content size (needed for paging disabled mode)
    [self setContentInset:UIEdgeInsetsMake(contentSize.height*2*hasVerticalScroll,
                                           contentSize.width*2*hasHorizontalScroll,
                                           contentSize.height*2*hasVerticalScroll,
                                           contentSize.width*2*hasHorizontalScroll)];
}
//
//-(void)addSubview:(UIView *)view {
//    [super addSubview:view];
//    
//    [self redrawPlaceHolders];
//}

#pragma mark - Internal methods

-(void) redrawPlaceHolders {
    for (UIView *view in placeholderSubviews) {
        [view removeFromSuperview];
    }
    [placeholderSubviews removeAllObjects];
     GNTScrollItemView *pageAtIndex = [self loadPageAtIndex:_numberOfViews - 1];
    pageAtIndex.frame = CGRectOffset(pageAtIndex.frame,
                                  -self.frame.size.width,
                                  0);
    [placeholderSubviews addObject:pageAtIndex];
    
    GNTScrollItemView *firstPageAtIndex = [self loadPageAtIndex:0];
    firstPageAtIndex.frame = CGRectOffset(firstPageAtIndex.frame,
                                      self.contentSize.width,
                                      0);
    [placeholderSubviews addObject:firstPageAtIndex];
        
    for (UIView *view in placeholderSubviews) {
        //You can use it for debug to see the magic
        [super addSubview:view];
    }
}

- (UIImage *)imageFromLayer:(CALayer *)layer
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions([layer frame].size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext([layer frame].size);
    
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return outputImage;
}



- (id <GNTScrollViewDelegate>)delegate {
	return (id <GNTScrollViewDelegate>) [super delegate];
}


-(void)setDelegate:(id<UIScrollViewDelegate>)delegate {
    originalDelegate = delegate;
    [super setDelegate:self];
}


- (GNTScrollItemView*)loadPageAtIndex:(NSInteger)index {
	GNTScrollItemView *visiblePage = [self.dataSource scrollView:self viewForRowAtIndex:index];
    return visiblePage;
}


- (NSInteger)indexForView:(GNTScrollItemView *)page {
    NSInteger index = [_visiblePages indexOfObject:page];
    if (index != NSNotFound) {
        return _visibleIndex + index;
    }
    return NSNotFound;
}


- (CGRect)frameForPageAtIndex:(NSInteger)index withPage:(GNTScrollItemView *)page {
    if ([_dataSource respondsToSelector:@selector(scrollView:sizeForViewAtIndex:)]) {
        CGSize pageSize = [_dataSource scrollView:self sizeForViewAtIndex:index];
        @try {
            NSValue *pageRect = [_sizeDic objectAtIndex:index];
            CGFloat originX = [pageRect CGRectValue].origin.x;
            CGRect resultFrame = page.frame;
            resultFrame.origin.x = originX;
            resultFrame.size = pageSize;
            return resultFrame;
        }
        @catch (NSException *exception) {
        }
    }
    return CGRectZero;
}


- (BOOL)isAlreadyDisplay:(int)index {
    BOOL founded = NO;
    for (GNTScrollItemView *item in _visiblePages) {
        if (item.viewIndex == index)
            founded = YES;
    }
    return founded;
}


- (void) addPageToScrollViewAtIndex:(NSInteger)index isInsert:(BOOL)isInsert {
    if (_visibleIndex < 0)
        _visibleIndex = 0;
    
    GNTScrollItemView *pageAtIndex = [self loadPageAtIndex:index];
    pageAtIndex.itemViewDelegate = self;
    pageAtIndex.viewIndex = index;
    CGRect frame = [self frameForPageAtIndex:index withPage:pageAtIndex];
    pageAtIndex.frame = frame;
    if (isInsert) {
        _visibleIndex = index;
        [_visiblePages insertObject:pageAtIndex atIndex:0];
    } else 
        [_visiblePages addObject:pageAtIndex];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"viewIndex" ascending:YES];
    [_visiblePages sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [self addSubview:pageAtIndex];
}


- (BOOL)checkVisible:(GNTScrollItemView *)page {
    CGRect visibleRect;
    visibleRect.origin = self.contentOffset;
    visibleRect.size = self.bounds.size;
    if ((page.frame.origin.x + page.frame.size.width) > self.contentOffset.x
        && (page.frame.origin.x +page.frame.size.width) <= self.contentOffset.x + self.bounds.size.width) {
        return YES;
    } 
    if (page.frame.origin.x  >= self.contentOffset.x
        && page.frame.origin.x  < self.contentOffset.x + self.bounds.size.width) {
        return YES;
    }
    return NO;
}


- (BOOL)checkRectVisible:(CGRect)rect {
    CGRect visibleRect;
    visibleRect.origin = self.contentOffset;
    visibleRect.size = self.bounds.size;
    if ((rect.origin.x + rect.size.width) > self.contentOffset.x
        && (rect.origin.x +rect.size.width) <= self.contentOffset.x + self.bounds.size.width) {
        return YES;
    } 
    if (rect.origin.x  >= self.contentOffset.x
               && rect.origin.x  < self.contentOffset.x + self.bounds.size.width) {
        return YES;
    }
    return NO;
}


- (GNTScrollItemView *)dequeueReusablePageWithIdentifier:(NSString *)identifier {
	for (GNTScrollItemView *page in _reusePages) {
		if ([page.reuseIndentifier isEqualToString:identifier]) {
			[_reusePages removeObject:page];
			[page prepareToReuse];
			return page;
		}
	}
	return nil;
}


- (void)updateVisiblePages {
    /* remove any subview which not visible */
    for (int i = 0; i < [_visiblePages count]; i++) {
        GNTScrollItemView *page = [_visiblePages objectAtIndex:i];
        if (![self checkVisible:page]) {
            [_reusePages addObject:page];
            [_visiblePages removeObjectAtIndex:i];
            [page removeFromSuperview];
        }
    }
    [_visiblePages removeObjectsInArray:_reusePages];
    int firstIndex = -1;
    int lastIndex = -1;
    for (int i = 0; i < _numberOfViews; i++) {
        NSValue *pageRect = [_sizeDic objectAtIndex:i];
        if ([self checkRectVisible:[pageRect CGRectValue]]) {
            if (firstIndex == -1)
                firstIndex = i;
            else
                lastIndex = i;
        } 
    }
    if (lastIndex < firstIndex)
        lastIndex = firstIndex;
    _visibleIndex = firstIndex;
    for (int i = firstIndex; i <= lastIndex && i >= 0; i++) {
        if (![self isAlreadyDisplay:i]) {
            [self addPageToScrollViewAtIndex:i isInsert:NO];
        } 
    }
//    int currentIndex = 0;
//    if ([_visiblePages count] > 0) {
//        GNTScrollItemView *item = [_visiblePages lastObject];
//        currentIndex = item.viewIndex;
//    }  else {
//        currentIndex = _visibleIndex;
//    }
//    for (int i = currentIndex + 1; i < _numberOfViews; i++) {
//        NSValue *pageRect = [_sizeDic objectAtIndex:i];
//        CGFloat originX = [pageRect CGRectValue].origin.x;
//        if (originX  >= self.contentOffset.x
//            && originX <= self.contentOffset.x + self.bounds.size.width) {
//            if (![self isAlreadyDisplay:i])
//                [self addPageToScrollViewAtIndex:i isInsert:NO];
//        } else {
//            break;
//        }
//    }
    
    
}


- (void)reloadData {
    /* reset size dic */
    [_sizeDic removeAllObjects];
    
    /* reset visible pages array */
	[_visiblePages removeAllObjects];
    
    /* remove all subviews in scrollView */
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:[GNTScrollItemView class]]) {
            [v removeFromSuperview];
        }
    }

    for (UIView *view in placeholderSubviews) {
        [view removeFromSuperview];
    }
    [placeholderSubviews removeAllObjects];
    
    /* get number of views again */
	if ([self.dataSource respondsToSelector:@selector(numberOfViewInScrollView:)]) {
		_numberOfViews = [self.dataSource numberOfViewInScrollView:self];
	}
    CGFloat totalWidth = 0;
    for (int i = 0; i < _numberOfViews; i++) {
        if ([_dataSource respondsToSelector:@selector(scrollView:sizeForViewAtIndex:)]) {
            CGSize itemSize = [_dataSource scrollView:self sizeForViewAtIndex:i];
            CGRect pageRect = CGRectMake(totalWidth, 0, itemSize.width, itemSize.height);
            [_sizeDic addObject:[NSValue valueWithCGRect:pageRect]];
            totalWidth += itemSize.width;
        }
    }
    self.contentSize = CGSizeMake(totalWidth, self.frame.size.height);
	if (_numberOfViews > 0) {
		// reload visible pages
		
		// this will load any additional views which become visible  
		[self updateVisiblePages];
    }
    [self redrawPlaceHolders];
}


- (void)layoutSubviews {
    [self updateVisiblePages];
}


- (NSInteger)indexForRowAtPoint:(CGPoint)point {
    for (int i = 0; i < [_visiblePages count]; i++) {
        GNTScrollItemView *page = [_visiblePages objectAtIndex:i];
        if (CGRectContainsPoint(page.frame, point)) {
            return _visibleIndex + i;
        }
    }
    return NSNotFound;
}


- (NSArray *)indexForRowsInRect:(CGRect)rect {
    NSMutableArray *list = [NSMutableArray array];
    for (int i = 0; i < [_visiblePages count]; i++) {
        GNTScrollItemView *page = [_visiblePages objectAtIndex:i];
        if (CGRectIntersectsRect(page.frame, rect)) {
            [list addObject:[NSNumber numberWithInt:_visibleIndex + i]];
        }
    }
    return list;
}


- (GNTScrollItemView *)viewForRowAtIndex:(int)index {
    int visibleIndex = index - _visibleIndex;
    if (visibleIndex >= 0 && visibleIndex < [_visiblePages count]) {
        return [_visiblePages objectAtIndex:visibleIndex];
    } 
    return nil;
}


- (NSArray *)visibleViews {
    return _visiblePages;
}


- (NSArray *)indexsForVisibleViews {
    NSMutableArray *list = [NSMutableArray array];
    for (int i = 0; i < [_visiblePages count]; i++) {
        [list addObject:[NSNumber numberWithInt:_visibleIndex + i]];
    }
    return list;
}


- (void)scrollToRowAtIndex:(NSInteger)index animated:(BOOL)animated {
    if (index >= 0 && index < [_sizeDic count]) {
        NSValue *pageRect = [_sizeDic objectAtIndex:index];
        [self setContentOffset:[pageRect CGRectValue].origin animated:animated];
    }
}


- (NSInteger)numberOfViews {
    return _numberOfViews;
}


- (void)deselectViewAtIndex:(NSInteger)index {
    GNTScrollItemView *v = [self viewForRowAtIndex:index];
    if (v) {
        [v setHightLight:NO];
    }
}


- (void)reloadRowAtIndex:(int)index {
    
}


#pragma mark === GNTScrollItemViewDelegate ===
- (void)scrollItemViewWillTapped:(GNTScrollItemView *)itemView {
    if (_rowAlreadySelected) {
        return;
    }
    NSInteger index = [itemView viewIndex];
    if (index != NSNotFound) {
        if (self.dataDelegate && [self.dataDelegate respondsToSelector:@selector(scrollView:willSelectPageAtIndex:)]) {
            [self.dataDelegate scrollView:self willSelectPageAtIndex:index];
        } 
    }
}


- (void)scrollItemViewDidTapped:(GNTScrollItemView *)itemView {
    if (self.selectionEnable) {
        if (_rowAlreadySelected) {
            return;
        } else {
            _rowAlreadySelected = YES;
        }
        NSInteger index = [itemView viewIndex];
        if (index != NSNotFound) {
            if (self.dataDelegate && [self.dataDelegate respondsToSelector:@selector(scrollView:didSelectPageAtIndex:)]) {
                [self.dataDelegate scrollView:self didSelectPageAtIndex:index];
            }
        }
        [self performSelector:@selector(enableSelectRow) withObject:nil afterDelay:0.5f];
    }
}


#pragma mark - UIScrollViewDelegate Forwarders

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([originalDelegate respondsToSelector:@selector(scrollViewDidScroll:)])
        [originalDelegate scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if ([originalDelegate respondsToSelector:@selector(scrollViewDidZoom:)])
        [originalDelegate scrollViewDidZoom:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([originalDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)])
        [originalDelegate scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (!CGSizeEqualToSize(self.contentSize, CGSizeZero)) {
        
        //If target offset is far left
        if (((*targetContentOffset).x<-self.frame.size.width/2)) {
            [super setContentOffset:CGPointMake(self.contentOffset.x+self.contentSize.width, self.contentOffset.y)];
            targetContentOffset->x += self.contentSize.width;
        }
        
        //If target offset is far right
        if ((*targetContentOffset).x>self.contentSize.width-self.frame.size.width/2) {
            [super setContentOffset:CGPointMake(self.contentOffset.x-self.contentSize.width, self.contentOffset.y)];
            targetContentOffset->x -= self.contentSize.width;
        }
        
        //If target offset is far up
        if (((*targetContentOffset).y<-self.frame.size.height/2)) {
            [super setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y+self.contentSize.height)];
            targetContentOffset->y += self.contentSize.height;
        }
        
        //If target offset is far bottom
        if (((*targetContentOffset).y>self.contentSize.height-self.frame.size.height/2)) {
            [super setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y-self.contentSize.height)];
            targetContentOffset->y -= self.contentSize.height;
        }
        
    }
    
    if ([originalDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)])
        [originalDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([originalDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)])
        [originalDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ([originalDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)])
        [originalDelegate scrollViewWillBeginDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([originalDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)])
        [originalDelegate scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([originalDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)])
        [originalDelegate scrollViewDidEndScrollingAnimation:scrollView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if ([originalDelegate respondsToSelector:@selector(viewForZoomingInScrollView:)])
        return [originalDelegate viewForZoomingInScrollView:scrollView];
    
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    if ([originalDelegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)])
        [originalDelegate scrollViewWillBeginZooming:scrollView withView:view];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if ([originalDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)])
        [originalDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    if ([originalDelegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)])
        return [originalDelegate scrollViewShouldScrollToTop:scrollView];
    
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if ([originalDelegate respondsToSelector:@selector(scrollViewDidScrollToTop:)])
        [originalDelegate scrollViewDidScrollToTop:scrollView];
}



- (void)enableSelectRow {
    _rowAlreadySelected = NO;
}

//- (void)scrollItemViewDidTapped:(GNTScrollItemView *)sender;
//- (void)scrollItemViewDidDoubleTapped:(GNTScrollItemView *)sender;
//- (void)scrollItemViewDidLongPressed:(GNTScrollItemView *)sender;
- (void)dealloc {
    self.dataDelegate = nil;
    self.dataSource = nil;
}
@end
