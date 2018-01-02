//
//  ViewController.m
//  JsonToModel
//
//  Created by LZ on 2018/1/2.
//  Copyright © 2018年 QYM. All rights reserved.
//

#import "ViewController.h"
#import "JsonParseModel.h"
#import "PropertyParseModel.h"

@interface ViewController ()

@property (weak) IBOutlet NSTextField *textFieldJsonOpenPath;
@property (unsafe_unretained) IBOutlet NSTextView *textViewContent;
@property (weak) IBOutlet NSTextField *textFieldClassName;

@property (nonatomic, readonly) NSString *className;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark -
- (NSString *)className
{
    NSString *name = self.textFieldClassName.stringValue;
    if (name.length < 1) {
        name = @"model";
    }
    return name;
}

#pragma mark -
- (IBAction)buttonOpenJsonPathClicked:(id)sender {

    NSButton *btn = (NSButton*)sender;
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setPrompt: @"OK"];
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"json",nil]]; //   [NSImage imageFileTypes]
    
    NSURL *pathUrl = [[NSURL alloc] initFileURLWithPath:NSHomeDirectory()];
    [panel setDirectoryURL:pathUrl];
    
    [panel beginSheetModalForWindow:[btn window] completionHandler:^(NSInteger result){
        
        if (result == NSFileHandlingPanelOKButton) {
            NSArray *urls = [panel URLs];
            
            NSURL *url     = [urls objectAtIndex:0];
            NSString *path = [url path];
            
            //NSLog(@"%@",path);
            
            [self.textFieldJsonOpenPath setStringValue:path];
            
            NSError *error = nil;
            NSString *jsonString = [[NSString alloc] initWithContentsOfFile:path
                                                               encoding:NSUTF8StringEncoding
                                                                  error:&error];
            if (error == nil && jsonString.length > 0) {
                self.textViewContent.string = jsonString;
            }
        }
        
        NSLog(@"resutlt:%ld",result);
        
    }];
}

- (IBAction)buttonOutputClicked:(id)sender {
    
    NSButton *button = (NSButton *)sender;
    
    NSString *text = self.textViewContent.string;
    if (text.length > 0) {
        NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error = nil;
        id  jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                       options:NSJSONReadingMutableLeaves
                                                         error:&error];
        if (error) {
            [self showAlertWithText:error.localizedDescription withWindow:button.window];
        }
        else{
            
            
            NSOpenPanel *panel = [NSOpenPanel openPanel];
            [panel setPrompt: @"OK"];
            [panel setCanChooseDirectories:YES];
            [panel setCanCreateDirectories:YES];
            [panel setCanChooseFiles:NO];

            NSURL *pathUrl = [[NSURL alloc] initFileURLWithPath:NSHomeDirectory()];
            [panel setDirectoryURL:pathUrl];
            
            [panel beginSheetModalForWindow:[button window] completionHandler:^(NSInteger result){
                
                if (result == NSFileHandlingPanelOKButton) {
                    NSArray *urls = [panel URLs];
                    
                    NSURL *url     = [urls objectAtIndex:0];
                    NSString *path = [url path];

                     [self outPutWithJsonData:jsonData withPath:path];
                    
                }
                
                NSLog(@"resutlt:%ld",result);
                
            }];
            
            
           
        }
    }
}

#pragma mark - NSAlert 操作
- (void)showAlertWithText:(NSString *)text withWindow:(NSWindow *)window
{
    NSAlert *alert = [[NSAlert alloc] init];
    //alert.messageText = nil;
    alert.informativeText = text;
    [alert addButtonWithTitle:@"确定"];
    
    [alert beginSheetModalForWindow:window
                  completionHandler:^(NSModalResponse returnCode) {
                      
                  }];
}


#pragma mark -
- (void)outPutWithJsonData:(id)object withPath:(NSString *)path
{
    
    JsonParseModel *jsonModel = nil;
    NSString *className       = self.className;
    
    if ([object isKindOfClass:[NSDictionary class]]) {
        jsonModel = [JsonParseModel jsonModelWithClassName:className jsonDict:object];
    }
    else if ([object isKindOfClass:[NSArray class]]){
        
        if ([object count] > 0) {
            
            id firstObject = object[0];
            if ([firstObject isKindOfClass:[NSDictionary class]]) {
                jsonModel = [JsonParseModel jsonModelWithClassName:className jsonDict:firstObject];
            }
        
        }
    }
    
    NSString *headerFileString   = [self fileHeaderInfoWithModel:jsonModel];
    NSString *headerPropertyInfo = [self headerFileClassInfoWithModel:jsonModel];
    if (headerPropertyInfo) {
        headerFileString = [headerFileString stringByAppendingString:headerPropertyInfo];
    }
    
    if (headerFileString.length > 0) {
    
        NSString *hearderPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.h",jsonModel.className]];
        
        [headerFileString writeToFile:hearderPath
                           atomically:NO
                             encoding:NSUTF8StringEncoding
                                error:nil];
    }
    
    NSString *implementaitonFileString   = [self fileImplementationInfoWithModel:jsonModel];
    NSString *implementationPropertyInfo = [self implementationFileWithModel:jsonModel];
    
    if (implementationPropertyInfo) {
        implementaitonFileString = [implementaitonFileString stringByAppendingString:implementationPropertyInfo];
    }

    if (implementaitonFileString.length > 0) {
        
        NSString *implementationPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m",jsonModel.className]];
        
        [implementaitonFileString writeToFile:implementationPath
                           atomically:NO
                             encoding:NSUTF8StringEncoding
                                error:nil];
    }
}

