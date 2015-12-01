//
//  YelpApiManager.m
//  YelpSample
//
//  Created by Zaid Sarsam on 11/30/15.
//  Copyright © 2015 sarsam. All rights reserved.
//

#import "YelpApiManager.h"
#import "NSURLRequest+OAuth.h"
#import "BusinessModel.h"
#import "DetailBusinessModel.h"

static NSString * const kAPIHost           = @"api.yelp.com";
static NSString * const kSearchPath        = @"/v2/search/";
static NSString * const kBusinessPath      = @"/v2/business/";

static NSString * const kSearchLimit       = @"10";

@implementation YelpApiManager



#pragma mark Yelp Helper functions

+ (void)queryTopBusinessInfoForTerm:(NSString *)term location:(NSString *)location completionHandler:(void (^)(NSArray *businesses, NSError *error))completionHandler {
    
    NSLog(@"Querying the Search API with term \'%@\' and location \'%@'", term, location);
    
    NSURLRequest *searchRequest = [YelpApiManager _searchRequestWithTerm:term location:location];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:searchRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        if (!error && httpResponse.statusCode == 200) {
            
            NSDictionary *searchResponseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSArray *businessArray = searchResponseJSON[@"businesses"];
            
            if ([businessArray count] > 0) {
                
                NSMutableArray* businesses = [[NSMutableArray alloc] init];
                
                for( NSDictionary* business in businessArray){
                    BusinessModel *model =  [[BusinessModel alloc] init];
                    model.name = business[@"name"];
                    model.businessID = business[@"id"];
                    model.imageURL = business[@"image_url"];
                    model.url = business[@"url"];
                    
                    [businesses addObject:model];
                }
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
 Builds a request to hit the search endpoint with the given parameters.
 
 @param term The term of the search, e.g: dinner
 @param location The location request, e.g: San Francisco, CA
 
 @return The NSURLRequest needed to perform the search
 */
+ (NSURLRequest *)_searchRequestWithTerm:(NSString *)term location:(NSString *)location {
    NSDictionary *params = @{
                             @"term" : term,
                             @"cc": @"CA",
                             @"sort": @"2",
                             @"location": location,
                             @"limit": kSearchLimit
                             };
    
    return [NSURLRequest requestWithHost:kAPIHost path:kSearchPath params:params];
}


+ (void)queryTopBusinessInfoForTerm:(NSString *)businessID completionHandler:(void (^)(DetailBusinessModel *model, NSError *error))completionHandler {
    
    
    //Make a first request to get the search results with the passed term and location
    
    //https://api.yelp.com/v2/business/keeffaa-ethiopian-toronto?cc=CA
    // [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.yelp.com/v2/search/?location=toronto&limit=10&cc=CA&category_filter=ethiopian"]];
    NSURLRequest *searchRequest = [YelpApiManager _businessInfoRequestForID:businessID];
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
+ (NSURLRequest *)_businessInfoRequestForID:(NSString *)businessID {
    
    NSString *businessPath = [NSString stringWithFormat:@"%@%@", kBusinessPath, businessID];
    return [NSURLRequest requestWithHost:kAPIHost path:businessPath];
}

@end
