//
//  CollectionViewCell.h
//  YelpSample
//
//  Created by Zaid Sarsam on 11/29/15.
//  Copyright © 2015 sarsam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@end
