//
//  movieDetailViewController.m
//  Rotten Tomatoes
//
//  Created by Pragya  Pherwani on 6/8/14.
//  Copyright (c) 2014 Pragya  Pherwani. All rights reserved.
//
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "movieDetailViewController.h"

@interface movieDetailViewController ()

@end

@implementation movieDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.detailMovieTitle.text = [movieTitle description];
    self.detailSynopsis.text = [movieSynopsis description];
    NSString *imageUrl = [movieImageUrl description];
    NSURL *url = [NSURL URLWithString:imageUrl];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
    [self.detailPoster setImageWithURLRequest:urlRequest placeholderImage:[UIImage imageNamed:@"default"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        self.detailPoster.image = image;
    }
                    failure:nil];
    self.detailPoster.alpha = 0.0;
    [UIView animateWithDuration:0.5 animations:^{
        self.detailPoster.alpha = 1.0;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end