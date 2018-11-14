//
//  Person.m
//  TeacherPlanner
//
//  Created by Oliver on 29.12.13.
//
//

#import "Person.h"
#import "PersonRef.h"
#import "Model.h"
#import "Application.h"
#import "Utilities.h"

@implementation Person {
    PersonRef *_personRef;
}

@synthesize name = _name;
@synthesize photoUUID = _photoUUID;

- (void)setup:(BOOL)isNew {
    if (!self.annotation) {
        self.annotation = [AnnotationContainer new];
    }
    self.annotation.parent = self;

    if (isNew) {
        _personRef = [PersonRef new];
        _personRef.uuid = self.uuid;
        _personRef.name = @"";
    } else {
        _personRef = [[Model instance].application personRefByUUID:self.uuid];
    }
    if (!self.useCount) {
        self.useCount = 0;
    }
}

#pragma mark - ANNOTATION

- (AnnotationContainer *)annotationByUUID:(NSString *)uuid {
    if ([self.annotation.uuid isEqual:uuid]) {
        return self.annotation;
    }
    return nil;
}

#pragma mark - PERSON REF

- (NSString *)name {
    return self.ref.name;
}

- (void)setName:(NSString *)name {
    if ([_name isEqualToString:name]) {
        return;
    }
    [self.ref setProperty:@"name" value:name];
}

- (NSString *)photoUUID {
    return self.ref.photoUUID;
}

- (void)setPhotoUUID:(NSString *)photoUUID {
    if ([_photoUUID isEqualToString:photoUUID]) {
        return;
    }
    [self.ref setProperty:@"photoUUID" value:photoUUID];
}

#pragma mark - PERSON

- (PersonRef *)ref {
    return _personRef;
}

- (Photo *)photo {
    if (self.photoUUID) {
        return [[Model instance].application photoByUUID:self.photoUUID];
    }
    return nil;
}

- (NSString *)nameInitials {
    return [self.ref nameInitials];
}

@end