//
//  JsonModel.m
//  JsonToModel
//
//  Created by LZ on 2018/1/2.
//  Copyright © 2018年 QYM. All rights reserved.
//

#import "JsonParseModel.h"

@implementation JsonParseModel

+ (instancetype)jsonModelWithClassName:(NSString *)className jsonDict:(NSDictionary *)dict
{
    JsonParseModel *model = [[JsonParseModel alloc] init];
    
    model.className = className;
    model.jsonDict  = dict;
    
    return model;
}

@end
