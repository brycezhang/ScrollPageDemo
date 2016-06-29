//
//  ViewController.m
//  ScrollPageDemo
//
//  Created by zhanghanbing on 16/6/29.
//  Copyright © 2016年 Bryce. All rights reserved.
//

#import "TableViewController.h"
#import "ViewController.h"

@interface ViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *verticalScrollView;
@property (nonatomic, strong) UIScrollView *horizontalScrollView;

@property (nonatomic, strong) UILabel *headerView;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _verticalScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _verticalScrollView.alwaysBounceVertical = YES;
    _verticalScrollView.delegate = self;
    _verticalScrollView.contentInset = UIEdgeInsetsMake(240, 0, 0, 0);
    _verticalScrollView.scrollIndicatorInsets = UIEdgeInsetsMake(240, 0, 0, 0);
    [self.view addSubview:_verticalScrollView];

    _headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, -240, CGRectGetWidth(self.view.bounds), 200)];
    _headerView.backgroundColor = [UIColor orangeColor];
    _headerView.text = @"Header";
    _headerView.textAlignment = NSTextAlignmentCenter;
    [_verticalScrollView addSubview:_headerView];

    _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"item0", @"item1", @"item2"]];
    _segmentedControl.frame = CGRectMake(0, -40, CGRectGetWidth(self.view.bounds), 40);
    _segmentedControl.backgroundColor = [UIColor whiteColor];
    [_segmentedControl addTarget:self action:@selector(didSelectedChange:) forControlEvents:UIControlEventValueChanged];
    [_verticalScrollView addSubview:_segmentedControl];

    _horizontalScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 240)];
    _horizontalScrollView.contentSize = CGSizeMake(self.view.frame.size.width * 3, CGRectGetHeight(self.view.bounds) - 240);
    _horizontalScrollView.pagingEnabled = YES;
    _horizontalScrollView.delegate = self;
    _horizontalScrollView.bounces = NO;
    _horizontalScrollView.backgroundColor = [UIColor grayColor];
    [_verticalScrollView addSubview:_horizontalScrollView];

    TableViewController *fVC = [[TableViewController alloc] init];
    [self addChildViewController:fVC];
    [_horizontalScrollView addSubview:fVC.view];
    fVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [fVC.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:(__bridge void *_Nullable)((fVC.tableView))];

    TableViewController *sVC = [[TableViewController alloc] init];
    [self addChildViewController:sVC];
    [_horizontalScrollView addSubview:sVC.view];
    sVC.view.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
    [sVC.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:(__bridge void *_Nullable)(sVC.tableView)];

    TableViewController *tVC = [[TableViewController alloc] init];
    [self addChildViewController:tVC];
    [_horizontalScrollView addSubview:tVC.view];
    tVC.view.frame = CGRectMake(self.view.frame.size.width*2, 0, self.view.frame.size.width, self.view.frame.size.height);
    [tVC.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:(__bridge void *_Nullable)(tVC.tableView)];

    [_verticalScrollView bringSubviewToFront:self.segmentedControl];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *, id> *)change context:(void *)context
{
    UITableView *tableView = (__bridge UITableView *)context;
    CGRect originFrame = tableView.frame;
    tableView.frame = CGRectMake(originFrame.origin.x, originFrame.origin.y, tableView.contentSize.width, tableView.contentSize.height);
    CGFloat maxHeight = MAX(tableView.contentSize.height, CGRectGetHeight(self.view.bounds));

    CGRect frame = self.horizontalScrollView.frame;
    frame.size.height = maxHeight;
    self.horizontalScrollView.frame = frame;
    self.horizontalScrollView.contentSize = CGSizeMake(self.horizontalScrollView.contentSize.width, maxHeight);
    self.verticalScrollView.contentSize = CGSizeMake(0, maxHeight);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _verticalScrollView) {
        CGRect frame = self.segmentedControl.frame;
        CGFloat height = frame.size.height;

        if (scrollView.contentOffset.y > -height) {
            frame.origin.y = scrollView.contentOffset.y;
        } else {
            frame.origin.y = -height;
        }
        self.segmentedControl.frame = frame;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _horizontalScrollView) {
        CGFloat pageWidth = scrollView.frame.size.width;

        NSInteger currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        [_horizontalScrollView setContentOffset:CGPointMake(CGRectGetWidth(self.view.bounds) * currentPage, 0)];
        _segmentedControl.selectedSegmentIndex = currentPage;

        UITableViewController *currentVC = self.childViewControllers[currentPage];
        CGFloat maxHeight = MAX(currentVC.tableView.contentSize.height, CGRectGetHeight(self.view.bounds));

        _verticalScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), maxHeight);
        _horizontalScrollView.contentSize = CGSizeMake(self.horizontalScrollView.contentSize.width, maxHeight);

        CGRect frame = _horizontalScrollView.frame;
        frame.size.height = maxHeight;
        _horizontalScrollView.frame = frame;
    }
}

#pragma mark - Actions

- (void)didSelectedChange:(UISegmentedControl *)sender
{
    [_horizontalScrollView setContentOffset:CGPointMake(CGRectGetWidth(self.view.bounds) * sender.selectedSegmentIndex, 0) animated:YES];
}

@end
