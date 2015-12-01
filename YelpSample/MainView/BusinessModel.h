//
//  BusinessModel.h
//  YelpSample
//
//  Created by Zaid Sarsam on 11/29/15.
//  Copyright © 2015 sarsam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BusinessModel : NSObject

@property (strong,nonatomic) NSString* name;
@property (strong,nonatomic) NSString* url;
@property (strong,nonatomic) NSString* imageURL;
@property (strong,nonatomic) NSString* businessID;

@end
