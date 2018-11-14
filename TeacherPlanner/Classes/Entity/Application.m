//
//  Application.m
//  TeacherPlanner
//
//  Created by Oliver on 29.12.13.
//
//

#import "Application.h"
#import "Model.h"
#import "Utilities.h"
#import "PencilStyle.h"
#import "Codes.h"

@implementation Application {
    NSMutableDictionary *_photoByUUID;
    NSMutableDictionary *_attachmentByUUID;
    NSMutableDictionary *_personByUUID;
    NSMutableDictionary *_schoolYearByUUID;
    NSMutableDictionary *_wordByUUID;

    NSMutableArray *_filterPersonRefNameInitials;
    NSMutableDictionary *_filterPersonRefsByInitial;
    NSMutableArray *_filterPersonRefs;

    NSMutableArray *_schoolYearRefTypes;
    NSArray *_schoolYearRefTypePosition;
    NSMutableDictionary *_schoolYearRefsByType;
    
    NSMutableArray *_filterWordInitials;
    NSMutableDictionary *_filterWordsByInitial;
    NSMutableArray *_filterWords;
}

@synthesize settings = _settings;

- (void)setup:(BOOL)isNew {
    if (!self.settings) {
        self.settings = [Settings new];
    }
    if (!self.personRef) {
        self.personRef = (NSMutableArray<PersonRef> *)[@[] mutableCopy];
    }
    if (!self.schoolYearRef) {
        self.schoolYearRef = (NSMutableArray<SchoolYearRef> *)[@[] mutableCopy];
    }
    if (!self.photoUUID) {
        self.photoUUID = [NSMutableSet new];
    }
    if (!self.attachmentUUID) {
        self.attachmentUUID = [NSMutableSet new];
    }
    if (!self.pencilStyle) {
        self.pencilStyle = [[[NSMutableArray alloc] initWithObjects:kImageAnnotationDefaultPencilStyle, nil] mutableCopy];
    }
    if (!self.word) {
        self.word = [@[] mutableCopy];
    }
    if (!self.menuSelection) {
        self.menuSelection = [@[] mutableCopy];
    }
    if (!self.contentSelection) {
        self.contentSelection = [@[] mutableCopy];
    }
    if (!self.tabSelection) {
        self.tabSelection = [@{} mutableCopy];
    }

    _photoByUUID = [@{} mutableCopy];
    _attachmentByUUID = [@{} mutableCopy];
    _personByUUID = [@{} mutableCopy];
    _schoolYearByUUID = [@{} mutableCopy];
    _wordByUUID = [@{} mutableCopy];

    _filterPersonRefs = [[NSArray arrayWithArray:self.personRef] mutableCopy];
    [self sortPersonRef];
    
    _schoolYearRefTypePosition = @[@(CodeSchoolYearTypeActive),
                                   @(CodeSchoolYearTypePlanned),
                                   @(CodeSchoolYearTypeCompleted)];
    [self sortSchoolYearRef];
    
    for (Word *word in self.word) {
        word.parent = self;
        _wordByUUID[word.uuid] = word;
    }
    
    _filterWords = [[NSArray arrayWithArray:self.word] mutableCopy];
    [self sortWord];
}

+ (Application *)load:(NSString *)uuid {
    Application *application = (Application *)[Utilities readEntity:uuid folder:uuid class:Application.class];
    if (application) {
        [application setProperty:@"uuid" value:uuid];
    }
    return application;
}

- (NSString *)applicationFolder {
    return self.uuid;
}

- (BOOL)store {
    [Utilities createEntityFolder:self.applicationFolder];
    return [Utilities writeEntity:self.uuid folder:self.applicationFolder entity:self];
}

- (BOOL)exportData {
    [Utilities createFolder:[[Utilities generatedFolder] stringByAppendingPathComponent:self.applicationFolder]];
    return [Utilities exportEntity:self.uuid folder:self.applicationFolder entity:self];
}

- (void)setSuppressProtected:(BOOL)suppressProtected {
    for (SchoolYear *schoolYear in self.loadedSchoolYear) {
        [schoolYear setSuppressProtected:suppressProtected];
    }
}

