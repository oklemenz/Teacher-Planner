//
//  Application.h
//  TeacherPlanner
//
//  Created by Oliver on 29.12.13.
//
//

#import "JSONRootEntity.h"
#import "Photo.h"
#import "Attachment.h"
#import "Person.h"
#import "PersonRef.h"
#import "SchoolYear.h"
#import "SchoolYearRef.h"
#import "Settings.h"
#import "PencilStyle.h"
#import "Word.h"
#import "ImageAnnotationViewController.h"

#define kApplicationImportTypeExport @"Export"
#define kApplicationImportTypeBackup @"Backup"

@interface Application : JSONRootEntity <ImageAnnotationDataSource>

@property (nonatomic, strong) Settings *settings;
@property (nonatomic, strong) NSMutableArray<PersonRef> *personRef;
@property (nonatomic, strong) NSMutableArray<SchoolYearRef> *schoolYearRef;
@property (nonatomic, strong) NSMutableSet *photoUUID;
@property (nonatomic, strong) NSMutableSet *attachmentUUID;
@property (nonatomic, strong) NSMutableArray<PencilStyle> *pencilStyle;
@property (nonatomic, strong) NSMutableArray<Word> *word;

@property (nonatomic, strong) NSMutableArray *menuSelection;
@property (nonatomic, strong) NSMutableArray *contentSelection;
@property (nonatomic) NSMutableDictionary *tabSelection;

- (NSString *)applicationFolder;

+ (Application *)createApplication:(NSString *)uuid;
+ (BOOL)deleteApplication:(NSString *)uuid;
+ (BOOL)copyApplication:(NSString *)uuid;
+ (BOOL)importApplication:(NSString *)filePath type:(NSString *)type password:(NSString *)password;

- (void)pushMenuSelection:(NSString *)uuid;
- (void)popMenuSelection;

- (Photo *)photoByUUID:(NSString *)uuid;
- (Photo *)addPhoto:(NSData *)data;
- (void)insertPhoto:(Photo *)photo;
- (void)removePhotoByUUID:(NSString *)uuid;
- (void)removePhoto:(Photo *)photo;
- (NSArray *)loadedPhoto;

- (Attachment *)attachmentByUUID:(NSString *)uuid;
- (Attachment *)addAttachment:(NSDictionary *)parameters;
- (void)insertAttachment:(Attachment *)attachment;
- (void)removeAttachmentByUUID:(NSString *)uuid;
- (void)removeAttachment:(Attachment *)attachment;
- (NSArray *)loadedAttachment;

- (NSInteger)numberOfPersonRef;
- (NSInteger)numberOfPersonRefGroup;
- (NSInteger)numberOfPersonRefByGroup:(NSInteger)group;
- (NSInteger)numberOfPersonRefByGroupName:(NSString *)groupName;
- (NSString *)personRefGroupName:(NSInteger)group;
- (NSIndexPath *)personRefGroupIndexByUUID:(NSString *)uuid;
- (PersonRef *)personRefByGroup:(NSInteger)group index:(NSInteger)index;
- (PersonRef *)personRefByUUID:(NSString *)uuid;
- (Person *)personByGroup:(NSInteger)group index:(NSInteger)index;
- (Person *)personByUUID:(NSString *)uuid;
- (Person *)addPerson;
- (void)insertPerson:(Person *)person;
- (void)removePersonRefByUUID:(NSString *)uuid;
- (void)removePersonByUUID:(NSString *)uuid;
- (void)removePerson:(Person *)person;
- (void)removePersonRef:(PersonRef *)personRef;
- (void)sortPersonRef;
- (NSArray *)personRefIndex;
- (NSArray *)loadedPerson;
- (void)filterPersonRefBy:(NSString *)filter;
- (void)resetFilterPersonRef;

- (NSInteger)numberOfSchoolYearRef;
- (NSInteger)numberOfSchoolYearRefGroup;
- (NSInteger)numberOfSchoolYearRefByGroup:(NSInteger)group;
- (NSInteger)numberOfSchoolYearRefByGroupName:(NSString *)groupName;
- (NSString *)schoolYearRefGroupName:(NSInteger)group;
- (NSIndexPath *)schoolYearRefGroupIndexByUUID:(NSString *)uuid;
- (SchoolYearRef *)schoolYearRefByGroup:(NSInteger)group index:(NSInteger)index;
- (SchoolYearRef *)schoolYearRefByIndex:(NSInteger)index;
- (SchoolYearRef *)schoolYearRefByUUID:(NSString *)uuid;
- (SchoolYear *)schoolYearByGroup:(NSInteger)group index:(NSInteger)index;
- (SchoolYear *)schoolYearByIndex:(NSInteger)index;
- (SchoolYear *)schoolYearByUUID:(NSString *)uuid;
- (SchoolYear *)activeSchoolYear;
- (SchoolYear *)addSchoolYear;
- (void)insertSchoolYear:(SchoolYear *)schoolYear;
- (SchoolYear *)copySchoolYear:(SchoolYear *)schoolYear;
- (void)removeSchoolYearRefByUUID:(NSString *)uuid;
- (void)removeSchoolYearByUUID:(NSString *)uuid;
- (void)removeSchoolYear:(SchoolYear *)schoolYear;
- (void)removeSchoolYearRef:(SchoolYearRef *)schoolYearRef;
- (void)sortSchoolYearRef;
- (NSArray *)loadedSchoolYear;

- (void)addPersonUsage:(NSString *)personUUID;
- (void)removePersonUsage:(NSString *)personUUID;

- (NSInteger)numberOfWord;
- (NSInteger)numberOfWordGroup;
- (NSInteger)numberOfWordByGroup:(NSInteger)group;
- (NSInteger)numberOfWordByGroupName:(NSString *)groupName;
- (NSString *)wordGroupName:(NSInteger)group;
- (NSIndexPath *)wordGroupIndexByUUID:(NSString *)uuid;
- (Word *)wordByGroup:(NSInteger)group index:(NSInteger)index;
- (Word *)wordByUUID:(NSString *)uuid;
- (Word *)addWord;
- (void)insertWord:(Word *)word;
- (void)removeWordByUUID:(NSString *)uuid;
- (void)removeWord:(Word *)word;
- (void)sortWord;
- (NSArray *)wordIndex;
- (void)filterWordBy:(NSString *)filter;
- (void)resetFilterWord;
- (NSNumber *)containsWord:(NSString *)word;

- (void)cleanup;

@end