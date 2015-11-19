//
//  ViewController.m
//  考试样例
//
//  Created by zhengjing on 15/8/25.
//  Copyright (c) 2015年 zhengjing. All rights reserved.
//


/*
 
    网络请求地址
    @"http://www.ecbaby.com/index.php?a=msglist&c=iosapp&keywards=吃饭&page=1";
    
    解析步骤，用AFNetwork解析上面地址的数据，加载到UI界面上
    集成MJRefresh下拉刷新和上拉加载更多
    下拉刷新当前页数 page=1
    上拉加载跟多每次page+=1
    刷新tableview
    注意：上拉刷新和下拉刷新的逻辑要考虑清楚。
    返回参数里面有一个参数是 description，和系统冲突记得处理一下
 
 */

#import "ViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <MJRefresh/MJRefresh.h>
#import "JYArticleTableViewCell.h"
#import "JYArticle.h"
#import "MJExtension.h"
#import <MJRefresh/MJRefresh.h>

/*使用这种方式定义常量，比通过宏预定义的优点是，可以对常量进行指针比较操作(比如:[myURL isEqualToString:kInitURL];)，这是#define做不到的。const关键字表示变量是常量，不可修改。在objc的约定里，常量也是大小写混排的驼峰命名规则，首字母小写，另外，第一个字母是k。标准C中const定义的变量是外连接的，即如果一个编译单元中定义了一个全局const常量，则其在其他编译单元中是可见的，如果其他编译单元也定义了同名const常量就会产生重复定义错误。这一点与C++不同，C++中const定义的变量是内连接的，即每个编译单元定义的全局const常量是自己独有的。Objective-C是标准C的另一种扩展，为了防止重复定义使得编译器报错,可以定义的常量前加一个static关键字,这里的static是用来把定义的const常量标记为对外不可见的,即该常量的作用域只为当前文件。
 */
static NSString * const kArticleCellIdentifier = @"com.joyann.article.cell.identifier";
static NSString * const kFetchDataBaseURLString = @"http://www.ecbaby.com/index.php";

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *articles;
@property (nonatomic, strong) MJRefreshNormalHeader *header;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self addTableView];
    
    self.tableView.rowHeight = 80;
    
    [self addRefresher];
    [self addFooterReferesher];
}

#pragma mark - Load Data

- (NSArray *)articles
{
    if (!_articles) {
        AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
        NSDictionary *parameters = @{
                                     @"a": @"msglist",
                                     @"c": @"iosapp",
                                     @"keywards": @"吃饭",
                                     @"page": @"1"
                                     };
        [sessionManager GET:kFetchDataBaseURLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            [JYArticle setupReplacedKeyFromPropertyName:^NSDictionary *{
                return @{
                         @"articleDescription": @"description"
                         };
            }];
            _articles = [self setUpModelWithResponseObject: responseObject];
            [self.tableView reloadData];
            
            [self.header endRefreshing];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"%@",error);
        }];
    }
    return _articles;
}

#pragma mark - Private Methdos

- (void)addRefresher
{
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.articles = nil;
        [self.tableView reloadData];
    }];
    self.header = header;
    self.tableView.header = header;
}

- (void)addFooterReferesher
{
    MJRefreshAutoGifFooter *footer = [MJRefreshAutoGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    // 设置刷新图片
    [footer setTitle:@"上拉刷新" forState:MJRefreshStateIdle];
    
    // 设置尾部
    self.tableView.footer = footer;
}

- (void)loadMoreData
{
    // 上拉重新设置请求参数, 来不及做了.
}

// 字典 -> 模型

- (NSArray *)setUpModelWithResponseObject: (NSDictionary *)responseObject
{
    NSArray *data = responseObject[@"data"];
    // 数组 -> 模型
    return [JYArticle objectArrayWithKeyValuesArray:data];
}

- (void)addTableView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.articles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JYArticleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kArticleCellIdentifier];
    if (cell == nil) {
        cell = [[JYArticleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kArticleCellIdentifier];
    }
    JYArticle *article = self.articles[indexPath.row];
    cell.article = article;
    
    return cell;
}

#pragma mark - UITableViewDelegate

@end
