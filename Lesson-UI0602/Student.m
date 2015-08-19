//
//  Student.m
//  Lesson-UI0602
//
//  Created by lin on 15/6/2.
//  Copyright (c) 2015年 lin. All rights reserved.
//

#import "Student.h"

@implementation Student

-(void)dealloc {
    
    [_studentId release];
    [_number release];
    [_name release];
    [super dealloc];
}

@end
