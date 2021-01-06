//
//  ViewController.m
//  AZChoicesList
//
//  Created by 云联智慧 on 2021/1/5.
//

#import "ViewController.h"

@interface ViewController ()<KKGAZChoiceItemListViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *withSelectFuncBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 100, SCREEN_W, 40.0)];
    withSelectFuncBtn.backgroundColor = [UIColor orangeColor];
    [withSelectFuncBtn setTitle:@"可以做选择操作的" forState:UIControlStateNormal];
    [withSelectFuncBtn addTarget:self action:@selector(tapToShowList:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:withSelectFuncBtn];
    
    
    UIButton *noSelectFuncBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 200, SCREEN_W, 40.0)];
    noSelectFuncBtn.backgroundColor = [UIColor orangeColor];
    [noSelectFuncBtn setTitle:@"单纯展示的" forState:UIControlStateNormal];
    [self.view addSubview:noSelectFuncBtn];
    [noSelectFuncBtn addTarget:self action:@selector(tapToShowList:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)tapToShowList:(UIButton *)sender
{
    KKGAZChoiceItemListViewController *AZChoiceItemListVC = [KKGAZChoiceItemListViewController new];
    if([sender.currentTitle isEqualToString:@"可以做选择操作的"])
    {
        
        AZChoiceItemListVC.delegate = self;
        AZChoiceItemListVC.isJustForShow = NO;
    }
    else
    {
        
        AZChoiceItemListVC.isJustForShow = YES;
    }
    [self.navigationController pushViewController:AZChoiceItemListVC animated:YES];
}
#pragma mark KKGAZChoiceItemListViewControllerDelegate
-(void)didSelectedOneModel:(KKGChoiceItemModel *)model
{
    NSLog(@"选中了====%@",model.itemTitle);
}
@end
