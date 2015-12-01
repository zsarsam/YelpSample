//
//  YelpApiManager.h
//  YelpSample
//
//  Created by Zaid Sarsam on 11/30/15.
//  Copyright © 2015 sarsam. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DetailBusinessModel;

@interface YelpApiManager : NSObject


/**
 @param term search term
 @param location temp hardcoded to "toronto"
 @param completionHandler
*/
+ (void)queryTopBusinessInfoForTerm:(NSString *)term location:(NSString *)location completionHandler:(void (^)(NSArray *businesses, NSError *error))completionHandler ;

/**
 @param businessID the ID required for Bussiness search
 @param completionHandler with DetailBusinessModel (Details model for the buessiess returned by services ) and error
*/
+ (void)queryTopBusinessInfoForTerm:(NSString *)businessID completionHandler:(void (^)(DetailBusinessModel *model, NSError *error))completionHandler;

/**
 @param term search term
 @param location temp hardcoded to "toronto"
 @return Builds a NSURLRequest with all the OAuth headers field set with the host and path given to it.
 */
+ (NSURLRequest *)_searchRequestWithTerm:(NSString *)term location:(NSString *)location ;

/**
 @param businessID the ID required for Bussiness search
 @return Builds a NSURLRequest with all the OAuth headers field set with the host and path given to it.
 */
+ (NSURLRequest *)_businessInfoRequestForID:(NSString *)businessID;

@end