- (void)markDirty:(BOOL)dirty {
}

+ (Application *)createApplication:(NSString *)uuid {
    Application *application = [Application new];
    if (uuid) {
        [application setProperty:@"uuid" value:uuid];
    }
    [application store];
    return application;
}

+ (BOOL)deleteApplication:(NSString *)uuid {
    return [Utilities deleteEntityFolder:uuid];
}

+ (BOOL)copyApplication:(NSString *)uuid {
    return [Utilities copyApplication:uuid];
}

+ (BOOL)importApplication:(NSString *)filePath type:(NSString *)type password:(NSString *)password {
    if ([type isEqualToString:kApplicationImportTypeExport]) {
        return [Utilities importApplication:filePath password:password];
    } else if ([type isEqualToString:kApplicationImportTypeBackup]) {
        return [Utilities restoreApplication:filePath];
    }
    return NO;
}

#pragma mark SELECTION

- (void)pushMenuSelection:(NSString *)uuid {
    [self.menuSelection addObject:uuid];
}

- (void)popMenuSelection {
    [self.menuSelection removeLastObject];
}

#pragma mark PHOTO

- (Photo *)photoByUUID:(NSString *)uuid {
    Photo *photo = _photoByUUID[uuid];
    if (!photo) {
        photo = [Photo load:uuid];
        if (photo) {
            _photoByUUID[uuid] = photo;
        }
    }
    return photo;
}

- (Photo *)addPhoto:(NSDictionary *)parameters {
    NSData *data = parameters[@"data"];
    NSString *name = parameters[@"name"];
    Photo *photo = [Photo new];
    photo.data = data;
    photo.name = name;
    [self insertPhoto:photo];
    return photo;
}

- (void)insertPhoto:(Photo *)photo {
    _photoByUUID[photo.uuid] = photo;
    [self.photoUUID addObject:photo.uuid];
    photo.parent = self;
}

- (void)removePhotoByUUID:(NSString *)uuid {
    [[self photoByUUID:uuid] willBeRemoved];
    [self.photoUUID removeObject:uuid];
    [_photoByUUID removeObjectForKey:uuid];
}

- (void)removePhoto:(Photo *)photo {
    [self removePhotoByUUID:photo.uuid];
}

- (NSArray *)loadedPhoto {
    return _photoByUUID.allValues;
}

#pragma mark ATTACHMENT

- (Attachment *)attachmentByUUID:(NSString *)uuid {
    Attachment *attachment = _attachmentByUUID[uuid];
    if (!attachment) {
        attachment = [Attachment load:uuid];
        if (attachment) {
            _attachmentByUUID[uuid] = attachment;
        }
    }
    return attachment;
}

- (Attachment *)addAttachment:(NSDictionary *)parameters {
    NSData *data = parameters[@"data"];
    Attachment *attachment = [Attachment new];
    attachment.data = data;
    [self insertAttachment:attachment];
    return attachment;
}

- (void)insertAttachment:(Attachment *)attachment {
    _attachmentByUUID[attachment.uuid] = attachment;
    [self.attachmentUUID addObject:attachment.uuid];
    attachment.parent = self;
}

- (void)removeAttachmentByUUID:(NSString *)uuid {
    [[self attachmentByUUID:uuid] willBeRemoved];
    [self.attachmentUUID removeObject:uuid];
    [_attachmentByUUID removeObjectForKey:uuid];
}

- (void)removeAttachment:(Attachment *)attachment {
    [self removeAttachmentByUUID:attachment.uuid];
}

- (NSArray *)loadedAttachment {
    return _attachmentByUUID.allValues;
}

#pragma mark PERSON

- (NSInteger)numberOfPersonRef {
    return _filterPersonRefs.count;
}

- (NSInteger)numberOfPersonRefGroup {
    return _filterPersonRefNameInitials.count;
}

- (NSInteger)numberOfPersonRefByGroup:(NSInteger)group {
    NSString *initial = _filterPersonRefNameInitials[group];
    if (_filterPersonRefsByInitial[initial]) {
        return [_filterPersonRefsByInitial[initial] count];
    }
    return 0;
}

