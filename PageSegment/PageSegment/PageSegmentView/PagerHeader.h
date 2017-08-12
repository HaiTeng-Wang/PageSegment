//
//  PagerHeader.h
//  PageSegment
//
//  Created by Hunter on 12/08/2017.
//  Copyright © 2017 Hunter. All rights reserved.
//

#ifndef PagerHeader_h
#define PagerHeader_h


#endif /* PagerHeader_h */

// 图片路径
#define PagerTabSrcName(file)               [@"PageSegmentView.bundle" stringByAppendingPathComponent:file]

#define PagerTabFrameworkSrcName(file)      [@"Frameworks/PageSegment.framework/PageSegmentView.bundle" stringByAppendingPathComponent:file]

#define PagerTabImage(file)                 [UIImage imageNamed:PagerTabSrcName(file)] ? :[UIImage imageNamed:PagerTabFrameworkSrcName(file)]



#import "UIViewAdditions.h"
#import "BodyScrollView.h"
