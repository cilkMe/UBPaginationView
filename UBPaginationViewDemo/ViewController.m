//
//  ViewController.m
//  UBPaginationViewDemo
//
//  Created by tudou on 2019/12/18.
//  Copyright © 2019年 UbTeach. All rights reserved.
//

#import "ViewController.h"
#import "UBPaginationView.h"
#import "TempCell.h"
@interface ViewController ()<UBPaginationViewDelegate>
@property (nonatomic,strong) UBPaginationView * paginationView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"UBPaginationViewDemo";
    [self.view addSubview:self.paginationView];
    // Do any additional setup after loading the view, typically from a nib.
}
-(UBPaginationView *)paginationView{
    if (!_paginationView) {
        _paginationView = [[UBPaginationView alloc] initWithFrame:self.view.bounds];
        _paginationView.delegate = self;
        [_paginationView registerNib:[UINib nibWithNibName:@"TempCell" bundle:nil] forCellWithReuseIdentifier:@"TempCell"];
        _paginationView.dataSource = @[@"DEBDEV",@"VICEMODEBDE",@"DEBDEV",@"DEBDEV",@"VICEMODEBDE",@"DEBDEV",@"VICEMODEBDE",@"DEBDEV",@"VICEMODEBDE"].mutableCopy;
        
    }
    return _paginationView;
}

- (UICollectionViewCell *)paginationView:(UBPaginationView *)paginationView titleItemForPageAtIndex:(NSInteger)index{
    TempCell * cell = [paginationView dequeueReusableCellWithReuseIdentifier:@"TempCell" forIndex:index];
    UBPaginationModel * model = paginationView.dataSource[index];
    cell.title_lab.text = model.title;
    cell.red_view.hidden =model.isAlreadyRead;
    return cell;
}
-(CGSize)paginationView:(UBPaginationView *)paginationView titleSizeForPageAtIndex:(NSInteger)index{
    return CGSizeMake([paginationView sizeWithString:paginationView.dataSource[index].title Font:[UIFont systemFontOfSize:20]].width + 10, 50);
}


- (UIViewController *)paginationView:(UBPaginationView *)paginationView controllerForPageAtIndex:(NSInteger)index{
    UIViewController * vc = [UIViewController new];
    switch (index) {
        case 0:
            vc.view.backgroundColor = [UIColor orangeColor];
            break;
        case 1:
            vc.view.backgroundColor = [UIColor grayColor];
            break;
        case 2:
            vc.view.backgroundColor = [UIColor blueColor];
            break;
        case 3:
            vc.view.backgroundColor = [UIColor redColor];
            break;
        case 4:
            vc.view.backgroundColor = [UIColor yellowColor];
            break;
        case 5:
            vc.view.backgroundColor = [UIColor cyanColor];
            break;
            
        default:
            vc.view.backgroundColor = [UIColor purpleColor];
            break;
    }
    NSLog(@"当前加载的控制器为%ld-------------------------",index);
    return vc;
}
-(void)paginationView:(UBPaginationView *)paginationView didSelectPageTitleAtIndex:(NSInteger)index{
    UBPaginationModel * model = paginationView.dataSource[index];
    if (![model.title containsString:@"已读"]) [paginationView updatePaginationViewTitle:[NSString stringWithFormat:@"%@(已读)",model.title] index:index];
    NSLog(@"选择的控制器为%ld-------------------------",index);
    
}

@end