- (NSInteger)numberOfPersonRefByGroupName:(NSString *)groupName {
    if (_filterPersonRefsByInitial[groupName]) {
        return [_filterPersonRefsByInitial[groupName] count];
    }
    return 0;
}

- (NSString *)personRefGroupName:(NSInteger)group {
    if (group >= 0 && group < _filterPersonRefNameInitials.count) {
        return _filterPersonRefNameInitials[group];
    }
    return nil;
}

- (NSIndexPath *)personRefGroupIndexByUUID:(NSString *)uuid {
    NSInteger group = 0;
    for (NSString *initial in _filterPersonRefNameInitials) {
        NSInteger index = 0;
        for (PersonRef *personRef in _filterPersonRefsByInitial[initial]) {
            if ([personRef.uuid isEqualToString:uuid]) {
                return [NSIndexPath indexPathForRow:index inSection:group];
            }
            index++;
        }
        group++;
    }
    return nil;
}

- (PersonRef *)personRefByGroup:(NSInteger)group index:(NSInteger)index {
    if (group >= 0 && group < _filterPersonRefNameInitials.count) {
        NSString *initial = _filterPersonRefNameInitials[group];
        if (index >= 0 && index < [_filterPersonRefsByInitial[initial] count]) {
            return _filterPersonRefsByInitial[initial][index];
        }
    }
    return nil;
}

- (PersonRef *)personRefByUUID:(NSString *)uuid {
    for (PersonRef *personRef in self.personRef) {
        if ([personRef.uuid isEqual:uuid]) {
            return personRef;
        }
    }
    return nil;
}

- (Person *)personByGroup:(NSInteger)group index:(NSInteger)index {
    return [self personByUUID:[self personRefByGroup:group index:index].uuid];
}

- (Person *)personByUUID:(NSString *)uuid {
    Person *person = _personByUUID[uuid];
    if (!person) {
        person = [Person load:uuid];
        if (person) {
            _personByUUID[uuid] = person;
        }
    }
    return person;
}

- (Person *)addPerson {
    Person *person = [Person new];
    [self insertPerson:person];
    return person;
}

- (void)insertPerson:(Person *)person {
    [self.personRef insertObject:person.ref atIndex:0];
    if (_filterPersonRefs) {
        [_filterPersonRefs insertObject:person.ref atIndex:0];
    }
    _personByUUID[person.uuid] = person;
    [_filterPersonRefsByInitial[@""] insertObject:person.ref atIndex:0];
    person.parent = self;
}

- (void)removePersonRefByUUID:(NSString *)uuid {
    [self removePersonByUUID:uuid];
}

- (void)removePersonByUUID:(NSString *)uuid {
    PersonRef *personRef = [self personRefByUUID:uuid];
    [personRef willBeRemoved];
    [[self personByUUID:uuid] willBeRemoved];
    [self.personRef removeObject:personRef];
    if (_filterPersonRefs) {
        [_filterPersonRefs removeObject:personRef];
    }
    for (NSString *initial in _filterPersonRefNameInitials) {
        if ([_filterPersonRefsByInitial[initial] containsObject:personRef]) {
            [_filterPersonRefsByInitial[initial] removeObject:personRef];
            if ([_filterPersonRefsByInitial[initial] count] == 0 && ![initial isEqualToString:@""]) {
                [_filterPersonRefsByInitial removeObjectForKey:initial];
                [_filterPersonRefNameInitials removeObject:initial];
            }
            break;
        }
    }
    [_personByUUID removeObjectForKey:uuid];
}

- (void)removePerson:(Person *)person {
    [self removePersonByUUID:person.uuid];
}

- (void)removePersonRef:(PersonRef *)personRef {
    [self removePersonByUUID:personRef.uuid];
}

