//
//  JSONValueTransformer.m
//
//  @version 0.9.3
//  @author Marin Todorov, http://www.touch-code-magazine.com
//

// Copyright (c) 2012-2013 Marin Todorov, Underplot ltd.
// This code is distributed under the terms and conditions of the MIT license.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// The MIT License in plain English: http://www.touch-code-magazine.com/JSONModel/MITLicense

#import "JSONValueTransformer.h"

#pragma mark - functions
extern BOOL isNull(id value)
{
    if (!value) return YES;
    if ([value isKindOfClass:[NSNull class]]) return YES;
    
    return NO;
}

@implementation JSONValueTransformer

-(instancetype)init
{
    self = [super init];
    if (self) {
        _primitivesNames = @{@"f":@"float", @"i":@"int", @"d":@"double", @"l":@"long", @"c":@"BOOL", @"s":@"short", @"q":@"long",
                             //and some famos aliases of primitive types
                             @"I":@"NSInteger"};
    }
    return self;
}

+(Class)classByResolvingClusterClasses:(Class)sourceClass
{
    //check for all variations of strings
    if ([sourceClass isSubclassOfClass:[NSString class]]) {
        return [NSString class];
    }
    
    //check for all variations of numbers
    if ([sourceClass isSubclassOfClass:[NSNumber class]]) {
        return [NSNumber class];
    }

    //check for all variations of dictionaries
    if ([sourceClass isSubclassOfClass:[NSArray class]]) {
        return [NSArray class];
    }
    
    //check for all variations of arrays
    if ([sourceClass isSubclassOfClass:[NSDictionary class]]) {
        return [NSDictionary class];
    }

    //check for all variations of dates
    if ([sourceClass isSubclassOfClass:[NSDate class]]) {
        return [NSDate class];
    }

    //no cluster parent class found
    return sourceClass;
}

#pragma mark - NSMutableString <-> NSString
-(NSMutableString*)NSMutableStringFromNSString:(NSString*)string
{
    return [NSMutableString stringWithString:string];
}

#pragma mark - NSMutableArray <-> NSArray
-(NSMutableArray*)NSMutableArrayFromNSArray:(NSArray*)array
{
    return [NSMutableArray arrayWithArray:array];
}

#pragma mark - NSMutableDictionary <-> NSDictionary
-(NSMutableDictionary*)NSMutableDictionaryFromNSDictionary:(NSDictionary*)dict
{
    return [NSMutableDictionary dictionaryWithDictionary:dict];
}

#pragma mark - NSSet <-> NSArray
-(NSSet*)NSSetFromNSArray:(NSArray*)array
{
    return [NSSet setWithArray:array];
}

-(NSMutableSet*)NSMutableSetFromNSArray:(NSArray*)array
{
    return [NSMutableSet setWithArray:array];
}

-(id)JSONObjectFromNSSet:(NSSet*)set
{
    return [set allObjects];
}

-(id)JSONObjectFromNSMutableSet:(NSMutableSet*)set
{
    return [set allObjects];
}


#pragma mark - BOOL <-> number/string
-(NSNumber*)BOOLFromNSNumber:(NSNumber*)number
{
    if (isNull(number)) return @0;
    return number;
}

-(NSNumber*)BOOLFromNSString:(NSString*)string
{
    int val = [string intValue];
    if (val!=0) val=1;
    return @(val);
}

-(NSNumber*)JSONObjectFromBOOL:(NSNumber*)number
{
    return number;
}

#pragma mark - string/number <-> float
-(float)floatFromObject:(id)obj
{
    return [obj floatValue];
}

-(float)floatFromNSString:(NSString*)string
{
    return [self floatFromObject:string];
}

-(float)floatFromNSNumber:(NSNumber*)number
{
    return [self floatFromObject:number];
}

-(NSNumber*)NSNumberFromfloat:(float)f
{
    return [NSNumber numberWithFloat:f];
}

#pragma mark - string <-> number
-(NSNumber*)NSNumberFromNSString:(NSString*)string
{
    return [NSNumber numberWithFloat: [string doubleValue]];
}

-(NSString*)NSStringFromNSNumber:(NSNumber*)number
{
    return [number stringValue];
}

#pragma mark - string <-> url
-(NSURL*)NSURLFromNSString:(NSString*)string
{
    return [NSURL URLWithString: [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

-(NSString*)JSONObjectFromNSURL:(NSURL*)url
{
    return [url absoluteString];
}

#pragma mark - string <-> date
-(NSDate*)NSDateFromNSString:(NSString*)string
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    string = [string stringByReplacingOccurrencesOfString:@":" withString:@""]; // this is such an ugly code, is this the only way?
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HHmmssZZZZ"];
    
    return [dateFormatter dateFromString: string];
}

-(NSString*)JSONObjectFromNSDate:(NSDate*)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    
    return [dateFormatter stringFromDate:date];
}

@end
