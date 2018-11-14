//
//  PersonRef.m
//  TeacherPlanner
//
//  Created by Oliver on 29.12.13.
//
//

#import "PersonRef.h"
#import "Model.h"
#import "Application.h"
#import "Utilities.h"

@implementation PersonRef

@synthesize name = _name;
@synthesize photoUUID = _photoUUID;

- (Person *)person {
    return [[Model instance].application personByUUID:self.uuid];
}

- (void)setName:(NSString *)name {
    if ([_name isEqualToString:name]) {
        return;
    }
    _name = name;
    [self.person setProperty:@"name" value:name force:YES];
}

- (void)setPhotoUUID:(NSString *)photoUUID {
    if ([_photoUUID isEqualToString:photoUUID ]) {
        return;
    }
    _photoUUID = photoUUID;
    [self.person setProperty:@"photoUUID" value:photoUUID force:YES];
}

- (Photo *)photo {
    if (self.photoUUID) {
        return [[Model instance].application photoByUUID:self.photoUUID];
    }
    return nil;
}

- (NSString *)nameInitials {
    return [Utilities nameInitials:self.name];
}

@end