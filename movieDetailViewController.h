//
//  movieDetailViewController.h
//  Rotten Tomatoes
//
//  Created by Pragya  Pherwani on 6/8/14.
//  Copyright (c) 2014 Pragya  Pherwani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface movieDetailViewController : UIViewController
{
    @public NSString *movieTitle;
    @public NSString *movieSynopsis;
    @public NSString *movieImageUrl;
    @public NSString *movieYear;
}
@property (weak, nonatomic) IBOutlet UIImageView *detailPoster;
@property (weak, nonatomic) IBOutlet UILabel *detailMovieTitle;
@property (weak, nonatomic) IBOutlet UITextView *detailSynopsis;
@property (weak, nonatomic) IBOutlet UILabel *detailMovieYear;



@end
