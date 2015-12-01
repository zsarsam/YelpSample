//
//  CollectionViewController.m
//  YelpSample
//
//  Created by Zaid Sarsam on 11/29/15.
//  Copyright © 2015 sarsam. All rights reserved.
//

#import "CollectionViewController.h"
#import "CollectionViewCell.h"
#import "BusinessModel.h"
#import "UIImageView+AFNetworking.h"
#import "DetailViewController.h"
#import "YelpApiManager.h"


@interface CollectionViewController () <UISearchBarDelegate>

@property NSArray* businessModels;
@property NSIndexPath* selectedIndex;

@end

@implementation CollectionViewController

static NSString * const reuseIdentifier = @"CellD";

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // making service call for default ethiopian food
    [YelpApiManager queryTopBusinessInfoForTerm:@"ethiopian" location:@"toronto" completionHandler:^(NSArray *businesses, NSError *error) {
        self.businessModels = [NSArray arrayWithArray:businesses];
        dispatch_async(dispatch_get_main_queue(), ^{
             [self.collectionView reloadData];
        });
    }];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.businessModels count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    BusinessModel* model = (BusinessModel*)self.businessModels[indexPath.row];
    cell.title.text = model.name ;
    [cell.imageView setImageWithURL:[NSURL URLWithString:model.imageURL]];
    
    return cell;
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"detailViewID"])
    {
        // Get reference to the destination view controller
        DetailViewController *vc = [segue destinationViewController];
        
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        NSIndexPath *index = [indexPaths objectAtIndex:0];
        // Pass any objects to the view controller here, like...
        [vc setBusinessModel: self.businessModels[index.row]];
    }
}



#pragma mark -- search delegate
-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    //making service call for search query 
    [YelpApiManager queryTopBusinessInfoForTerm:searchBar.text
                            location:@"toronto" completionHandler:^(NSArray *businesses, NSError *error) {
        self.businessModels = [NSArray arrayWithArray:businesses];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }];

}
@end
