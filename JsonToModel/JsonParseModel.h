//
//  JsonModel.h
//  JsonToModel
//
//  Created by LZ on 2018/1/2.
//  Copyright © 2018年 QYM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JsonParseModel : NSObject

@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) NSDictionary *jsonDict;

+ (instancetype)jsonModelWithClassName:(NSString *)className jsonDict:(NSDictionary *)dict;

@end
