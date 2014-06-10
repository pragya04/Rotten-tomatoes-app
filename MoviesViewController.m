//
//  MoviesViewController.m
//  Rotten Tomatoes
//
//  Created by Pragya  Pherwani on 6/5/14.
//  Copyright (c) 2014 Pragya  Pherwani. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "MoviesViewController.h"
#import "MovieCell.h"
#import "movieDetailViewController.h"
#import "Reachability.h"
#import <MBProgressHUD.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface MoviesViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *movies;

@end

@implementation MoviesViewController
@synthesize notificationLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Movies";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    /* Call the rotten tomatoes API for Movies */
    NSString *url = @"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=p7jsqc4cszn4k3vhxe9kgmr3";
    
    /* Loading Spinner while waiting for the API */
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            self.movies = object[@"movies"];
            [self.tableView reloadData];
            
        }];

        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MovieCell" bundle:nil] forCellReuseIdentifier:@"MovieCell"] ;
    self.tableView.rowHeight = 150;
    
    /* adding pull to refresh feature */
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull To Refresh"];
    [self.tableView addSubview:refreshControl];
    
    /* Check network status*/
    if (![self connected]) {
        [notificationLabel setHidden:FALSE];
        notificationLabel.text = @"Network Error!";
        
    }
}

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}


- (void)refresh:(UIRefreshControl *)refreshControl {
    [refreshControl endRefreshing];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *selectedMovie = self.movies[indexPath.row];
    movieDetailViewController *detailViewController = [[movieDetailViewController alloc] initWithNibName:@"movieDetailViewController" bundle:nil];
    
    detailViewController->movieTitle = selectedMovie[@"title"];
    detailViewController->movieSynopsis = selectedMovie[@"synopsis"];
    detailViewController->movieYear = selectedMovie[@"year"];
    NSDictionary *imgurl = selectedMovie[@"posters"];
    detailViewController->movieImageUrl = imgurl[@"detailed"];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - table view methods
- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    NSDictionary *movie = self.movies[indexPath.row];
    cell.movieTitle.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"synopsis"];
    
    NSDictionary *posters = movie[@"posters"];
    NSString *imageUrl = posters[@"thumbnail"];
    
    NSURL *url = [NSURL URLWithString:imageUrl];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
    [cell.posterView setImageWithURLRequest:urlRequest placeholderImage:[UIImage imageNamed:@"default"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        cell.posterView.image = image;
    }
    failure:nil];
    return cell;
}

@end
