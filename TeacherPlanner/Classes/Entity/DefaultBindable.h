//
//  DefaultBindable.h
//  TeacherPlanner
//
//  Created by Oliver on 05.10.14.
//
//

#import "Bindable.h"

@interface DefaultBindable : NSObject <Bindable>

@property (nonatomic, weak, readonly) id delegate;

- (instancetype)initWithDelegate:(id)delegate;

@end