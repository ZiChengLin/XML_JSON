//
//  ViewController.m
//  Lesson-UI0602
//
//  Created by lin on 15/6/2.
//  Copyright (c) 2015年 lin. All rights reserved.
//

#import "ViewController.h"
#import "Student.h"
#import "Teacher.h"

#import "GDataXMLNode.h"   // 支持DOM解析XML 第三方类库

#import "JSONKit.h"        // 支持KIT解析JSON 第三方类库

@interface ViewController ()

@property (nonatomic, retain)NSMutableArray *studentArray;   // 保持解析过程中产生的学生对象

@property (nonatomic, retain)NSString *elementName;          // 纪录解析过程中遇到的标签名

@property (nonatomic, retain)NSMutableArray *teacherArray;   // 保存json解析过程中产生的所有teacher对象

@end

@implementation ViewController

-(void)dealloc {
    
    [_studentArray release];
    [_elementName release];
    [_teacherArray release];
    [super dealloc];
}

- (IBAction)saxButton:(id)sender {
    
    // 读取文件
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"students" ofType:@"xml"];    // 找到文件路径
    
    NSString *str = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"%@", str);
    
    // 二进制数据类 (把字符串转化为二进制数据)
    NSData *xml = [str dataUsingEncoding:NSUTF8StringEncoding];
    
#pragma mark -开始解析 （SAX解析、逐行解析过程）
    // 1.创建解析对象
    NSXMLParser *parser = [[NSXMLParser alloc]initWithData:xml];
    parser.delegate = self;
    // 2.解析开始
    [parser parse];
    
}

#pragma mark -实现代理方法
// 文件开始解析时候调用的方法 初始化解析过程中使用到的数据
-(void)parserDidStartDocument:(NSXMLParser *)parser {
    
    self.studentArray = [[NSMutableArray alloc]initWithCapacity:10];
}

// 遇到开始标签触发的方法 参数: 解析对象、标签名、命名空间、前缀名、属性
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    self.elementName = elementName;
    if ([_elementName isEqualToString:@"student"]) {
        
        NSString *str = attributeDict[@"id"];   // 取到属性的值
        
        Student *stu = [[Student alloc]init];
        stu.studentId = str;                    // 将所有属性的值保存到学生类里面
        
        [_studentArray addObject:stu];
        [stu release];
    }
}

// 遇到字符串（值）触发的方法
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    // 获取数据对象,数组的最后一个元素（从后往前）
    Student *stu = [_studentArray lastObject];
    if ([_elementName isEqualToString:@"number"]) {
        
        stu.number = string;
    }
    if ([_elementName isEqualToString:@"name"]) {
        
        stu.name = string;
    }
    
}

// 遇到结束标签触发的方法
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    _elementName = nil;  // 将纪录开始标签置空，再重新解析下一个数据
    
}

// 解析结束
-(void)parserDidEndDocument:(NSXMLParser *)parser {
    
    for (Student *stu in _studentArray) {
        
        NSLog(@"id:%@, number:%@, name:%@", stu.studentId, stu.number, stu.name);
    }
    
}


#pragma mark -XML的DOM解析
- (IBAction)domButton:(id)sender {
    
    self.studentArray = [NSMutableArray arrayWithCapacity:10];
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"students" ofType:@"xml"];
    NSString *xmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"%@", xmlString);
    
    //
    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc]initWithXMLString:xmlString options:0 error:nil];
    
    // 获取根节点
    GDataXMLElement *element = xmlDoc.rootElement;
    
    // 获取所有标签为student的节点
    NSArray *array = [element elementsForName:@"student"];
    
    for (GDataXMLElement *element in array) {
        // 获取到对应属性的值 字符串
        NSString *str = [[element attributeForName:@"id"] stringValue];
        NSLog(@"%@", str);
        
        // 获取student层对应的number节点（因为number只有一个）
        GDataXMLElement *subElement = [[element elementsForName:@"number"] lastObject];
        NSString *numStr = [subElement stringValue];    // 再将其转化成字符串
        
        GDataXMLElement *subElement2 = [[element elementsForName:@"name"] lastObject];
        NSString *nameStr = [subElement2 stringValue];
        NSLog(@"%@, %@", numStr, nameStr);
        
        // 创建对象接收它
        Student *stu = [[Student alloc]init];
        stu.studentId = str;
        stu.number = numStr;
        stu.name = nameStr;
        [_studentArray addObject:stu];
        [stu release];
    }
    
    for (Student *stu in _studentArray) {
        NSLog(@"id:%@, number:%@, name:%@", stu.studentId, stu.number, stu.name);
    }
    
}



#pragma mark -系统Json文件解析(效率最高)
- (IBAction)jsonButton:(id)sender {
    
    self.teacherArray = [[NSMutableArray alloc]initWithCapacity:10];
    // 获取文件路径
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"teacher" ofType:@"json"];
    NSString *jsonStr = [[NSString alloc]initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];   // ios所有的编码方式都是NSUTF8StringEncoding.
    NSLog(@"%@", jsonStr);
    
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    // 查看json文件最外层是数组还是字典，对应接收的类型
    NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];    //options读取方式
    
    for (NSDictionary *teacherDic in array) {
        
        Teacher *teacher = [[Teacher alloc]init];
        [teacher setValuesForKeysWithDictionary:teacherDic];
        [_teacherArray addObject:teacher];
        [teacher release];
    }
    
    for (Teacher *teacher in _teacherArray) {
        
        NSLog(@"number = %@, name = %@", teacher.number, teacher.name);
    }

}


#pragma mark -第三方的Json Kit文件解析
- (IBAction)kitButton:(id)sender {
    
    // 获取文件路径
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"area" ofType:@"json"];
    NSString *jsonStr = [[NSString alloc]initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"%@", jsonStr);
    
    // json Kit的方法获取最外层的数组
    NSArray *array = [jsonStr objectFromJSONString];
    
    for (NSDictionary *dic in array) {
        
        NSString *provinceName = dic[@"province"];
        NSLog(@"provinceName = %@", provinceName);
        
        NSArray *cityArray = dic[@"cityList"];
        
        for (NSString *str in cityArray) {
            NSLog(@"cityName = %@", str);
        }
    }
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
