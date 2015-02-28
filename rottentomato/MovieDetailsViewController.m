//
//  MovieDetailsViewController.m
//  rottentomato
//
//  Created by Xiao Jiang on 10/19/14.
//  Copyright (c) 2014 Xiao Jiang. All rights reserved.
//

#import "MovieDetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MovieDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *synopsisView;

- (NSString *) getHighResPosterURL;

@end

@implementation MovieDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    self.titleView.text = self.movie.title;
    self.synopsisView.text = self.movie.synopsis;
    NSString *highResPosterURL = [self getHighResPosterURL];
    [self.posterView setImageWithURL:[NSURL URLWithString:highResPosterURL]];
}

- (NSString *) getHighResPosterURL{
    return [[self.movie.thumbnail absoluteString] stringByReplacingOccurrencesOfString:@"_tmb" withString:@"_hud"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
