//
//  KKGAZChoiceItemListViewController.m
//  AZChoicesList
//
//  Created by 云联智慧 on 2021/1/5.
//

#import "KKGAZChoiceItemListViewController.h"

@interface KKGAZChoiceItemListViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)NSMutableArray *allItemsArray;
/**A~Z字母组。*/
@property(nonatomic,strong)NSArray *indexKeysArray;
/**遍历所有用户的名字首字母之后，得到的索引组。*/
@property(nonatomic,strong)NSMutableArray *needIndexKeysArray;
/**将每个索引作为key值存入字典，key值对应的项数组作为value.*/
@property(nonatomic,strong)NSMutableDictionary *itemDic;
/**搜索框*/
@property(nonatomic,strong)UISearchBar *searchBar;
/**搜索结果数组*/
@property(nonatomic,strong)NSMutableArray *searchResultsArray;
/**用于记录当前显示的索引分区。*/
@property(nonatomic,assign)NSInteger nowIndex;
/**用于保存所有项的字典，搜索时用来比对。*/
@property(nonatomic,strong)NSDictionary *allItemsDic;
@property(nonatomic,strong)UITableView *tableView;
@end

@implementation KKGAZChoiceItemListViewController
-(NSMutableArray *)searchResultsArray
{
    if(!_searchResultsArray)
    {
        _searchResultsArray = [NSMutableArray new];
    }
    return _searchResultsArray;
}
-(NSMutableDictionary *)itemDic
{
    if(!_itemDic)
    {
        _itemDic = [NSMutableDictionary new];
    }
    return _itemDic;
}
-(NSMutableArray *)needIndexKeysArray
{
    if(!_needIndexKeysArray)
    {
        _needIndexKeysArray = [NSMutableArray new];
    }
    return _needIndexKeysArray;
}

