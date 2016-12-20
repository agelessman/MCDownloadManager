//
//  MCDefine.h
//  JZGChryslerForPad
//
//  Created by test on 16/12/6.
//  Copyright © 2016年 Beijing JingZhenGu Information Technology Co.Ltd. All rights reserved.
//

#ifndef MCDefine_h
#define MCDefine_h


// Use dispatch_main_async_safe instead of dispatch_async(dispatch_get_main_queue(), block)
#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block)\
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}
#endif



#endif /* MCDefine_h */
