//
//  MovieIndexViewController.m
//  rottentomato
//
//  Created by Xiao Jiang on 10/14/14.
//  Copyright (c) 2014 Xiao Jiang. All rights reserved.
//

#import "MovieIndexViewController.h"
#import "MovieCell.h"
#import "MovieDetailsViewController.h"
#import "SVProgressHUD.h"
#import "Movie.h"
#import "RottenTomatoesClient.h"

@interface MovieIndexViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *errorView;
@property (weak, nonatomic) IBOutlet UITabBar *tabBarView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarView;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSArray *movies;
@property (strong, nonatomic) NSArray *shownMovies;

@end

const NSUInteger TopBoxOfficeTab = 0;
const NSUInteger TopDVDRentalTab = 1;

@implementation MovieIndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Movies";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"MovieCell" bundle:nil] forCellReuseIdentifier:@"MovieCell"];
    
    self.tabBarView.delegate = self;
    [self.tabBarView setSelectedItem:[[self.tabBarView items] objectAtIndex:0]];
    
    self.refreshControl = [self registerRefreshView];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    self.searchBarView.delegate = self;
    self.searchBarView.showsCancelButton = YES;
    
    [self makeBoxOfficeAPIRequest];
}

- (UIRefreshControl *) registerRefreshView {
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    return refresh;
}

- (void (^)(NSArray *movies, NSError *error)) onRefreshCompletion {
    return ^void(NSArray *movies, NSError *error) {
        if (error) {
            [self.errorView setHidden:NO];
        } else {
            self.movies = movies;
            self.shownMovies = [self.movies copy];
            [self.tableView reloadData];
            [self.errorView setHidden:YES];
        }
        
        [self.refreshControl endRefreshing];
    };
}

- (void) onRefresh: (UIRefreshControl *)refresh {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(){

        NSUInteger indexOfTab = [[self.tabBarView items] indexOfObject:[self.tabBarView selectedItem]];
        
        if (indexOfTab == TopBoxOfficeTab) {
            [[RottenTomatoesClient sharedInstance] getTopBoxOffice:[self onRefreshCompletion]];
        } else {
            [[RottenTomatoesClient sharedInstance] getTopDVDRentals:[self onRefreshCompletion]];
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.shownMovies count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    if (!cell) {
        cell = [[MovieCell alloc] init];
    }
    Movie *movie = self.shownMovies[indexPath.row];
    [cell setMovie:movie];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MovieDetailsViewController *dvc = [[MovieDetailsViewController alloc] init];
    dvc.movie = self.shownMovies[indexPath.row];
    
    [self.navigationController pushViewController:dvc animated:YES];
}

- (void) tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSUInteger indexOfTab = [[tabBar items] indexOfObject:item];
    self.searchBarView.text = @"";
    if (indexOfTab == 0) {
        [self makeBoxOfficeAPIRequest];
    } else {
        [self makeDVDAPIRequest];
    }
}

- (void (^)(NSArray *movies, NSError *error)) onAPIRequestCompletion {
    return ^void(NSArray *movies, NSError *error) {
        if (error) {
            [self.errorView setHidden:NO];
        } else {
            self.movies = movies;
            self.shownMovies = [self.movies copy];
            [self.tableView reloadData];
            [self.errorView setHidden:YES];
        }
        [SVProgressHUD dismiss];
    };
}

- (void) makeBoxOfficeAPIRequest {
    [SVProgressHUD show];
    [[RottenTomatoesClient sharedInstance] getTopBoxOffice:[self onAPIRequestCompletion]];
}

- (void) makeDVDAPIRequest {
    [SVProgressHUD show];
    [[RottenTomatoesClient sharedInstance] getTopDVDRentals:[self onAPIRequestCompletion]];
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText compare:@""]) {
        NSString *lowerSearchText = [searchText lowercaseString];
        NSPredicate *containsSearchText = [NSPredicate predicateWithBlock:
                                           ^BOOL(id evaluatedObject, NSDictionary *bindings) {
                                               Movie *movie = evaluatedObject;
                                               return [[movie.title lowercaseString] containsString:lowerSearchText];
                                           }];
        self.shownMovies = [self.movies filteredArrayUsingPredicate:containsSearchText];
    } else {
        self.shownMovies = [self.movies copy];
    }
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    self.shownMovies = [self.movies copy];
    [self.tableView reloadData];
    [searchBar resignFirstResponder];
}

@end