- (void)sortPersonRef {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    self.personRef = [[self.personRef sortedArrayUsingDescriptors:@[sort]] mutableCopy];
    _filterPersonRefs = [[_filterPersonRefs sortedArrayUsingDescriptors:@[sort]] mutableCopy];

    _filterPersonRefNameInitials = [@[ @"" ] mutableCopy];
    _filterPersonRefsByInitial = [@{ @"" : [@[] mutableCopy] } mutableCopy];
    
    for (PersonRef *personRef in _filterPersonRefs) {
        NSString *initial = [(personRef.name.length > 0 ? [personRef.name substringToIndex:1] : @"") uppercaseString];
        NSMutableArray *personRefsByInitial = _filterPersonRefsByInitial[initial];
        if (!personRefsByInitial) {
            personRefsByInitial = [@[] mutableCopy];
            _filterPersonRefsByInitial[initial] = personRefsByInitial;
            [_filterPersonRefNameInitials addObject:initial];
        }
        [personRefsByInitial addObject:personRef];
    }
    
    _filterPersonRefNameInitials = [[_filterPersonRefNameInitials sortedArrayUsingSelector:
                                 @selector(localizedCaseInsensitiveCompare:)] mutableCopy];
}

- (NSArray *)personRefIndex {
    return _filterPersonRefNameInitials;
}

- (NSArray *)loadedPerson {
    return _personByUUID.allValues;
}

