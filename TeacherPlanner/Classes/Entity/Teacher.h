//
//  Teacher.h
//  TeacherPlanner
//
//  Created by Oliver on 17.05.14.
//
//

#import "JSONChildEntity.h"

@interface Teacher : JSONChildEntity

@property (nonatomic, strong) NSString *photoUUID;
@property (nonatomic, strong) NSString *code;
@property (nonatomic) NSInteger title;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSDate *birthDate;
@property (nonatomic, strong) NSDate *birthTime;

- (NSString *)name;
- (NSString *)nameInitials;

- (void)setWelcomeName;

@end