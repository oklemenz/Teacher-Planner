//
//  JSONModelArray.h
//
//  @version 0.8.0
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

#import <Foundation/Foundation.h>

/**
 * **Don't make instances of JSONModelArray yourself, except you know what you are doing.**
 *
 * You get automatically JSONModelArray instances, when you declare a convert on demand property, like so:
 * 
 * @property (strong, nonatomic) NSArray&lt;JSONModel, ConvertOnDemand&gt;* list;
 *
 * The class stores its contents as they come from JSON, and upon the first request
 * of each of the objects stored in the array, it'll be converted to the target model class.
 * Thus saving time upon the very first model creation.
 */
@interface JSONModelArray : NSArray

/**
 * Don't make instances of JSONModelArray yourself, except you know what you are doing.
 * 
 * @param array an array of NSDictionary objects
 * @param cls the JSONModel sub-class you'd like the NSDictionaries to be converted to on demand
 */
- (instancetype)initWithArray:(NSArray *)array modelClass:(Class)cls;

- (id)objectAtIndex:(NSUInteger)index;
- (void)forwardInvocation:(NSInvocation *)anInvocation;
- (NSUInteger)count;

/**
 * Looks up the array's contents and tries to find a JSONModel object
 * with matching index property value to the indexValue param.
 *
 * Will return nil if no matching model is found. Will return nil if there's no index property
 * defined on the models found in the array (will sample the first object, assuming the array
 * contains homogenous collection of objects)
 *
 * @param indexValue the id value to search for
 * @return the found model or nil
 */
- (id)modelWithIndexValue:(id)indexValue;

@end
