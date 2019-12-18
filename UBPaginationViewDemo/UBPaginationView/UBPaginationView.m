//
//  UBPage.m
//  UBTeacher
//
//  Created by tudou on 2019/10/16.
//  Copyright © 2019年 UBZY. All rights reserved.
//

#import "UBPaginationView.h"
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
//弱引用self
#define WeakSelf __weak typeof(self) weakSelf = self;
@interface UBPaginationView()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic,strong) UICollectionView * title_collectionView ;
@property (nonatomic,strong) UICollectionView * vc_collectionView;
@property (nonatomic,strong) UIView * slider_view;
@property (nonatomic,assign) BOOL isFirst;

@property (nonatomic,assign) BOOL isRegisterNib;
@property (nonatomic,assign) NSInteger currentPage;
@property (nonatomic,strong) UICollectionViewCell * currentTitleItem;
@property (nonatomic,assign) CGFloat title_hight;
@property (nonatomic,assign) CGFloat lastContentOffset;
@property (nonatomic,assign) CGRect  slider_frame;


@end

@implementation UBPaginationView
#pragma --mark 公有方法

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self defaultAttribute];
        
    }
    return self;
}
-(void)defaultAttribute{
    self.slider_color = [UIColor orangeColor];
    self.slider_width = 50;
    self.slider_hight = 4;
    self.isFirst = YES;
    
}
-(CGFloat)title_hight{
    if (_title_hight <= 0) {
        _title_hight = [self.delegate respondsToSelector:@selector(heightForTitleItemInPaginationView:)] ? [self.delegate heightForTitleItemInPaginationView:self]:50;
    }
    return _title_hight;
}
/**
 设置页面
 */
-(void)setCurrentPage:(NSInteger)currentPage{
    _currentPage = currentPage;
    if (!self.isFirst) [self collectionView:self.title_collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:currentPage inSection:0]];
    
}
/**
 数据源处理
 */
-(void)setDataSource:(NSMutableArray<UBPaginationModel *> *)dataSource{
    _dataSource = [UBPaginationModel modelArrayWithTitleArray:dataSource];
    if (self.delegate && self.isRegisterNib)[self reloadData];
}

-(void)setDelegate:(id<UBPaginationViewDelegate>)delegate{
    _delegate = delegate;
    if (self.dataSource && self.isRegisterNib) [self reloadData];

}
/**
 刷新视图
 */
-(void)reloadData{
    [self.title_collectionView reloadData];
    [self.title_collectionView layoutIfNeeded];
    // 载入分页标题数据
    if (self.isFirst) {
        self.isFirst = NO;
        [self.title_collectionView addSubview:self.slider_view];
        [self bringSubviewToFront:self.slider_view];
        [self collectionView:self.title_collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentPage inSection:0]];
    }
}

/**
 注册样式
 */
