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
@property (weak, nonatomic) IBOutlet UIView *networkError;

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
    
    [self loadMovieData];
    [self.tableView registerNib:[UINib nibWithNibName:@"MovieCell" bundle:nil] forCellReuseIdentifier:@"MovieCell"] ;
    self.tableView.rowHeight = 150;
    
    /* adding pull to refresh feature */
     [self pullToRefreshSetUp];
    
    /* Check network status*/
    if (![self connected]) {
        [notificationLabel setHidden:FALSE];
        notificationLabel.text = @"Network Error!";
        
    }
}

- (void)pullToRefreshSetUp {
    //alloc a table view controller and then point it to this view controller's tableview
    UITableViewController *tvc = [[UITableViewController alloc] init];
    tvc.tableView = self.tableView;
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor grayColor];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    tvc.refreshControl = refresh;
}

-(void) loadMovieData {
    /* Call the rotten tomatoes API for Movies */
    NSString *url = @"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=p7jsqc4cszn4k3vhxe9kgmr3";
    /* Loading Spinner while waiting for the API */
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if(connectionError) {
                UIView *errorView = [[UIView alloc] initWithFrame:CGRectMake(0, 300, 320, 35)];
                UILabel *errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 5, 200, 20)];
                errorLabel.text = @"Network Error";
                errorLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
                errorView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
                [errorView addSubview:errorLabel];
                self.tableView.tableHeaderView = errorView;
            }else {
                self.tableView.tableHeaderView = nil;
            }
            if(data){
                id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                self.movies = object[@"movies"];
                [self.tableView reloadData];
            }
            
        }];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    

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
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:(76.0/255.0) green:(161.0/255.0) blue:(10.0/10.0) alpha:1.0];
    bgColorView.layer.masksToBounds = YES;
    cell.selectedBackgroundView = bgColorView;
    return cell;
}

@end
