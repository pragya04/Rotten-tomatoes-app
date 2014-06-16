//
//  topDvdsViewController.m
//  Rotten Tomatoes
//
//  Created by Pragya  Pherwani on 6/15/14.
//  Copyright (c) 2014 Pragya  Pherwani. All rights reserved.
//

#import "topDvdsViewController.h"
#import "MovieCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "movieDetailViewController.h"
#import <MBProgressHUD.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface topDvdsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dvds;

@end

@implementation topDvdsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Top DVD Rentals";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self loadDVDData];
    [self.tableView registerNib:[UINib nibWithNibName:@"MovieCell" bundle:nil] forCellReuseIdentifier:@"MovieCell"] ;
    self.tableView.rowHeight = 150;


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) loadDVDData {
    /* Call the rotten tomatoes API for Movies */
    NSString *url = @"http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=p7jsqc4cszn4k3vhxe9kgmr3";
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
                self.dvds = object[@"movies"];
                [self.tableView reloadData];
            }
            
        }];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *selectedDVD = self.dvds[indexPath.row];
    movieDetailViewController *detailViewController = [[movieDetailViewController alloc] initWithNibName:@"movieDetailViewController" bundle:nil];
    
    detailViewController->movieTitle = selectedDVD[@"title"];
    detailViewController->movieSynopsis = selectedDVD[@"synopsis"];
    NSDictionary *imgurl = selectedDVD[@"posters"];
    detailViewController->movieImageUrl = imgurl[@"original"];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - table view methods
- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    NSDictionary *dvd = self.dvds[indexPath.row];
    cell.movieTitle.text = dvd[@"title"];
    cell.synopsisLabel.text = dvd[@"synopsis"];
    
    NSDictionary *posters = dvd[@"posters"];
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
