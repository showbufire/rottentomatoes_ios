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

@end

@implementation MovieIndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.title = @"Movies";
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MovieCell" bundle:nil] forCellReuseIdentifier:@"MovieCell"];
    [SVProgressHUD show];
    
    [self makeAPICall];
    self.refreshControl = [self registerRefreshView];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (UIRefreshControl *) registerRefreshView {
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    return refresh;
}

- (NSURL *) getRequestURL {
    NSString *apiKey = @"yt2y9kbakprqz9ne9kumm47g";
    NSString *urlString = [NSString stringWithFormat:@"http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=%@", apiKey];
    return [NSURL URLWithString:urlString];
}

- (void) onRefresh: (UIRefreshControl *)refresh {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(){
      NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[self getRequestURL]];
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

- (void)makeAPICall {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[self getRequestURL]];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
