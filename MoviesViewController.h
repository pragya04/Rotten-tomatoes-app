//
//  MoviesViewController.h
//  Rotten Tomatoes
//
//  Created by Pragya  Pherwani on 6/5/14.
//  Copyright (c) 2014 Pragya  Pherwani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoviesViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *notificationLabel;


@end
