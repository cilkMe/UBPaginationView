//
//  UBPage.h
//  UBTeacher
//
//  Created by tudou on 2019/10/16.
//  Copyright © 2019年 UBZY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UBPaginationView;
@class UBPaginationModel;
NS_ASSUME_NONNULL_BEGIN
@protocol UBPaginationViewDelegate <NSObject>

@required

/**
 对应页码的item样式（自定义样式）
 */
- (nonnull __kindof UICollectionViewCell *)paginationView:(UBPaginationView *)paginationView titleItemForPageAtIndex:(NSInteger)index;

/**
 标题按钮的大小（可以固定大小，也可以单独计算每个大小）
 */

- (CGSize)paginationView:(UBPaginationView *)paginationView titleSizeForPageAtIndex:(NSInteger)index;

/**
 对应页码的控制器
 */
- (nonnull __kindof UIViewController *)paginationView:(UBPaginationView *)paginationView controllerForPageAtIndex:(NSInteger)index;

@optional

/**
 titleItem高度
 */
- (CGFloat)heightForTitleItemInPaginationView:(UBPaginationView *)paginationView;

/**
 paginationView内边距
 */
- (UIEdgeInsets)insetForTitleItemInPaginationView:(UBPaginationView *)paginationView;


/**
 标题与标题之间的间距
 */
- (CGFloat)minimumLineSpacingForTitleItemInPaginationView:(UBPaginationView *)paginationView;

/**
 点击对应页码
 */
- (void)paginationView:(UBPaginationView *)paginationView didSelectPageTitleAtIndex:(NSInteger)index;

/**
 是否展示对应控制器（默认为Yes）
 */
- (BOOL)paginationView:(UBPaginationView *)paginationView shouldSelectPageTitleAtIndex:(NSInteger)index;


@end

@interface UBPaginationView : UIView


/**
 刷新视图
 */
-(void)reloadData;

/**
 注册样式
 */
- (void)registerNib:(nullable UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier;


/**
 获取样式
 */
- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index;


/**
 获取样式
 */
- (nullable UICollectionViewCell *)cellForItemAtIndex:(NSInteger )index;
/**
 更新指定页码标题
 */
-(void)updatePaginationViewTitle:(NSString *)title index:(NSInteger)index;

/**
 计算文字的宽度
 */
- (CGSize)sizeWithString:(NSString *)string Font:(UIFont *)font;
/**
 代理
 */
@property (nonatomic, weak, nullable) id <UBPaginationViewDelegate> delegate;


/**
 数据源
 */
@property (nonatomic,strong) NSMutableArray<UBPaginationModel *> * dataSource;

/**
 手动设置控制器索引(如果是初始化的时候设置请在设置数据源之前设置)
 */
-(void)setCurrentPage:(NSInteger)currentPage;


/**
 滑块颜色
 */
@property (nonatomic,strong) UIColor * slider_color;

/**
 滑块高度
 */
@property (nonatomic,assign) float slider_hight;

/**
 滑块宽度
 */
@property (nonatomic,assign) float slider_width;

@end


@interface UBPaginationModel : UIView

+(NSMutableArray<UBPaginationModel *> *)modelArrayWithTitleArray:(NSArray *)titleArray;


/**
 控制器
 */
@property (nonatomic,strong) UIViewController * controller;

/**
 标题
 */
@property (nonatomic,strong) NSString * title;

/**
 是否已读过
 */
@property (nonatomic,assign) BOOL isAlreadyRead;


/**
 是否是当前页
 */
@property (nonatomic,assign) BOOL isCurrentPage;

@end
NS_ASSUME_NONNULL_END
