//
//  ViewController.m
//  BHBCardViewDemo
//
//  Created by bihongbo on 15/11/13.
//  Copyright © 2015年 bihongbo. All rights reserved.
//

#import "BHBCardViewController.h"

@interface BHBCardViewController ()<BHBCardViewDelegate,BHBCardSegmentViewDelegate>

@property (nonatomic,strong) BHBCardView * cardView;

@property (nonatomic, strong) BHBCardHeaderView * headerView;

@property (nonatomic, strong) NSArray * controllers;

@property (nonatomic, strong) BHBCardSegmentView * segmentView;

@end

@implementation BHBCardViewController

- (void)reloadData{
    [self.cardView removeFromSuperview];
    [self.headerView removeFromSuperview];
    self.controllers = nil;
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(cardViewControllerSegmentView)]) {
        self.segmentView = [self.dataSource cardViewControllerSegmentView];
    }
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(cardViewControllerCustomHeaderView)]) {
        self.headerView = [self.dataSource cardViewControllerCustomHeaderView];
    }else{
        self.headerView = [[BHBCardHeaderView alloc]initWithFrame:self.segmentView.bounds];
    }
    self.headerView.userInteractionEnabled = YES;
    [self.view addSubview:self.headerView];
    self.segmentView.delegate = self;
    self.segmentView.frame = CGRectMake(self.segmentView.frame.origin.x, self.headerView.frame.size.height - self.segmentView.frame.size.height, self.segmentView.frame.size.width, self.segmentView.frame.size.height);
    self.segmentView.userInteractionEnabled = YES;
    [self.headerView addSubview:self.segmentView];
    
    self.cardView = [[BHBCardView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.cardView.cardViewDelegate = self;
    self.cardView.topY = self.segmentView.frame.size.height;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(cardViewControllerSubControllers)]) {
        self.cardView.controllers = [self.dataSource cardViewControllerSubControllers];
        [self.cardView.controllers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIViewController * vc = (UIViewController *)obj;
            [self addChildViewController:vc];
        }];
    }
    self.segmentView.currentIndex = _currentIndex;
    self.cardView.currentCardIndex = _currentIndex;
    self.cardView.topInSetY = self.headerView.frame.size.height;
    self.cardView.commonOffsetY = self.headerView.frame.size.height;
    [self.view addSubview:self.cardView];
    [self.view bringSubviewToFront:self.headerView];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.parentViewController) {
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - 64);
    }
    [self reloadData];
}

- (void)setCurrentIndex:(NSInteger)currentIndex{
    
    _currentIndex = currentIndex;
    
}

- (void)carViewDidScrollToIndex:(NSInteger)index{
    self.segmentView.currentIndex = index;
    _currentIndex = index;
}

- (void)scrollTopAnimation{

    UIScrollView * sc = (UIScrollView *)self.cardView.currentView;
    NSInteger index = [self.cardView.allViews indexOfObject:sc];
    UIEdgeInsets contentInset = [self.cardView.allViewInsets[index] UIEdgeInsetsValue];
    [sc setContentOffset:CGPointMake(0, -self.cardView.topY - contentInset.top) animated:YES];
}

-(void)cardSegmentViewDidSelectIndex:(NSInteger)index{
    self.cardView.currentCardIndex = index;
    _currentIndex = index;
    if (self.scrollTopAnimationable) {
        [self scrollTopAnimation];
    }
}


-(void)cardViewScroll:(UIScrollView *)scollView didScrollWithOffsetOld:(CGPoint)offsetOld andOffetNew:(CGPoint)offsetNew{
    NSInteger index = [self.cardView.allViews indexOfObject:scollView];
    UIEdgeInsets contentInset = [self.cardView.allViewInsets[index] UIEdgeInsetsValue];
        CGFloat headerTargetY = -(offsetNew.y + contentInset.top + self.cardView.topInSetY);
        if (headerTargetY <= 0 && headerTargetY >= -(self.cardView.topInSetY - self.cardView.topY)) {
            self.headerView.frame = CGRectMake(self.headerView.frame.origin.x,headerTargetY, self.headerView.frame.size.width, self.headerView.frame.size.height);
        }
        else if(headerTargetY < -self.cardView.topY){
            [UIView animateWithDuration:.25 animations:^{
                self.headerView.frame = CGRectMake(self.headerView.frame.origin.x,-(self.cardView.topInSetY - self.cardView.topY), self.headerView.frame.size.width, self.headerView.frame.size.height);
            }];
        }else if(headerTargetY > 0){
            [UIView animateWithDuration:.25 animations:^{
                self.headerView.frame = CGRectMake(self.headerView.frame.origin.x,0, self.headerView.frame.size.width, self.headerView.frame.size.height);
            }];
        }
    if(self.cardView.commonOffsetY != self.headerView.frame.origin.y + self.headerView.frame.size.height){
        self.cardView.commonOffsetY = self.headerView.frame.origin.y + self.headerView.frame.size.height;
        if (self.cardView.commonOffsetY == self.cardView.topY) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(cardViewHeaderView:DidDisplayOrNot:)]) {
                [self.delegate cardViewHeaderView:self.headerView DidDisplayOrNot:NO];
            }
        }else{
            if (self.delegate && [self.delegate respondsToSelector:@selector(cardViewHeaderView:DidDisplayOrNot:)]) {
            [self.delegate cardViewHeaderView:self.headerView DidDisplayOrNot:YES];
            }
        }
    }
    
    
//    }
    
}

@end
