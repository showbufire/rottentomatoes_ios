//
//  MovieIndexViewController.m
//  rottentomato
//
//  Created by Xiao Jiang on 10/14/14.
//  Copyright (c) 2014 Xiao Jiang. All rights reserved.
//

#import "MovieIndexViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"
#import "MovieDetailsViewController.h"
#import "SVProgressHUD.h"

@interface MovieIndexViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *movies;
@property (weak, nonatomic) IBOutlet UILabel *errorView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UITabBar *tabBarView;

@end

@implementation MovieIndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Movies";
    
    // init table view
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"MovieCell" bundle:nil] forCellReuseIdentifier:@"MovieCell"];
    
    // init tab view
    self.tabBarView.delegate = self;
    [self.tabBarView setSelectedItem:[[self.tabBarView items] objectAtIndex:0]];
    
    // init refresh control
    self.refreshControl = [self registerRefreshView];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    // load data
    [self makeBoxOfficeAPIRequest];
}

- (UIRefreshControl *) registerRefreshView {
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    return refresh;
}

- (NSString *) getAPIKey {
    return @"yt2y9kbakprqz9ne9kumm47g";
}

- (NSURL *) getBoxOfficeURL {
    NSString *urlString = [NSString stringWithFormat:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=%@", [self getAPIKey]];
    return [NSURL URLWithString:urlString];
}

- (NSURL *) getDVDRequestURL {
    NSString *urlString = [NSString stringWithFormat:@"http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=%@", [self getAPIKey]];
    return [NSURL URLWithString:urlString];
}

- (void) onRefresh: (UIRefreshControl *)refresh {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(){

        NSUInteger indexOfTab = [[self.tabBarView items] indexOfObject:[self.tabBarView selectedItem]];
        NSURL *url = Nil;
        if (indexOfTab == 0){
            url = [self getBoxOfficeURL];
        } else {
            url = [self getDVDRequestURL];
        }
      
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            // uncomment to simulate an network error
            // error = [NSError alloc];
        
            if (error == nil) {
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                self.movies = responseDictionary[@"movies"];
                [self.tableView reloadData];
                [self.errorView setHidden:YES];
            } else {
                [self.errorView setHidden:NO];
            }
            [self.refreshControl endRefreshing];
      }];
    });
}

- (void)makeAPIRequest:(NSURL *) url {
    [SVProgressHUD show];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        // uncomment to simulate an network error
        // error = [NSError alloc];
        
        if (error == nil) {
          NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
          self.movies = responseDictionary[@"movies"];
          [self.tableView reloadData];
          [self.errorView setHidden:YES];
        } else {
          [self.errorView setHidden:NO];
        }
        [SVProgressHUD dismiss];
    }];
}

- (void)makeDVDAPIRequest {
    [self makeAPIRequest:[self getDVDRequestURL]];
}

- (void)makeBoxOfficeAPIRequest {
    [self makeAPIRequest:[self getBoxOfficeURL]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.movies count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    NSDictionary *movie = self.movies[indexPath.row];
    cell.titleLabel.text = movie[@"title"];
    cell.synoposisLabel.text = movie[@"synopsis"];
    NSString *thumbnailURL = [movie valueForKeyPath:@"posters.thumbnail"];
    [cell.imgView setImageWithURL:[NSURL URLWithString:thumbnailURL]];

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MovieDetailsViewController *dvc = [[MovieDetailsViewController alloc] init];
    dvc.movie = self.movies[indexPath.row];
    
    [self.navigationController pushViewController:dvc animated:YES];
}

- (void) tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSUInteger indexOfTab = [[tabBar items] indexOfObject:item];
    if (indexOfTab == 0) {
        [self makeBoxOfficeAPIRequest];
    } else {
        [self makeDVDAPIRequest];
    }
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
