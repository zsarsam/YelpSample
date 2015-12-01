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
    [self queryTopBusinessInfoForTerm:model.businessID completionHandler:^(DetailBusinessModel *model, NSError *error) {
        
       
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


#pragma mark Yelp Helper functions

- (void)queryTopBusinessInfoForTerm:(NSString *)businessID completionHandler:(void (^)(DetailBusinessModel *model, NSError *error))completionHandler {
    
    
    //Make a first request to get the search results with the passed term and location
    
    //https://api.yelp.com/v2/business/keeffaa-ethiopian-toronto?cc=CA
    // [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.yelp.com/v2/search/?location=toronto&limit=10&cc=CA&category_filter=ethiopian"]];
    NSURLRequest *searchRequest = [self _businessInfoRequestForID:businessID];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:searchRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        if (!error && httpResponse.statusCode == 200) {
            
            NSDictionary *searchResponseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            DetailBusinessModel *model = [[DetailBusinessModel alloc] init];
            
            model.name = searchResponseJSON[@"name"];
            model.url = searchResponseJSON[@"mobile_url"];
            model.reviewCount = searchResponseJSON[@"review_count"];
            model.imageURL = searchResponseJSON[@"rating_img_url"];
            model.phoneNumber = searchResponseJSON[@"phone"];
            NSDictionary *locations = searchResponseJSON[@"location"];
            NSArray* addressArray = locations[@"display_address"];
            model.address = [[addressArray valueForKey:@"description"] componentsJoinedByString:@" "];
            
            // setting up the review model
            model.reviews = [[ReviewModel alloc] init];
            
            NSArray* reviewsArray = searchResponseJSON[@"reviews"];
            NSDictionary *reviewsJSON = reviewsArray[0];
            model.reviews.excerpt = reviewsJSON[@"excerpt"];
            model.reviews.rating = reviewsJSON[@"rating"];
            model.reviews.userRatingImage =  reviewsJSON[@"rating_image_url"];
            model.reviews.timeCreated = reviewsJSON[@"time_created"];
            
            NSDictionary *user = reviewsJSON[@"user"];
            model.reviews.user = user[@"name"];
            model.reviews.userImage = user[@"image_url"];
           
            
            completionHandler(model, error); // No business was found
            
        } else {
            completionHandler(nil, error); // An error happened or the HTTP response is not a 200 OK
        }
    }] resume];
}

/**
 Builds a request to hit the business endpoint with the given business ID.
 
 @param businessID The id of the business for which we request informations
 
 @return The NSURLRequest needed to query the business info
 */
- (NSURLRequest *)_businessInfoRequestForID:(NSString *)businessID {
    
    NSString *businessPath = [NSString stringWithFormat:@"%@%@", kBusinessPath, businessID];
    return [NSURLRequest requestWithHost:kAPIHost path:businessPath];
}

- (IBAction)openWebsite:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.currentModel.url]];
}
- (IBAction)openAddress:(id)sender {
}

@end
