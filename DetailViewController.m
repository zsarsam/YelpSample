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
    [self queryTopBusinessInfoForTerm:model.businessID completionHandler:^(NSArray *businesses, NSError *error) {
//        self.businessModels = [NSArray arrayWithArray:businesses];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            // code here
//            [self.collectionView reloadData];
//        });
    }];

}


#pragma mark Yelp Helper functions

- (void)queryTopBusinessInfoForTerm:(NSString *)businessID completionHandler:(void (^)(NSArray *businesses, NSError *error))completionHandler {
    
    
    //Make a first request to get the search results with the passed term and location
    
    //https://api.yelp.com/v2/business/keeffaa-ethiopian-toronto?cc=CA
    // [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.yelp.com/v2/search/?location=toronto&limit=10&cc=CA&category_filter=ethiopian"]];
    NSURLRequest *searchRequest = [self _businessInfoRequestForID:businessID];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:searchRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        if (!error && httpResponse.statusCode == 200) {
            
            
            
            NSDictionary *searchResponseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSArray *businessArray = searchResponseJSON[@"businesses"];
            
            if ([businessArray count] > 0) {
                
                NSMutableArray* businesses = [[NSMutableArray alloc] init];
                
//                for( NSDictionary* business in businessArray){
//                    BusinessModel *model =  [[BusinessModel alloc] init];
//                    model.name = business[@"name"];
//                    model.businessID = business[@"id"];
//                    model.imageURL = business[@"image_url"];
//                    model.url = business[@"url"];
//                    
//                    [businesses addObject:model];
//                }
                completionHandler(businesses, nil);
                
            } else {
                completionHandler(nil, error); // No business was found
            }
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