-(NSMutableArray *)allItemsArray
{
    if(!_allItemsArray)
    {
        _allItemsArray = [NSMutableArray new];
    }
    return _allItemsArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden = YES;
    
        
    [self addChildViews];
    NSDictionary *tempDic = [NSKeyedUnarchiver unarchiveObjectWithFile:ITEM_LIST_DIC_FILE];
    NSArray *tempArray = [NSKeyedUnarchiver unarchiveObjectWithFile:ITEM_LIST_ARRAY_FILE];
#warning 请根据你的数据更新情况来决定缓存还是没次都获取服务器数据，每次都获取的话，每次都要转拼音，是个很耗时的操作，请注意。我自己项目里是每次打开应用都会去获取新数据，不管用户进不进入到这个列表，都回去获取新数据，去刷新缓存，避免数据不一致。
    
    if(tempDic&&tempArray)//本地有缓存
    {
        self.allItemsArray = [tempArray mutableCopy];

        self.allItemsDic = [tempDic mutableCopy];
        self.itemDic = [tempDic mutableCopy];
        self.needIndexKeysArray = [[NSArray arrayWithContentsOfFile:ITEM_LIST_INDEX_FILE] mutableCopy];
        [self.tableView reloadData];
    }
    else
    {
//        本地没有缓存就从服务器获取数据吧
        [self fetchDataFromServer];
    }
}
#pragma mark 处理数据
/** 处理数据 */
-(void)dealData
{
    __block int count = 0;//记录汉字转拼音的进度数目。
    dispatch_queue_t queue = dispatch_queue_create("wpk", DISPATCH_QUEUE_CONCURRENT);
    //    NSDate *startDate = [NSDate date];
    //    __block NSTimeInterval startTimerInterval = [startDate timeIntervalSince1970];
    dispatch_async(queue, ^{
        
        for (int i = 0; i < self.allItemsArray.count; i++)
        {
            KKGChoiceItemModel *model = self.allItemsArray[i];
            
            HanyuPinyinOutputFormat *outputFormat=[[HanyuPinyinOutputFormat alloc] init];
            [outputFormat setToneType:ToneTypeWithoutTone];
            [outputFormat setVCharType:VCharTypeWithV];
            [outputFormat setCaseType:CaseTypeUppercase];
            if([model.itemTitle rangeOfString:@" "].length)//去除名字中的空格。
            {
                model.itemTitle = [model.itemTitle stringByReplacingOccurrencesOfString:@" " withString:@""];
            }
            
            [PinyinHelper toHanyuPinyinStringWithNSString:model.itemTitle withHanyuPinyinOutputFormat:outputFormat withNSString:@" " outputBlock:^(NSString *pinYin) {
                NSArray *tempArray = [pinYin componentsSeparatedByString:@" "];
                NSMutableString *outputString = [NSMutableString string];
                /** 这个串是每个汉字的首字母，例如柯柯哥，就会拼接成KKG */
                NSMutableString *firstCharactersStr = [NSMutableString string];
                for (int i = 0; i < tempArray.count;i++)
                {
                    NSString *str = (NSString *)tempArray[i];
                    [outputString appendString:str];
                    if(str.length)
                    {
                        [firstCharactersStr appendString:[str substringToIndex:1]];
                    }
                    
                }
                [outputString appendString:firstCharactersStr];//将每个汉字的拼音首字母拼接在名字拼音后面，为了在用户搜索时输入名字简写拼音作比对用。
                model.capitalSpell = outputString;
                model.wordPrefixSpell = firstCharactersStr;
                count++;
                if(count >= self.allItemsArray.count)//满足条件则汉字转拼音全部完成。
                {
                    [SVProgressHUD dismiss];
                    self.allItemsDic = [self updateIndexKeys:self.allItemsArray];
#warning 存储到本地，每一次都请求服务器数据，汉字转拼音很耗时的
                    
                    [NSKeyedArchiver archiveRootObject:self.allItemsDic toFile:ITEM_LIST_DIC_FILE];
                    [NSKeyedArchiver archiveRootObject:self.allItemsArray toFile:ITEM_LIST_ARRAY_FILE];
                    [self.needIndexKeysArray writeToFile:ITEM_LIST_INDEX_FILE atomically:YES];
                    NSLog(@"存储路径===%@",ITEM_LIST_DIC_FILE);
                    [self.tableView reloadData];
                }
            }];
        }
    });
}
#pragma mark 获取数据
-(void)fetchDataFromServer
{
#warning 我这里就获取项目里写好的json了
    NSString *path = [[NSBundle mainBundle] pathForResource:@"localTest" ofType:@"json"];
    NSLog(@"path ==== %@",path);
    
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
    NSError *error = nil;
    NSArray *needArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    NSLog(@"needArray = %@",needArray);

    NSArray *itemArray = [KKGChoiceItemModel mj_objectArrayWithKeyValuesArray:needArray];
    [self.allItemsArray addObjectsFromArray:itemArray];
    [SVProgressHUD showWithStatus:@"获取中"];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    [self dealData];
}
/** 创建子视图 */
-(void)addChildViews
{
    UIView *topNavi = [self createCustomNaviWithTitle:@"列表"];
    [self.view addSubview:topNavi];
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_W, 44.0)];
    UIImage *image = [self createImageWithColor:[UIColor whiteColor] size:CGSizeMake(self.view.frame.size.width, 44.0)];
    [self.searchBar setBackgroundImage:image];
    self.searchBar.placeholder = @"请输入关键字";
    self.searchBar.delegate = self;
    [self.view addSubview:self.searchBar];
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.searchBar.frame.origin.y + self.searchBar.frame.size.height, SCREEN_W, SCREEN_H - SafeAreaBottomHeight - SafeAreaTopHeight - self.searchBar.frame.size.height) style:UITableViewStylePlain];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.tableView registerClass:[KKGChoiceItemCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.tableView];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:(CGFloat)250 / 255 green:(CGFloat)250 / 255 blue:(CGFloat)250 / 255 alpha:1.0];
    [self.tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    
    self.indexKeysArray = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#", nil];
    
}
/**用指定颜色生成指定尺寸的图片*/
-(UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0.0f,0.0f,size.width,size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context =UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *myImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return myImage;
}
/** 创建导航栏 */
-(UIView *)createCustomNaviWithTitle:(NSString *)titleStr
{
    //上方导航栏
    UIView *topNavi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W, SafeAreaTopHeight)];
    topNavi.backgroundColor = [UIColor colorWithRed:(CGFloat)78.0 / 255.0 green:(CGFloat)160.0 / 255.0 blue:(CGFloat)240.0 / 255.0 alpha:1.0];
    
    //返回按钮
    UIButton *backBottomBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, kStatusBarHeight, 60.0, 44.0)];
    backBottomBtn.backgroundColor = [UIColor clearColor];
    [backBottomBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [topNavi addSubview:backBottomBtn];
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(15.0,kStatusBarHeight + (44.0 - 20.0) / 2.0, 11.0, 20.0)];
    [backButton setImage:[UIImage imageNamed:@"backup"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [topNavi addSubview:backButton];
    
    //标题栏
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(backBottomBtn.frame.origin.x, kStatusBarHeight, SCREEN_W - backBottomBtn.frame.origin.x - backBottomBtn.frame.origin.x, SafeAreaTopHeight - kStatusBarHeight)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    titleLabel.text = titleStr.length?titleStr:@"";
    [topNavi addSubview:titleLabel];
    return topNavi;
}


#pragma mark 返回上一级
/** 返回上一级 */
-(void)goBack
{
    if(self.navigationController)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
#pragma mark -- UITableViewDatasource--UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.needIndexKeysArray.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *tempArray = self.itemDic[self.needIndexKeysArray[section]];
    return tempArray.count;
}
-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if ([view isKindOfClass: [UITableViewHeaderFooterView class]])
    {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView*) view;
        UIView *content = headerView.contentView;
        UIColor *color = [UIColor colorWithRed:(CGFloat)247 / 255 green:(CGFloat)247 / 255 blue:(CGFloat)247 / 255 alpha:1.0]; // substitute your color here
        content.backgroundColor = color;
        [headerView.textLabel setTextColor:[UIColor colorWithRed:(CGFloat)51 / 255 green:(CGFloat)51 / 255 blue:(CGFloat)51 / 255 alpha:1.0]];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 30.0;
    return height;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.needIndexKeysArray[section];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KKGChoiceItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSArray *currentUsersArray = self.itemDic[self.needIndexKeysArray[indexPath.section]];
    KKGChoiceItemModel *model = [currentUsersArray objectAtIndex:indexPath.row];
    NSString *itemTitle = model.itemTitle;
    cell.title = itemTitle;
    cell.subTitle = model.subTitle;
    cell.isJustForShow = self.isJustForShow;
    if([self.outInModel.itemTitle isEqualToString:itemTitle])
    {
        cell.isSelected = YES;
    }
    else
    {
        cell.isSelected = NO;
    }
    
    NSString *key = self.needIndexKeysArray[indexPath.section];
    NSArray *sectionArray = self.itemDic[key];
    if(indexPath.row == sectionArray.count - 1)
    {
        cell.isShowBottomLine = NO;
    }
    else
    {
        cell.isShowBottomLine = YES;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    
    for (UIView *subview in [tableView subviews]) {
        if ([subview isKindOfClass:NSClassFromString(@"UITableViewIndex")]) {
       
        }
    }
    return cell;
}

//让表格的分割线，左侧无距离
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.separatorInset = UIEdgeInsetsZero;
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
}
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(100, 180, 75, 75)];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.font = [UIFont systemFontOfSize:36];
    lab.adjustsFontSizeToFitWidth = YES;
    lab.textColor = [UIColor whiteColor];
    lab.backgroundColor = [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)168/255 blue:(CGFloat)236/255 alpha:1.0];
    lab.text = title;
    lab.center = self.view.center;
    [self.view addSubview:lab];
    //渐消动画
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    lab.alpha = 0;
    [UIView commitAnimations];
    
    NSArray *tempArray = self.itemDic[title];
    if(!tempArray.count)
    {
        //        NSLog(@"啥也没有");
        return self.nowIndex;
    }
    else
    {
        for (int i=0; i<self.needIndexKeysArray.count; i++)
        {
            NSString *letter = self.needIndexKeysArray[i];
            if([letter isEqualToString:title])
            {
                index = i;
            }
        }
        self.nowIndex = index;
        return index;
    }
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(_isJustForShow)
    {
        return;
    }
    NSString *key = self.needIndexKeysArray[indexPath.section];
    //    NSLog(@"key = %@",key);
    NSArray *tempArray = self.itemDic[key];
    KKGChoiceItemModel *selectedItem = tempArray[indexPath.row];
    if(_delegate&&[_delegate respondsToSelector:@selector(didSelectedOneModel:)])
    {
        [_delegate didSelectedOneModel:selectedItem];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
}
/**tableView的索引。*/
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    //NSLog(@"self.newIndexKeysArray.count = %lu",(unsigned long)self.newIndexKeysArray.count);
    return self.indexKeysArray;
}
/**将用户名字转为大写拼音*/
-(NSString *)getNameCapitalSpell:(NSString *)nameStr
{
    NSMutableString *str = [NSMutableString stringWithString:nameStr];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformMandarinLatin, NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformStripDiacritics, NO);
    //转化为大写拼音
    NSString *capitalStr = [str uppercaseString];
    //最终输出返回的转化好的字符串。
    NSMutableString * outputString = [NSMutableString string];
    //姓名中每个汉字的拼音首字母组成的字符串。