#pragma mark - header File
- (NSString *)fileHeaderInfoWithModel:(JsonParseModel *)model
{
    NSMutableString *fileHeader = [NSMutableString stringWithFormat:@"//\n//%@.h\n//",model.className];
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;

    [fileHeader appendFormat:@"\n// create on %@",[dateFormatter stringFromDate:currentDate]];
    
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *year = [dateFormatter stringFromDate:currentDate];
    [fileHeader appendFormat:@"\n// Copyright © %@年 __MyCompanyName__. All rights reserved.\n//",year];
    
    [fileHeader appendFormat:@"\n\n\n#import <Foundation/Foundation.h>"];
    
    return fileHeader;
}

- (NSString *)headerFileClassInfoWithModel:(JsonParseModel *)model
{
    NSMutableString *string = [NSMutableString string];
    [string appendFormat:@"\n\n@interface %@ : NSObject\n\n",model.className];
    
    NSDictionary *dict = model.jsonDict;
    PropertyParseModel *propertyJsonModel = [self propertyInfoWithDict:dict];
    [string appendString:propertyJsonModel.propertyString];
    NSArray *classArray = propertyJsonModel.classArray;

    [string appendFormat:@"\n\n@end\n\n"];
    
    for (JsonParseModel *jsonModel in classArray) {
        NSString *classJsonString = [self headerFileClassInfoWithModel:jsonModel];
        [string appendString:classJsonString];
    }
    
    return string;
}

- (PropertyParseModel *)propertyInfoWithDict:(NSDictionary *)dict
{
    NSMutableString *string    = [NSMutableString string];
    NSMutableArray *classArray = [NSMutableArray array];
    
    for (NSString *key in [dict allKeys]) {
        
        id object = dict[key];
        if([object isKindOfClass:[NSString class]])
        {
            [string appendFormat:@"@property (nonatomic, strong) NSString *%@;\n",key];
        }
        else if ([object isKindOfClass:[NSNumber class]])
        {
            [string appendFormat:@"@property (nonatomic, strong) NSNumber *%@;\n",key];
        }
        else if ([object isKindOfClass:[NSNull class]])
        {
            [string appendFormat:@"@property (nonatomic, strong) id %@;\n",key];
        }
        else if ([object isKindOfClass:[NSDictionary class]])
        {
            PropertyParseModel *model = [self propertyInfoWithDict:object];
            [string appendString:model.propertyString];
            [classArray addObjectsFromArray:model.classArray];
        }
        else if ([object isKindOfClass:[NSArray class]])
        {
            [string appendFormat:@"@property (nonatomic, strong) NSArray *%@;\n",key];
            
            if ([object count] > 0) {
                
                id firstObject = object[0];
                if ([firstObject isKindOfClass:[NSDictionary class]]) {
                    JsonParseModel *jsonModel = [JsonParseModel jsonModelWithClassName:key jsonDict:firstObject];
                    [classArray addObject:jsonModel];
                }
            }
        }
    }
    
    PropertyParseModel *model = [PropertyParseModel propertyParseModelWithPropertyString:string classArray:classArray];
    return model;
}

#pragma mark - implementationFile
- (NSString *)fileImplementationInfoWithModel:(JsonParseModel *)model
{
    NSMutableString *fileImplemantation = [NSMutableString stringWithFormat:@"//\n//%@.m\n//",model.className];
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    
    [fileImplemantation appendFormat:@"\n// create on %@",[dateFormatter stringFromDate:currentDate]];
    
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *year = [dateFormatter stringFromDate:currentDate];
    [fileImplemantation appendFormat:@"\n// Copyright © %@年 __MyCompanyName__. All rights reserved.\n//",year];
    
    
    [fileImplemantation appendFormat:@"\n\n\n#import \"%@.h\"",model.className];
    
    return fileImplemantation;
}

- (NSString *)implementationFileWithModel:(JsonParseModel *)model
{

    NSMutableString *string = [NSMutableString string];
    [string appendFormat:@"\n\n@implementation %@ \n\n",model.className];

    NSDictionary *dict  = model.jsonDict;
    NSArray *classArray = [self implementationPropertyInfoWithDict:dict];

    [string appendFormat:@"\n\n@end\n\n"];

    for (JsonParseModel *jsonModel in classArray) {
        NSString *classJsonString = [self implementationFileWithModel:jsonModel];
        [string appendString:classJsonString];
    }

    return string;
}

- (NSArray *)implementationPropertyInfoWithDict:(NSDictionary *)dict
{
    NSMutableArray *classArray = [NSMutableArray array];
    
    for (NSString *key in [dict allKeys]) {
        
        id object = dict[key];
        if ([object isKindOfClass:[NSArray class]])
        {
            if ([object count] > 0) {
                
                id firstObject = object[0];
                if ([firstObject isKindOfClass:[NSDictionary class]]) {
                    JsonParseModel *jsonModel = [JsonParseModel jsonModelWithClassName:key jsonDict:firstObject];
                    [classArray addObject:jsonModel];
                }
            }
        }
        else if ([object isKindOfClass:[NSDictionary class]])
        {
            NSArray *array = [self implementationPropertyInfoWithDict:object];
            [classArray addObjectsFromArray:array];
        }
        
    }
    
    return classArray;
}


@end
