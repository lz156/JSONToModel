//
//  PropertyParseModel.h
//  JsonToModel
//
//  Created by LZ on 2018/1/2.
//  Copyright © 2018年 QYM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PropertyParseModel : NSObject

@property (nonatomic, strong) NSString *propertyString;
@property (nonatomic, strong) NSArray *classArray;

+ (instancetype)propertyParseModelWithPropertyString:(NSString *)propertyString classArray:(NSArray *)array;

@end