//    NSMutableString *firstCharactersStr = [NSMutableString string];
    [capitalStr enumerateSubstringsInRange:NSMakeRange(0, capitalStr.length) options:NSStringEnumerationByWords usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        //        NSLog(@"substring = %@",substring);
        [outputString appendFormat:@"%@",substring];
        
//        [firstCharactersStr appendFormat:@"%@",[substring substringToIndex:1]];
        
    }];
//    //将每个汉字的拼音首字母拼接在名字拼音后面，为了在用户搜索时输入名字简写拼音作比对用。
//    [outputString appendFormat:@"%@",firstCharactersStr];
    //返回用户名字大写拼写。
    return outputString;
}
/**遍历所有用户，将用户的名字的首字母，更新索引数组。*/
-(NSDictionary *)updateIndexKeys:(NSMutableArray *)itemsArray
{
    //NSLog(@"updateIndexKeys");
    NSMutableArray *tempItemsArray = itemsArray;
    NSString *allIndexStr = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ#";
    NSMutableArray *specialArray = [NSMutableArray array];
    NSMutableDictionary *sectionDic = [NSMutableDictionary dictionary];
    for (int i = 0; i < tempItemsArray.count; i++)
    {
        KKGChoiceItemModel *model = tempItemsArray[i];
        NSString *capitalSpell = [model.capitalSpell uppercaseString];
        if(capitalSpell.length)
        {
            NSString *letterKey = [capitalSpell substringWithRange:NSMakeRange(0, 1)];//字母标签
            if([allIndexStr rangeOfString:letterKey].location != NSNotFound&&[allIndexStr rangeOfString:letterKey].length)
            {
                NSMutableArray *sectionArray = sectionDic[letterKey];
                if(sectionArray)//如果存在，就直接拿来用
                {
                    [sectionArray addObject:model];
                }
                else//不存在创建一个添加赋值
                {
                    sectionArray = [NSMutableArray array];
                    [sectionArray addObject:model];
                    sectionDic[letterKey] = sectionArray;
                }
                
            }
            else
            {
                [specialArray addObject:model];
            }
        }
    }
    for (int i =0; i<self.indexKeysArray.count; i++)
    {
        NSString *letter = self.indexKeysArray[i];
        NSMutableArray *sectionArray = sectionDic[letter];
        
        
        if (sectionArray.count)//如果对应的索引字母下的用户个数不为空，就把此字母索引加入数组self.newIndexKeysArray中，作为索引。
        {
            [self.needIndexKeysArray addObject:letter];
            NSArray *sortsResultArray;
            
            
                sortsResultArray = [sectionArray sortedArrayUsingComparator:^(KKGChoiceItemModel *m1,KKGChoiceItemModel *m2) {
                    return [m1.wordPrefixSpell localizedCompare:m2.wordPrefixSpell];
                }];
            
            
            [self.itemDic setValue:sortsResultArray forKey:letter];//写入字典。
        }
        else
        {
            [self.needIndexKeysArray removeObject:letter];
            [self.itemDic removeObjectForKey:letter];
        }
        
    }
    if(specialArray.count)//特殊字符开头，那么挂在"#"一类
    {
        [self.needIndexKeysArray addObject:@"#"];
        NSArray *sortsResultArray = [specialArray sortedArrayUsingComparator:^(KKGChoiceItemModel *m1,KKGChoiceItemModel *m2) {
            return [m1.wordPrefixSpell localizedCompare:m2.wordPrefixSpell];
        }];
        //            NSArray *sortsResultArray = [[ChineseString LetterSortArray:[tempArray copy]] copy];
        [self.itemDic setValue:sortsResultArray forKey:@"#"];//写入字典。
    }
    else
    {
        [self.needIndexKeysArray removeObject:@"#"];
        [self.itemDic removeObjectForKey:@"#"];
    }
    NSDictionary *resultsDic = [NSDictionary dictionaryWithDictionary:[self.itemDic copy]];
    return resultsDic;
}
#pragma mark - - UISearchBarDelegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //NSLog(@"searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText===%@",searchText);
    
    [self searchTextByString:searchBar.text];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //NSLog(@"searchBarSearchButtonClicked:(UISearchBar *)searchBar");
    [searchBar resignFirstResponder];
    [self searchTextByString:searchBar.text];
    
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar;
{
    [searchBar resignFirstResponder];
    [self.view endEditing:YES];
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    //NSLog(@"searchBarCancelButtonClicked:(UISearchBar *)searchBar");
    [searchBar resignFirstResponder];
    [self searchTextByString:nil];
}

