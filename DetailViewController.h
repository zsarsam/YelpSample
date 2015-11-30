//
//  DetailViewController.h
//  YelpSample
//
//  Created by Zaid Sarsam on 11/29/15.
//  Copyright © 2015 sarsam. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BusinessModel;

@interface DetailViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UIImageView *ratingImage;

@property (strong, nonatomic) IBOutlet UILabel *reviewCounts;
@property (strong, nonatomic) IBOutlet UILabel *status;

-(void) setBusinessModel:(BusinessModel*)model;

@end
