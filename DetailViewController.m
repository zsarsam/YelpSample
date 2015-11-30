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

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setBusinessModel:(BusinessModel*)model {
    // do something
    [self queryTopBusinessInfoForTerm:model.businessID completionHandler:^(DetailBusinessModel *model, NSError *error) {
        
       
        dispatch_async(dispatch_get_main_queue(), ^{
             // code here
             self.name.text = model.name;
            
            [self.ratingImage setImageWithURL:[NSURL URLWithString:model.imageURL]];
            self.ratingImage.contentMode = UIViewContentModeScaleAspectFit;
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
            
            // setting up the review model
            model.reviews = [[ReviewModel alloc] init];
            
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