- (void)filterPersonRefBy:(NSString *)filter {
    if (!filter || [filter isEqualToString:@""]) {
        _filterPersonRefs = [[NSArray arrayWithArray:self.personRef] mutableCopy];
    } else {
        _filterPersonRefs = [@[] mutableCopy];
        for (PersonRef *personRef in self.personRef) {
            if ([personRef.name rangeOfString:filter options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [_filterPersonRefs addObject:personRef];
            }
        }
    }
    [self sortPersonRef];
}

- (void)resetFilterPersonRef {
    [self filterPersonRefBy:nil];
}

#pragma mark SCHOOL YEAR

- (NSInteger)numberOfSchoolYearRef {
    return self.schoolYearRef.count;
}

- (NSInteger)numberOfSchoolYearRefGroup {
    return _schoolYearRefTypes.count;
}

- (NSInteger)numberOfSchoolYearRefByGroup:(NSInteger)group {
    id type = _schoolYearRefTypes[group];
    if (_schoolYearRefsByType[type]) {
        return [_schoolYearRefsByType[type] count];
    }
    return 0;

}

- (NSInteger)numberOfSchoolYearRefByGroupName:(NSString *)groupName {
    for (id type in _schoolYearRefTypes) {
        CodeSchoolYearType value = [type integerValue];
        NSString *text = [Codes textForCode:kCodeSchoolYearType value:value];
        if ([text isEqualToString:groupName]) {
            return [_schoolYearRefsByType[type] count];
        }
    }
    return 0;
}

- (NSString *)schoolYearRefGroupName:(NSInteger)group {
    if (group >= 0 && group < _schoolYearRefTypes.count) {
        CodeSchoolYearType value = [_schoolYearRefTypes[group] integerValue];
        return [Codes textForCode:kCodeSchoolYearType value:value];
    }
    return nil;
}

- (NSIndexPath *)schoolYearRefGroupIndexByUUID:(NSString *)uuid {
    NSInteger group = 0;
    for (id type in _schoolYearRefTypes) {
        NSInteger index = 0;
        for (SchoolYearRef *schoolYearRef in _schoolYearRefsByType[type]) {
            if ([schoolYearRef.uuid isEqualToString:uuid]) {
                return [NSIndexPath indexPathForRow:index inSection:group];
            }
            index++;
        }
        group++;
    }
    return nil;
}

- (SchoolYearRef *)schoolYearRefByGroup:(NSInteger)group index:(NSInteger)index {
    if (group >= 0 && group < _schoolYearRefTypes.count) {
        id type = _schoolYearRefTypes[group];
        if (index >= 0 && index < [_schoolYearRefsByType[type] count]) {
            return _schoolYearRefsByType[type][index];
        }
    }
    return nil;
}

- (SchoolYearRef *)schoolYearRefByIndex:(NSInteger)index {
    if (index >= 0 && index < [self.schoolYearRef count]) {
        return self.schoolYearRef[index];
    }
    return nil;
}

- (SchoolYearRef *)schoolYearRefByUUID:(NSString *)uuid {
    for (SchoolYearRef *schoolYearRef in self.schoolYearRef) {
        if ([schoolYearRef.uuid isEqual:uuid]) {
            return schoolYearRef;
        }
    }
    return nil;
}

- (SchoolYear *)schoolYearByGroup:(NSInteger)group index:(NSInteger)index {
    return [self schoolYearByUUID:[self schoolYearRefByGroup:group index:index].uuid];
}

- (SchoolYear *)schoolYearByIndex:(NSInteger)index {
    return [self schoolYearByUUID:[self schoolYearRefByIndex:index].uuid];
}

- (SchoolYear *)schoolYearByUUID:(NSString *)uuid {
    SchoolYear *schoolYear = _schoolYearByUUID[uuid];
    if (!schoolYear) {
        schoolYear = [SchoolYear load:uuid];
        if (schoolYear) {
            _schoolYearByUUID[uuid] = schoolYear;
        }
    }
    return schoolYear;
}

- (SchoolYear *)activeSchoolYear {
    for (SchoolYearRef *schoolYearRef in self.schoolYearRef) {
        if ([schoolYearRef.isActive boolValue]) {
            return [self schoolYearByUUID:schoolYearRef.uuid];
        }
    }
    return nil;
}

- (SchoolYear *)addSchoolYear {
    SchoolYear *schoolYear = [SchoolYear new];
    [self insertSchoolYear:schoolYear];
    return schoolYear;
}

- (void)insertSchoolYear:(SchoolYear *)schoolYear {
    NSInteger count = 0;
    for (SchoolYearRef *schoolYearRef in self.schoolYearRef) {
        if ([schoolYearRef.name hasPrefix:schoolYear.name]) {
            count++;
        }
    }
    if (count > 0) {
        schoolYear.name = [NSString stringWithFormat:@"%@ (%@)", schoolYear.name, @(count + 1)];
    }
    [self.schoolYearRef insertObject:schoolYear.ref atIndex:0];
    _schoolYearByUUID[schoolYear.uuid] = schoolYear;
    
    NSMutableArray *schoolYearRefsByType = _schoolYearRefsByType[@(CodeSchoolYearTypePlanned)];
    if (!schoolYearRefsByType) {
        schoolYearRefsByType = [@[] mutableCopy];
        _schoolYearRefsByType[@(CodeSchoolYearTypePlanned)] = schoolYearRefsByType;
        [_schoolYearRefTypes addObject:@(CodeSchoolYearTypePlanned)];
        _schoolYearRefTypes = [[_schoolYearRefTypes sortedArrayUsingComparator:^NSComparisonResult(id type1, id type2) {
            return [self->_schoolYearRefTypePosition indexOfObject:type1] - [self->_schoolYearRefTypePosition indexOfObject:type2];
        }] mutableCopy];
    }
    [schoolYearRefsByType insertObject:schoolYear.ref atIndex:0];
    schoolYear.parent = self;
}

- (SchoolYear *)copySchoolYear:(SchoolYear *)schoolYear {
    SchoolYear *schoolYearCopy = [schoolYear copy];
    [self insertSchoolYear:schoolYearCopy];
    return schoolYearCopy;
}

- (void)removeSchoolYearRefByUUID:(NSString *)uuid {
    [self removeSchoolYearByUUID:uuid];
}

- (void)removeSchoolYearByUUID:(NSString *)uuid {
    SchoolYearRef *schoolYearRef = [self schoolYearRefByUUID:uuid];
    [schoolYearRef willBeRemoved];
    [[self schoolYearByUUID:uuid] willBeRemoved];
    [self.schoolYearRef removeObject:schoolYearRef];
    [_schoolYearByUUID removeObjectForKey:uuid];

    NSMutableArray *schoolYearRefsByType = _schoolYearRefsByType[@(schoolYearRef.type)];
    [schoolYearRefsByType removeObject:schoolYearRef];
    if (schoolYearRefsByType.count == 0) {
        [_schoolYearRefsByType removeObjectForKey:@(schoolYearRef.type)];
        [_schoolYearRefTypes removeObject:@(schoolYearRef.type)];
    }
}

- (void)removeSchoolYear:(SchoolYear *)schoolYear {
    [self removeSchoolYearByUUID:schoolYear.uuid];
}

- (void)removeSchoolYearRef:(SchoolYearRef *)schoolYearRef {
    [self removeSchoolYearByUUID:schoolYearRef.uuid];
}

- (void)sortSchoolYearRef {
    self.schoolYearRef = [[self.schoolYearRef sortedArrayUsingComparator:^NSComparisonResult(SchoolYearRef *schoolYearRef1, SchoolYearRef *schoolYearRef2) {
        int num1;
        BOOL num1Found = [[NSScanner scannerWithString:schoolYearRef1.name] scanInt:&num1];
        int num2;
        BOOL num2Found = [[NSScanner scannerWithString:schoolYearRef2.name] scanInt:&num2];
        if (num1Found && num2Found) {
            if (num1 < 100) {
                num1 = 2000 + num1;
            }
            if (num2 < 100) {
                num2 = 2000 + num2;
            }
            return -(num1 - num2);
            
        }
        return [schoolYearRef1.name compare:schoolYearRef2.name];
    }] mutableCopy];
    
    _schoolYearRefTypes = [@[ @"" ] mutableCopy];
    _schoolYearRefsByType = [@{ } mutableCopy];
    
    for (SchoolYearRef *schoolYeaRef in self.schoolYearRef) {
        NSMutableArray *schoolYearRefsByType = _schoolYearRefsByType[@(schoolYeaRef.type)];
        if (!schoolYearRefsByType) {
            schoolYearRefsByType = [@[] mutableCopy];
            _schoolYearRefsByType[@(schoolYeaRef.type)] = schoolYearRefsByType;
            [_schoolYearRefTypes addObject:@(schoolYeaRef.type)];
        }
        [schoolYearRefsByType addObject:schoolYeaRef];
    }
    
    _schoolYearRefTypes = [[_schoolYearRefTypes sortedArrayUsingComparator:^NSComparisonResult(id type1, id type2) {
        return [self->_schoolYearRefTypePosition indexOfObject:type1] - [self->_schoolYearRefTypePosition indexOfObject:type2];
    }] mutableCopy];
}

- (NSArray *)loadedSchoolYear {
    return _schoolYearByUUID.allValues;
}

#pragma mark PENCIL STYLES

- (NSArray *)pencilStyles {
    return self.pencilStyle;
}

- (void)addPencilStyle:(PencilStyle *)pencilStyle {
    [self.pencilStyle removeObject:pencilStyle];
    [self.pencilStyle insertObject:pencilStyle atIndex:0];
    if (self.pencilStyle.count > kImageAnnotationMaxHistoryPencilStyle) {
        [self.pencilStyle removeLastObject];
    }
}

#pragma mark DICTIONARY WORD

- (NSInteger)numberOfWord {
    return _filterWords.count;
}

- (NSInteger)numberOfWordGroup {
    return _filterWordInitials.count;
}

- (NSInteger)numberOfWordByGroup:(NSInteger)group {
    NSString *initial = _filterWordInitials[group];
    if (_filterWordsByInitial[initial]) {
        return [_filterWordsByInitial[initial] count];
    }
    return 0;

}

- (NSInteger)numberOfWordByGroupName:(NSString *)groupName {
    if (_filterWordsByInitial[groupName]) {
        return [_filterWordsByInitial[groupName] count];
    }
    return 0;
}

- (NSString *)wordGroupName:(NSInteger)group {
    if (group >= 0 && group < _filterWordsByInitial.count) {
        return _filterWordInitials[group];
    }
    return nil;
}

- (NSIndexPath *)wordGroupIndexByUUID:(NSString *)uuid {
    NSInteger group = 0;
    for (NSString *initial in _filterWordInitials) {
        NSInteger index = 0;
        for (Word *word in _filterWordsByInitial[initial]) {
            if ([word.uuid isEqualToString:uuid]) {
                return [NSIndexPath indexPathForRow:index inSection:group];
            }
            index++;
        }
        group++;
    }
    return nil;
}

- (NSString *)wordByGroup:(NSInteger)group index:(NSInteger)index {
    if (group >= 0 && group < _filterWordInitials.count) {
        NSString *initial = _filterWordInitials[group];
        if (index >= 0 && index < [_filterWordsByInitial[initial] count]) {
            return _filterWordsByInitial[initial][index];
        }
    }
    return nil;
}

- (Word *)wordByUUID:(NSString *)uuid {
    return _wordByUUID[uuid];
}

- (Word *)addWord {
    Word *word = [Word new];
    [self insertWord:word];
    return word;
}

- (void)insertWord:(Word *)word {
    [self.word insertObject:word atIndex:0];
    if (_filterWords) {
        [_filterWords insertObject:word atIndex:0];
    }
    _wordByUUID[word.uuid] = word;
    [_filterWordsByInitial[@""] insertObject:word atIndex:0];
    word.parent = self;
}

- (void)removeWordByUUID:(NSString *)uuid {
    Word *word = [self wordByUUID:uuid];
    [word willBeRemoved];
    [self.word removeObject:word];
    if (_filterWords) {
        [_filterWords removeObject:word];
    }
    for (NSString *initial in _filterWordInitials) {
        if ([_filterWordsByInitial[initial] containsObject:word]) {
            [_filterWordsByInitial[initial] removeObject:word];
            if ([_filterWordsByInitial[initial] count] == 0 && ![initial isEqualToString:@""]) {
                [_filterWordsByInitial removeObjectForKey:initial];
                [_filterWordInitials removeObject:initial];
            }
            break;
        }
    }
    [_wordByUUID removeObjectForKey:uuid];
}

- (void)removeWord:(Word *)word {
    [self removeWordByUUID:word.uuid];
}

- (void)sortWord {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    self.word = [[self.word sortedArrayUsingDescriptors:@[sort]] mutableCopy];
    _filterWords = [[_filterWords sortedArrayUsingDescriptors:@[sort]] mutableCopy];
    
    _filterWordInitials = [@[ @"" ] mutableCopy];
    _filterWordsByInitial = [@{ @"" : [@[] mutableCopy] } mutableCopy];
    
    for (Word *word in _filterWords) {
        NSString *initial = [(word.name.length > 0 ? [word.name substringToIndex:1] : @"") uppercaseString];
        NSMutableArray *wordsByInitial = _filterWordsByInitial[initial];
        if (!wordsByInitial) {
            wordsByInitial = [@[] mutableCopy];
            _filterWordsByInitial[initial] = wordsByInitial;
            [_filterWordInitials addObject:initial];
        }
        [wordsByInitial addObject:word];
    }
    
    _filterPersonRefNameInitials = [[_filterPersonRefNameInitials sortedArrayUsingSelector:
                                     @selector(localizedCaseInsensitiveCompare:)] mutableCopy];
}

- (NSArray *)wordIndex {
     return _filterWordInitials;
}

- (void)filterWordBy:(NSString *)filter {
    if (!filter || [filter isEqualToString:@""]) {
        _filterWords = [[NSArray arrayWithArray:self.word] mutableCopy];
    } else {
        _filterWords = [@[] mutableCopy];
        for (Word *word in self.word) {
            if ([word.name rangeOfString:filter options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [_filterWords addObject:word];
            }
        }
    }
    [self sortWord];
}

- (void)resetFilterWord {
    [self filterWordBy:nil];
}

- (NSNumber *)containsWord:(NSString *)wordSearch {
    BOOL found = NO;
    for (Word *word in self.word) {
        if ([word.name isEqualToString:wordSearch]) {
            found = YES;
        }
    }
    return @(found);
}

#pragma mark OTHER

- (void)addPersonUsage:(NSString *)personUUID {
    [[[Model instance] application] personByUUID:personUUID].useCount++;
}

- (void)removePersonUsage:(NSString *)personUUID {
    [[[Model instance] application] personByUUID:personUUID].useCount--;
}

- (void)cleanup {
    [_photoByUUID removeAllObjects];
    [_attachmentByUUID removeAllObjects];
    [_personByUUID removeAllObjects];
    [_schoolYearByUUID removeAllObjects];
}

@end