-(void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier{
   
    [self.title_collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
    self.isRegisterNib = YES;
    if (self.delegate && self.dataSource)[self reloadData];
}

/**
 获取样式
 */
-(UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index{
   
    return [self.title_collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
}

/**
 获取样式
 */
-(UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index{
    return [self.title_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
}

/**
 更新指定页码标题
 */
-(void)updatePaginationViewTitle:(NSString *)title index:(NSInteger)index{
    self.dataSource[index].title = title;
    [self.title_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
}

#pragma --mark collectionView 代理

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == self.title_collectionView) {
        return CGSizeMake([self.delegate paginationView:self titleSizeForPageAtIndex:indexPath.row].width, self.title_hight);
    }else{
        return CGSizeMake(self.frame.size.width, self.frame.size.height - self.title_hight);
    }
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if (collectionView == self.title_collectionView) {
        UICollectionViewCell * cell = [self.delegate paginationView:self titleItemForPageAtIndex:indexPath.row];
        collectionView.backgroundColor = cell.backgroundColor;
        return cell;
    }else{
        UBPaginationModel * model = self.dataSource[indexPath.row];
        UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        if (!model.controller) {
            model.controller = [self.delegate paginationView:self controllerForPageAtIndex:indexPath.row];
            model.controller.view.frame = CGRectMake(0,0, self.frame.size.width, self.frame.size.height - self.title_hight);
        }
        for (UIView *subView in [cell.contentView subviews]) [subView removeFromSuperview];
        [cell.contentView addSubview:model.controller.view];

        return cell;
    }
   
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == self.vc_collectionView) return;
    // 不被允许的时候，防止居中滚动
    [self.title_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    // 判断此次点击事件是否是应该发生的
    BOOL isAble = YES;
    if ([self.delegate respondsToSelector:@selector(paginationView:shouldSelectPageTitleAtIndex:)]){
        self.vc_collectionView.scrollEnabled = NO;
        isAble = [self.delegate paginationView:self shouldSelectPageTitleAtIndex:indexPath.row];
    }
    if (!isAble) return;
    for (UBPaginationModel * model in self.dataSource) model.isCurrentPage = NO;
    self.dataSource[indexPath.row].isCurrentPage = YES;
    self.dataSource[indexPath.row].isAlreadyRead = YES;
    _currentPage = indexPath.row;
    if ([self.delegate respondsToSelector:@selector(paginationView:didSelectPageTitleAtIndex:)])  [self.delegate paginationView:self didSelectPageTitleAtIndex:indexPath.row ];
    [self changeControllerCollectionViewWithIndexPath:indexPath];
    [self changeTitleCollectionViewWithIndexPath:indexPath];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.title_collectionView)return;
    NSInteger index = (NSInteger)((scrollView.contentOffset.x + SCREEN_WIDTH*0.5)/SCREEN_WIDTH);
    [self collectionView:self.title_collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == self.vc_collectionView){
        self.lastContentOffset = scrollView.contentOffset.x;//判断z左右滑动时
        [self.title_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }else{
        
    }
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.vc_collectionView){



        if (scrollView.contentOffset.x < self.lastContentOffset ){
            if ( scrollView.contentOffset.x > 0) {
                float distance = ABS([self slierCenter:self.currentPage] - [self slierCenter:self.currentPage-1]);
                NSInteger page = scrollView.contentOffset.x/SCREEN_WIDTH;
                float percentage = (scrollView.contentOffset.x - page * SCREEN_WIDTH)/SCREEN_WIDTH;
                float increment = distance * percentage;
                self.slider_view.frame = CGRectMake(self.slider_frame.origin.x + increment - distance, self.slider_view.frame.origin.y, self.slider_width - increment + distance, self.slider_view.frame.size.height);
                
            }
        } else if (scrollView. contentOffset.x > self.lastContentOffset ){

            if ((self.dataSource.count-1) *SCREEN_WIDTH > scrollView.contentOffset.x) {
                float distance = ABS([self slierCenter:self.currentPage] - [self slierCenter:self.currentPage+1]);
                NSInteger page = scrollView.contentOffset.x/SCREEN_WIDTH;
                float percentage = (scrollView.contentOffset.x - page * SCREEN_WIDTH)/SCREEN_WIDTH;
                float increment = distance * percentage;
                self.slider_view.frame = CGRectMake(self.slider_frame.origin.x, self.slider_view.frame.origin.y, self.slider_width + increment, self.slider_view.frame.size.height);
            }
        }
    }
}
-(CGFloat)slierCenter:(NSInteger)index{

    UICollectionViewCell * cell = [self.title_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    CGRect frame = [cell convertRect:cell.bounds toView:self.title_collectionView];

    CGRect slierFrame = CGRectMake(frame.origin.x + (frame.size.width - self.slider_width)/2, self.title_hight - 1 - self.slider_hight, self.slider_width, self.slider_hight);
    
    return (slierFrame.origin.x + slierFrame.size.width)/2;

}
#pragma --mark 私有方法

/**
 滚动到对应下标的控制器视图
 */
-(void)changeControllerCollectionViewWithIndexPath:(NSIndexPath *)indexPath{
    [self.vc_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

/**
 滚动到对应下标的标题
 */
-(void)changeTitleCollectionViewWithIndexPath:(NSIndexPath *)indexPath{
    [self.title_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [self.title_collectionView layoutIfNeeded];
    [self sliderAnimationsWithIndexPath:indexPath];
}

/**
 底部slider滚动到对应的标题下方
 */
-(void)sliderAnimationsWithIndexPath:(NSIndexPath *)indexPath{
    WeakSelf
    UICollectionViewCell * cell = [self.title_collectionView cellForItemAtIndexPath:indexPath];
    CGRect frame = [cell convertRect:cell.bounds toView:self.title_collectionView];
    if (frame.size.width == 0) {
        [self.title_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        [self.title_collectionView layoutIfNeeded];
         cell = [self.title_collectionView cellForItemAtIndexPath:indexPath];
         frame = [cell convertRect:cell.bounds toView:self.title_collectionView];
        NSLog(@"问题点");
    }
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.slider_view.frame = CGRectMake(frame.origin.x + (frame.size.width - self.slider_width)/2, self.title_hight - 1 - self.slider_hight, self.slider_width, self.slider_hight);
        weakSelf.slider_frame = weakSelf.slider_view.frame;
    }];
}

/**
 计算文字的宽度
 */
- (CGSize)sizeWithString:(NSString *)string Font:(UIFont *)font{
    CGRect rect = [string boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 20, MAXFLOAT)//限制最大的宽度和高度
                                       options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading  | NSStringDrawingUsesLineFragmentOrigin//采用换行模式
                                    attributes:@{NSFontAttributeName: font}//传人的字体字典
                                       context:nil];
    return rect.size;
}

#pragma --mark 视图

/**
 承载标题的布局视图
 */
-(UICollectionView *)title_collectionView{
    if (!_title_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = [self.delegate respondsToSelector:@selector(insetForTitleItemInPaginationView:)] ? [self.delegate insetForTitleItemInPaginationView:self]:UIEdgeInsetsZero;
        layout.minimumLineSpacing = [self.delegate respondsToSelector:@selector(minimumLineSpacingForTitleItemInPaginationView:)]?[self.delegate minimumLineSpacingForTitleItemInPaginationView:self]:0;
        layout.minimumInteritemSpacing = 0;
        _title_collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.title_hight) collectionViewLayout:layout];
        _title_collectionView.showsHorizontalScrollIndicator = NO;
        _title_collectionView.delegate = self;
        _title_collectionView.dataSource = self;
//        _title_collectionView.pagingEnabled = YES;
        [self addSubview:_title_collectionView];
    }
    
    return _title_collectionView;
}

/**
 承载控制器的布局视图
 */
-(UICollectionView *)vc_collectionView{
    
    if (!_vc_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsZero;
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        _vc_collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.title_hight, self.frame.size.width, self.frame.size.height - self.title_hight) collectionViewLayout:layout];
        _vc_collectionView.showsHorizontalScrollIndicator = NO;
        _vc_collectionView.dataSource = self;
        _vc_collectionView.delegate = self;
        _vc_collectionView.backgroundColor = [UIColor whiteColor];
        _vc_collectionView.pagingEnabled = YES;
        [_vc_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        [self addSubview:_vc_collectionView];
    }
    
    return _vc_collectionView;
}

/**
 slider懒加载
 */
-(UIView *)slider_view{
    if (!_slider_view) {
        _slider_view = [[UIView alloc] init];
        _slider_view.backgroundColor = self.slider_color;
        _slider_view.clipsToBounds = YES;
        _slider_view.layer.cornerRadius = self.slider_hight/2;
    }
    return _slider_view;
}

@end


@implementation UBPaginationModel

+(NSMutableArray<UBPaginationModel *> *)modelArrayWithTitleArray:(NSArray *)titleArray{
    NSMutableArray * modelArray = [NSMutableArray array];
    for (NSString * title in titleArray) {
        UBPaginationModel * model = [UBPaginationModel new];
        model.title = title;
        [modelArray addObject:model];
    }
    return modelArray;
}

-(void)setController:(UIViewController *)controller{
    _controller = controller;
    [[self currentViewController] addChildViewController:controller];
}

/**
 获取当前屏幕显示的viewcontroller
 */

- (UIViewController *)currentViewController{
    return [self getCurrentVCFrom:[UIApplication sharedApplication].delegate.window.rootViewController];
}

/**
 递归
 */
- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootController{
    UIViewController * currentController;
    if ([rootController presentedViewController]) rootController = [rootController presentedViewController]; // 视图是被presented出来的
    
    if ([rootController isKindOfClass:[UITabBarController class]]) {
        currentController = [self getCurrentVCFrom:[(UITabBarController *)rootController selectedViewController]]; // 根视图为UITabBarController
    } else if ([rootController isKindOfClass:[UINavigationController class]]){
        currentController = [self getCurrentVCFrom:[(UINavigationController *)rootController visibleViewController]];// 根视图为UINavigationController
    } else {
        currentController = rootController;// 根视图为非导航类
    }
    
    return currentController;
}
@end
