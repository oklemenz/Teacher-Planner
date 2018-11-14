//
//  Model.m
//  TeacherPlanner
//
//  Created by Oliver on 30.12.13.
//
//

#import "Model.h"
#import "Application.h"
#import "TransientCustomData.h"
#import "Photo.h"
#import "Attachment.h"
#import "Person.h"
#import "SchoolYear.h"
#import "Utilities.h"

@interface Model () {
    TransientCustomData *_transientCustomData;
}

@end

@implementation Model

- (instancetype)init {
    self = [super init];
    if (self) {
        _transientCustomData = [TransientCustomData new];
    }
    return self;
}

+ (Model *)instance {
    static Model *instance = nil;
    @synchronized(self) {
        if (!instance) {
            instance = [Model new];
        }
    }
    return instance;
}

- (Application *)application {
    return (Application *)super.root;
}

- (NSString *)load:(NSString *)uuid {
    if (uuid) {
        super.root = [Application load:uuid];
    }
    if (!super.root) {
        super.root = [Application createApplication:uuid];
    }
    [super load:uuid];
    return self.root.uuid;
}

- (BOOL)store {
    BOOL success = YES;
    if (self.application) {
        if (![self.application store]) {
            success = NO;
        }
        for (Photo *photo in [self.application loadedPhoto]) {
            if (![photo store]) {
                success = NO;
            }
        }
        for (Attachment *attachment in [self.application loadedAttachment]) {
            if (![attachment store]) {
                success = NO;
            }
        }
        for (Person *person in [self.application loadedPerson]) {
            if (![person store]) {
                success = NO;
            }
        }
        for (SchoolYear *schoolYear in [self.application loadedSchoolYear]) {
            if (![schoolYear store]) {
                success = NO;
            }
        }
        if (success) {
            success = [super store];
        }
    }
    return success;
}

- (BOOL)exportData {
    BOOL success = YES;
    if (self.application) {
        [self.application exportData];
        for (NSString *photoUUID in [self.application photoUUID]) {
            if (![[self.application photoByUUID:photoUUID] exportData]) {
                success = NO;
            }
        }
        for (NSString *attachmentUUID in [self.application attachmentUUID]) {
            if (![[self.application attachmentByUUID:attachmentUUID] exportData]) {
                success = NO;
            }
        }
        for (PersonRef *personRef in [self.application personRef]) {
            if (![[self.application personByUUID:personRef.uuid] exportData]) {
                success = NO;
            }
        }
        for (SchoolYearRef *schoolYearRef in [self.application schoolYearRef]) {
            if (![[self.application schoolYearByUUID:schoolYearRef.uuid] exportData]) {
                success = NO;
            }
        }
    }
    return success;
}

- (void)cleanup {
    [self.application cleanup];
}

- (TransientCustomData *)transientCustomData {
    return _transientCustomData;
}

@end