-(void)searchTextByString:(NSString *)searchText
{
    //去掉前后空格和回车符
    searchText = [searchText stringByTrimmingCharactersInSet:
                  [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (searchText == nil ||[searchText isEqualToString:@""])
    {
        self.searchResultsArray = self.allItemsArray;
        //NSLog(@"%lu",(unsigned long)self.allUsersArray.count);
        [self.searchBar resignFirstResponder];
    }
    else if (searchText.length == 1)
    {
//        NSLog(@"else if searchText.length == 1,%@",searchText);
        NSString *tempStr = searchText;
        tempStr = [self getNameCapitalSpell:tempStr];
        if(tempStr.length == 1)//满足此条件则证明输入的是单个字母。
        {
            
            NSString *str = searchText;
            str = [str uppercaseString];
            NSString *tempStr = @"0123456789";
            if([tempStr rangeOfString:str].location != NSNotFound&&[tempStr rangeOfString:str].length)
            {
                NSMutableArray * tempArray = [[NSMutableArray alloc] initWithCapacity:0];
                for (KKGChoiceItemModel *model in self.allItemsArray)
                {
                    
                    if(model.itemTitle&&model.itemTitle.length)
                    {
                        if([model.itemTitle rangeOfString:searchText].length > 0)
                        {
                            [tempArray addObject:model];
                        }
                    }
                    
                    
                }
                self.searchResultsArray = tempArray;
            }
            else
            {
                for (NSString *letter in self.indexKeysArray)
                {
                    if([str isEqualToString:letter])
                    {
                        self.searchResultsArray = self.allItemsDic[letter];
                    }
                }
            }
            
        }
        else//进入此条件则输入的是一个汉字。
        {
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (KKGChoiceItemModel *model in self.allItemsArray)
            {
                if(model.itemTitle&&model.itemTitle.length)
                {
                    if([model.itemTitle rangeOfString:searchText].length > 0)
                    {
                        [tempArray addObject:model];
                    }
                }
                
                
            }
            self.searchResultsArray = tempArray;
        }
    }
    else
    {
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
        for (KKGChoiceItemModel *model in self.allItemsArray)
        {
            
            if(model.itemTitle&&model.itemTitle.length)
            {
//                NSString *capitalSpell = [self getNameCapitalSpell:model.itemTitle];
                NSString *capitalSpell = model.capitalSpell;
                if (([model.itemTitle rangeOfString:searchText].length > 0)||([capitalSpell rangeOfString:[searchText uppercaseString]].length > 0) )
                {
                    //NSLog(@"userInfo.nameSpell = %@",userInfo.nameSpell);
                    [tempArray addObject:model];
                }
            }
            
            
            
        }
        self.searchResultsArray = tempArray;
    }
    [self.needIndexKeysArray removeAllObjects];
    //    [self.userDic removeAllObjects];
    [self updateIndexKeys:self.searchResultsArray];
    [self.tableView reloadData];
}
-(void)showKeyboard:(NSNotification *)notification
{
    //键盘出现后的位置
    CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = endFrame.size.height;
    if (keyboardHeight==0)
    {
        //解决搜狗输入法三次调用此方法的bug、
        //        IOS8.0之后可以安装第三方键盘，如搜狗输入法之类的。
        //        获得的高度都为0.这是因为键盘弹出的方法:- (void)keyBoardWillShow:(NSNotification *)notification需要执行三次,你如果打印一下,你会发现键盘高度为:第一次:0;第二次:216:第三次:282.并不是获取不到高度,而是第三次才获取真正的高度.
        return;
    }
    //键盘弹起时的动画效果
    UIViewAnimationOptions option = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
    //键盘动画时长
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration delay:0 options:option animations:^{
        self.tableView.frame = CGRectMake(0, self.tableView.frame.origin.y, self.view.frame.size.width, endFrame.origin.y - self.tableView.frame.origin.y);
    } completion:nil];
    [self.view layoutIfNeeded];
}
-(void)hideKeyboard:(NSNotification *)notification
{
    
    UIViewAnimationOptions option = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration delay:0 options:option animations:^{
        self.tableView.frame = CGRectMake(0, self.searchBar.frame.origin.y + self.searchBar.frame.size.height, SCREEN_W, SCREEN_H - SafeAreaBottomHeight - SafeAreaTopHeight - self.searchBar.frame.size.height);
        
    } completion:nil];
    
    [self.view layoutIfNeeded];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

/** 是否是汉字开头 */
-(BOOL)isChineseFirst:(NSString *)giveStr
{
    //是否以中文开头(unicode中文编码范围是0x4e00~0x9fa5)
    int utfCode = 0;
    void *buffer = &utfCode;
    NSRange range = NSMakeRange(0, 1);
    //判断是不是中文开头的，buffer->获取字符的字节数据 maxLength->buffer的最大长度
    //usedLength->实际写入的长度，不需要的话可以传递NULL encoding->字符编码常数，
    //不同编码方式转换后的字节长度是不一样的，这里我用了UTF16 Little-Endian,maxLength为2字节，
    //如果使用Unicode,则需要4字节 option->编码转换的选项，有两个值，分别是NSStringEncodingConversionAllowLossy和NSStringEncodingConversionExternalRepresentation
//    range->获取的字符串中的字符范围，这里设置的第一个字符 remainingRange->建议获取的范围，可以传递NULL
    
    BOOL b = [giveStr getBytes:buffer maxLength:2 usedLength:NULL encoding:NSUTF16LittleEndianStringEncoding options:NSStringEncodingConversionExternalRepresentation range:range remainingRange:NULL];
    if(b && (utfCode >= 0x4e00 && utfCode <= 0x9fa5))
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
    
    
}
/** 是否是字母开头 */
-(BOOL)isLetterFirst:(NSString *)giveStr
{
    NSString *predicateStr = @"^[A-Za-z]+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",predicateStr];
    return [predicate evaluateWithObject:giveStr];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
