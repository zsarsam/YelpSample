//
//  CollectionViewController.m
//  YelpSample
//
//  Created by Zaid Sarsam on 11/29/15.
//  Copyright © 2015 sarsam. All rights reserved.
//

#import "CollectionViewController.h"
#import "CollectionViewCell.h"
#import "NSURLRequest+OAuth.h"
#import "BusinessModel.h"
#import "UIImageView+AFNetworking.h"
#import "DetailViewController.h"


static NSString * const kAPIHost           = @"api.yelp.com";
static NSString * const kSearchPath        = @"/v2/search/";
static NSString * const kBusinessPath      = @"/v2/business/";

static NSString * const kSearchLimit       = @"10";

@interface CollectionViewController () <UISearchBarDelegate>

@property NSArray* businessModels;
@property NSIndexPath* selectedIndex;

@end

@implementation CollectionViewController

static NSString * const reuseIdentifier = @"CellD";

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self queryTopBusinessInfoForTerm:@"ethiopian" location:@"toronto" completionHandler:^(NSArray *businesses, NSError *error) {
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
    
    // Configure the cell
    BusinessModel* model = (BusinessModel*)self.businessModels[indexPath.row];
    cell.title.text = model.name ;
    [cell.imageView setImageWithURL:[NSURL URLWithString:model.imageURL]];
    //cell.title.backgroundColor = [UIColor grayColor];
    
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    indexPath = indexPath;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
 */

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
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

#pragma mark Yelp Helper functions

- (void)queryTopBusinessInfoForTerm:(NSString *)term location:(NSString *)location completionHandler:(void (^)(NSArray *businesses, NSError *error))completionHandler {
    
    NSLog(@"Querying the Search API with term \'%@\' and location \'%@'", term, location);
    
    NSURLRequest *searchRequest = [self _searchRequestWithTerm:term location:location];
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
- (NSURLRequest *)_searchRequestWithTerm:(NSString *)term location:(NSString *)location {
    NSDictionary *params = @{
                             @"term" : term,
                             @"cc": @"CA",
                             @"sort": @"2",
                             @"location": location,
                             @"limit": kSearchLimit
                             };
    
    return [NSURLRequest requestWithHost:kAPIHost path:kSearchPath params:params];
}

#pragma mark -- search delegate

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self queryTopBusinessInfoForTerm:searchBar.text
                            location:@"toronto" completionHandler:^(NSArray *businesses, NSError *error) {
        self.businessModels = [NSArray arrayWithArray:businesses];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // code here
            [self.collectionView reloadData];
        });
    }];

}


@end
