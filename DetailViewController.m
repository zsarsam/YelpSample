//
//  DetailViewController.m
//  YelpSample
//
//  Created by Zaid Sarsam on 11/29/15.
//  Copyright © 2015 sarsam. All rights reserved.
//

#import "DetailViewController.h"
#import "NSURLRequest+OAuth.h"
#import "BusinessModel.h"
#import "DetailBusinessModel.h"
#import "UIImageView+AFNetworking.h"
#import "YelpApiManager.h"

static NSString * const kAPIHost           = @"api.yelp.com";
static NSString * const kSearchPath        = @"/v2/search/";
static NSString * const kBusinessPath      = @"/v2/business/";

@interface DetailViewController ()

@property (strong, nonatomic) DetailBusinessModel *currentModel;
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.website.backgroundColor = [UIColor redColor];
    // Do any additional setup after loading the view.
}

-(void) setBusinessModel:(BusinessModel*)model {
    // do something
    [YelpApiManager queryTopBusinessInfoForTerm:model.businessID completionHandler:^(DetailBusinessModel *model, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
             // code here
            
            self.currentModel = model;
            self.name.text = model.name;
            
            [self.ratingImage setImageWithURL:[NSURL URLWithString:model.imageURL]];
            self.ratingImage.contentMode = UIViewContentModeScaleAspectFit;
            self.reviewCounts.text = [NSString stringWithFormat:@"%@ reviews",model.reviewCount];
            
            [self.userImage setImageWithURL:[NSURL URLWithString:model.reviews.userImage]];
            self.userImage.contentMode = UIViewContentModeScaleAspectFit;
            self.userName.text = model.reviews.user;
            [self.userRatingImage setImageWithURL:[NSURL URLWithString:model.reviews.userRatingImage]];
            self.userRatingImage.contentMode = UIViewContentModeScaleAspectFit;
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[model.reviews.timeCreated integerValue]];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yyyy-mm-dd "];
            
            NSString *dateString = [formatter stringFromDate:date];
            self.date.text = dateString;
            
            self.review.text = model.reviews.excerpt;
            [self.review sizeToFit];
            
            self.address.text = model.address ;
         });
    }];
}
- (IBAction)openWebsite:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.currentModel.url]];
}

@end
