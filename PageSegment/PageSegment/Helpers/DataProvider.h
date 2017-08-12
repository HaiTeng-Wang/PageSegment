//
//  DataProvider.h
//  CcfaxPagerTab
//
//  Created by Hunter on 12/08/2017.
//  Copyright © 2017 Hunter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataProvider : NSObject

+ (DataProvider *)sharedInstance;

@property (nonatomic, strong) NSArray *postsData;

@end
