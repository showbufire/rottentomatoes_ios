//
//  MovieCell.m
//  rottentomato
//
//  Created by Xiao Jiang on 10/14/14.
//  Copyright (c) 2014 Xiao Jiang. All rights reserved.
//

#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"

@interface MovieCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@end


@implementation MovieCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) setMovie:(Movie *)movie {
    self.titleLabel.text = movie.title;
    self.synopsisLabel.text = movie.synopsis;
    [self.imgView setImageWithURL:movie.thumbnail];
}

@end
