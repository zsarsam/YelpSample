//
//  DetailBusinessModel.h
//  YelpSample
//
//  Created by Zaid Sarsam on 11/30/15.
//  Copyright © 2015 sarsam. All rights reserved.
//

#import "BusinessModel.h"

@interface ReviewModel : NSObject

@property (strong,nonatomic) NSString* excerpt;
@property (strong,nonatomic) NSString* rating;
@property (strong,nonatomic) NSString* ratingImage;

@end

@interface DetailBusinessModel : BusinessModel

@property (strong,nonatomic) NSString* phoneNumber;
@property (strong,nonatomic) ReviewModel* reviews;
@property (strong,nonatomic) NSString* reviewCount;
@property (strong,nonatomic) NSString* snippetText;
@property (strong,nonatomic) NSString* snippetImageUrl;


@end


