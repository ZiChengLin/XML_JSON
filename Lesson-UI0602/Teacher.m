//
//  Teacher.m
//  Lesson-UI0602
//
//  Created by lin on 15/6/2.
//  Copyright (c) 2015年 lin. All rights reserved.
//

#import "Teacher.h"

@implementation Teacher

-(void)dealloc {
    
    [_name release];
    [_number release];
    [super dealloc];
}

// json文件中往往有很多字段，但是只需要部分字段。重写这个方法，防止它调用系统的crush(因为这个方法:setValuesForKeysWithDictionary)
-(void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    
}

@end
