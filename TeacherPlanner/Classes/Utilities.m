//
//  Utilities.m
//  TeacherPlanner
//
//  Created by Oliver on 29.12.13.
//
//

#import "Utilities.h"
#import "JSONEntity.h"
#import "SecureStore.h"
#import "ZipArchive.h"

#define kDataExtension   @"data"
#define kCryptExtension  @"crypt"

#define kDataFolder      @"Data"
#define kGeneratedFolder @"Generated"
#define kExportFolder    @"Export"
#define kBackupFolder    @"Backup"

@implementation Utilities

#pragma mark GENERAL

+ (BOOL)createFolder:(NSString *)folder {
    if (![self pathExists:folder]) {
        return [[NSFileManager defaultManager] createDirectoryAtPath:folder
                                         withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return YES;
}

+ (NSString *)createTempFolder {
    NSString *folder = [self createUUID];
    NSString *folderPath = [[self generatedFolder] stringByAppendingPathComponent:folder];
    if ([self createFolder:folderPath]) {
        return folder;
    }
    return nil;
}

+ (BOOL)pathExists:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    return [fileManager fileExistsAtPath:path isDirectory:&isDir];
}

+ (BOOL)deletePath:(NSString *)path {
    if ([Utilities pathExists:path]) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        [fileManager removeItemAtPath:path error:&error];
        if (error) {
            return NO;
        }
    }
    return YES;
}

+ (NSData *)read:(NSString *)path {
    return [NSData dataWithContentsOfFile:path];
}

+ (NSArray *)readContent:(NSString *)folder {
    if ([Utilities pathExists:folder]) {
        return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folder error:nil];
    }
    return @[];
}

+ (NSDictionary *)readAttributes:(NSString *)path {
    if ([Utilities pathExists:path]) {
        return [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    }
    return nil;
}

+ (NSURL *)writeGeneratedFile:(NSData *)data path:(NSString *)path {
    NSString *filePath = [[NSString alloc] initWithString:[[Utilities generatedFolder] stringByAppendingPathComponent:path]];
    [data writeToFile:filePath atomically:YES];
    return [NSURL fileURLWithPath:filePath];
}

#pragma mark FOLDER

+ (NSString *)tempFolder {
    return NSTemporaryDirectory();
}

+ (NSString *)generatedFolder {
    NSString *generatedFolder = [[Utilities tempFolder] stringByAppendingPathComponent:kGeneratedFolder];
    if (![Utilities pathExists:generatedFolder]) {
        [Utilities createFolder:generatedFolder];
    }
    return generatedFolder;
}

+ (NSString *)entityFolder {
    NSString *documentFolder = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    NSString *dataFolder = [documentFolder stringByAppendingPathComponent:kDataFolder];
    if (![Utilities pathExists:dataFolder]) {
        [Utilities createFolder:dataFolder];
    }
    return dataFolder;
}

+ (NSString *)exportFolder {
    NSString *documentFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *exportFolder = [documentFolder stringByAppendingPathComponent:kExportFolder];
    if (![Utilities pathExists:exportFolder]) {
        [Utilities createFolder:exportFolder];
    }
    return exportFolder;
}

+ (NSString *)backupFolder {
    NSString *documentFolder = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    NSString *backupFolder = [documentFolder stringByAppendingPathComponent:kBackupFolder];
    if (![Utilities pathExists:backupFolder]) {
        [Utilities createFolder:backupFolder];
    }
    return backupFolder;
}

+ (BOOL)clearGeneratedFolder {
    BOOL result = [Utilities deletePath:[Utilities generatedFolder]];
    [Utilities generatedFolder];
    return result;
}

#pragma mark ENTITY

+ (NSArray *)readEntities {
    return [Utilities readContent:[Utilities entityFolder]];
}

+ (NSDictionary *)readEntityAttributes:(NSString *)name {
    NSString *entityPath = [[[Utilities entityFolder] stringByAppendingPathComponent:name] stringByAppendingPathComponent:[name stringByAppendingPathExtension:kDataExtension]];
    NSDictionary *attributes = [Utilities readAttributes:entityPath];
    if (!attributes) {
        entityPath = [[Utilities entityFolder] stringByAppendingPathComponent:name];
        attributes = [Utilities readAttributes:entityPath];
    }
    return attributes;
}

+ (BOOL)createEntityFolder:(NSString *)name {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSString *entityPath = [[Utilities entityFolder] stringByAppendingPathComponent:name];
    if (![self pathExists:entityPath]) {
        return [fileManager createDirectoryAtPath:entityPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    return YES;
}

+ (BOOL)entityExists:(NSString *)name {
    NSString *entityPath = [[Utilities entityFolder] stringByAppendingPathComponent:name];
    return [self pathExists:entityPath];
}

+ (BOOL)isEntityFolder:(NSString *)name {
    if ([Utilities entityExists:name]) {
        NSString *entityPath = [[Utilities entityFolder] stringByAppendingPathComponent:name];
        BOOL isDir = NO;
        return [[NSFileManager defaultManager] fileExistsAtPath:entityPath isDirectory:&isDir] && isDir;
    }
    return NO;
}

+ (BOOL)writeEntity:(NSString *)name folder:(NSString *)folder entity:(JSONEntity *)entity {
    NSString *entityPath = [folder stringByAppendingPathComponent:name];
    entityPath = [[Utilities entityFolder] stringByAppendingPathComponent:entityPath];
    NSString *entityDataPath = [entityPath stringByAppendingPathExtension:kDataExtension];
    NSData *encodedEntity = [Utilities encodeEntity:entity];
    NSDictionary *cryptInfo = [Utilities encryptData:encodedEntity];
    if (cryptInfo) {
        if ([Utilities writeDataFile:entityDataPath data:cryptInfo[@"data"]]) {
            NSString *entityCryptPath = [entityPath stringByAppendingPathExtension:kCryptExtension];
            cryptInfo = @{ @"iv" : cryptInfo[@"iv"], @"digest" : cryptInfo[@"digest" ]};
            NSData *cryptInfoData = [NSKeyedArchiver archivedDataWithRootObject:cryptInfo];
            if ([Utilities writeDataFile:entityCryptPath data:cryptInfoData]) {
                return YES;
            }
        }
    }
    return NO;
}

+ (BOOL)exportEntity:(NSString *)name folder:(NSString *)folder entity:(JSONEntity *)entity {
    NSString *entityPath = [folder stringByAppendingPathComponent:name];
    entityPath = [[Utilities generatedFolder] stringByAppendingPathComponent:entityPath];
    NSString *entityDataPath = [entityPath stringByAppendingPathExtension:kDataExtension];
    NSData *encodedEntity = [Utilities encodeEntity:entity];
    return [Utilities writeDataFile:entityDataPath data:encodedEntity];
}

+ (NSData *)encodeEntity:(JSONEntity *)entity {
    NSString *json = entity.toJSONString;
    return [json dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSDictionary *)encryptData:(NSData *)data {
    SecureStore *secureStore = [SecureStore instance];
    NSData *digest = [secureStore dataDigest:data];
    NSDictionary *cryptInfo = [secureStore encryptData:data];
    if (cryptInfo) {
        return @{ @"iv" : cryptInfo[@"iv"], @"data" : cryptInfo[@"data"], @"digest" : digest };
    } else {
        return nil;
    }
}

+ (BOOL)writeDataFile:(NSString *)path data:(NSData *)data {
    NSError *error = nil;
    [data writeToFile:path options:NSDataWritingFileProtectionComplete error:&error];
    [[NSFileManager defaultManager] setAttributes:[NSDictionary dictionaryWithObject:NSFileProtectionComplete forKey:NSFileProtectionKey] ofItemAtPath:path error:&error];
    return !error;
}

+ (JSONEntity *)readEntity:(NSString *)name folder:(NSString *)folder class:(Class)class {
    NSString *entityPath = [folder stringByAppendingPathComponent:name];
    entityPath = [[Utilities entityFolder] stringByAppendingPathComponent:entityPath];
    NSString *entityDataPath = [entityPath stringByAppendingPathExtension:kDataExtension];
    NSData *encryptedEntityData = [Utilities readDataFile:entityDataPath];
    if (encryptedEntityData) {
        NSString *entityCryptPath = [entityPath stringByAppendingPathExtension:kCryptExtension];
        NSData *cryptInfoData = [Utilities readDataFile:entityCryptPath];
        if (cryptInfoData) {
            NSDictionary *cryptInfo = [NSKeyedUnarchiver unarchiveObjectWithData:cryptInfoData];
            NSData *entityData = [Utilities decryptData:encryptedEntityData cryptInfo:cryptInfo];
            if (entityData) {
                return [Utilities decodeEntity:entityData class:class];
            }
        }
    }
    return nil;
}

+ (NSData *)decryptData:(NSData *)data cryptInfo:(NSDictionary *)cryptInfo {
    return [[SecureStore instance] decryptData:data cryptInfo:cryptInfo];
}

+ (JSONEntity *)decodeEntity:(NSData *)entityData class:(Class)class {
    NSString *entityString = [[NSString alloc] initWithData:entityData encoding:NSUTF8StringEncoding];
    NSError *err = nil;
    JSONEntity *entity = [[class alloc] initWithString:entityString error:&err];
    return entity;
}

+ (NSData *)readDataFile:(NSString *)path {
    return [NSData dataWithContentsOfFile:path];
}

+ (BOOL)deleteEntityFolder:(NSString *)name {
    NSString *entityPath = [[Utilities entityFolder] stringByAppendingPathComponent:name];
    return [Utilities deletePath:entityPath];
}

+ (BOOL)deleteEntity:(NSString *)name folder:(NSString *)folder {
    NSString *entityPath = [folder stringByAppendingPathComponent:name];
    entityPath = [[Utilities entityFolder] stringByAppendingPathComponent:entityPath];
    NSString *entityDataPath = [entityPath stringByAppendingPathExtension:kDataExtension];
    if ([Utilities deletePath:entityDataPath]) {
        NSString *entityCryptPath = [entityPath stringByAppendingPathExtension:kCryptExtension];
        if ([Utilities deletePath:entityCryptPath]) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)renameApplicationFile:(NSString *)fromName to:(NSString *)toName {
    NSString *entityPath = [[Utilities entityFolder] stringByAppendingPathComponent:toName];
    
    NSString *entityDataPath = [fromName stringByAppendingPathExtension:kDataExtension];
    NSString *entityCryptPath = [fromName stringByAppendingPathExtension:kCryptExtension];
    NSString *applicationDataPath = [entityPath stringByAppendingPathComponent:entityDataPath];
    NSString *applicationCryptPath = [entityPath stringByAppendingPathComponent:entityCryptPath];
    
    NSString *newEntityDataPath = [toName stringByAppendingPathExtension:kDataExtension];
    NSString *newEntityCryptPath = [toName stringByAppendingPathExtension:kCryptExtension];
    NSString *newApplicationDataPath = [entityPath stringByAppendingPathComponent:newEntityDataPath];
    NSString *newApplicationCryptPath = [entityPath stringByAppendingPathComponent:newEntityCryptPath];
    NSError *error;
    [[NSFileManager defaultManager] moveItemAtPath:applicationDataPath toPath:newApplicationDataPath error:&error];
    if (!error) {
        NSDictionary *attributes = @{ NSFileModificationDate : [NSDate date] };
        [[NSFileManager defaultManager] setAttributes:attributes ofItemAtPath:newApplicationDataPath error:&error];
        if (!error) {
            [[NSFileManager defaultManager] moveItemAtPath:applicationCryptPath toPath:newApplicationCryptPath
                                                     error:&error];
            if (!error) {
                [[NSFileManager defaultManager] setAttributes:attributes ofItemAtPath:newApplicationCryptPath
                                                        error:&error];
                return !error;
            }
        }
    }
    [Utilities deletePath:entityPath];
    return NO;
}

+ (BOOL)copyApplication:(NSString *)name {
    NSString *entityPath = [[Utilities entityFolder] stringByAppendingPathComponent:name];
    if ([Utilities pathExists:entityPath]) {
        NSString *newName = [Utilities createUUID];
        NSString *newEntityPath = [[Utilities entityFolder] stringByAppendingPathComponent:newName];
        NSError *error = nil;
        [[NSFileManager defaultManager] copyItemAtPath:entityPath toPath:newEntityPath error:&error];
        if (!error) {
            return [Utilities renameApplicationFile:name to:newName];
        }
    }
    return NO;
}

+ (BOOL)zipFolder:(NSString *)folderPath targetPath:(NSString *)targetPath password:(NSString *)password {
    ZipArchive *zipArchive = [ZipArchive new];
    BOOL success = [zipArchive CreateZipFile2:targetPath Password:password];
    NSArray *content = [Utilities readContent:folderPath];
    for (NSString *fileName in content) {
        NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
        BOOL isDir = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
        if (!isDir) {
            if (![zipArchive addFileToZip:filePath]) {
                success = NO;
            }
        }
    }
    if (![zipArchive CloseZipFile2]) {
        success = NO;
    }
    return success;
}

+ (BOOL)unzipFolder:(NSString *)path targetPath:(NSString *)targetPath password:(NSString *)password {
    ZipArchive *zipArchive = [ZipArchive new];
    BOOL success = [zipArchive UnzipOpenFile:path Password:password];
    if (![zipArchive UnzipFileTo:targetPath overWrite:YES]) {
        success = NO;
    }
    [zipArchive CloseZipFile2];
    return success;
}

+ (BOOL)backupApplication:(NSString *)name {
    NSString *entityPath = [[Utilities entityFolder] stringByAppendingPathComponent:name];
    NSDateComponents *components = [[Utilities calendar] components:NSCalendarUnitDay fromDate:[NSDate date]];
    NSInteger day = [components day];
    NSString *backupName = [[NSString stringWithFormat:@"%@.%tu", name, day] stringByAppendingPathExtension:kApplicationExtension];
    NSString *backupFilePath = [[Utilities backupFolder] stringByAppendingPathComponent:backupName];
    return [Utilities zipFolder:entityPath targetPath:backupFilePath password:nil];
}

+ (BOOL)restoreApplication:(NSString *)path {
    NSString *name = [[[path lastPathComponent] stringByDeletingPathExtension] stringByDeletingPathExtension];
    NSString *newName = [Utilities createUUID];
    NSString *newEntityPath = [[Utilities entityFolder] stringByAppendingPathComponent:newName];
    BOOL success = [Utilities unzipFolder:path targetPath:newEntityPath password:nil];
    if (![Utilities renameApplicationFile:name to:newName]) {
        success = NO;
    }
    return success;
}

+ (BOOL)exportApplication:(NSString *)name fileName:(NSString *)fileName password:(NSString *)password {
    NSString *entityPath = [[Utilities generatedFolder] stringByAppendingPathComponent:name];
    NSString *exportName = [fileName stringByAppendingPathExtension:kApplicationExtension];
    NSString *exportPath = [[Utilities exportFolder] stringByAppendingPathComponent:exportName];
    BOOL success = [Utilities zipFolder:entityPath targetPath:exportPath password:password];
    [Utilities clearGeneratedFolder];
    return success;
}

+ (BOOL)importApplication:(NSString *)filePath password:(NSString *)password {
    NSString *name = [Utilities createUUID];
    NSString *importPath = [[Utilities generatedFolder] stringByAppendingPathComponent:name];
    BOOL success = [Utilities unzipFolder:filePath targetPath:importPath password:password];
    if (success) {
        // TODO: Find application file, copy to entity folder and rename accordingly...
        /*if (![Utilities renameApplicationFile:name to:name]) {
            success = NO;
        }*/
    }
    [Utilities clearGeneratedFolder];
    return success;
}

+ (BOOL)zipData:(NSData *)data path:(NSString *)path extension:(NSString *)extension {
    // TODO: Needed? No success handling
    NSError *error = nil;
    NSString *filePath = [[Utilities generatedFolder] stringByAppendingPathComponent:path];
    [data writeToFile:filePath options:NSDataWritingFileProtectionComplete error:&error];
    if (!error) {
        NSString *zipFilePath = [filePath stringByAppendingPathExtension:extension];
        ZipArchive *zipArchive = [ZipArchive new];
        [zipArchive CreateZipFile2:zipFilePath];
        [zipArchive addFileToZip:filePath];
        [zipArchive CloseZipFile2];
    }
    [Utilities clearGeneratedFolder];
    return !error;
}

+ (NSData *)unzipData:(NSString *)path extension:(NSString *)extension {
    // TODO: Needed? No success handling
    NSString *filePath = [[Utilities generatedFolder] stringByAppendingPathComponent:path];
    NSString *zipFilePath = [filePath stringByAppendingPathExtension:extension];
    ZipArchive *zipArchive = [ZipArchive new];
    [zipArchive UnzipOpenFile:zipFilePath];
    [zipArchive UnzipFileTo:filePath overWrite:YES];
    [zipArchive CloseZipFile2];
    return [NSData dataWithContentsOfFile:filePath];
}

+ (NSDate *)dayDateForDate:(NSDate *)date {
    NSDateComponents *components = [[Utilities calendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSDate *dayDate = [[Utilities calendar] dateFromComponents:components];
    return dayDate;
}


+ (NSDateFormatter *)timeFormatter {
    static NSDateFormatter *timeFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timeFormatter = [NSDateFormatter new];
        [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
        [timeFormatter setDateStyle:NSDateFormatterNoStyle];
        NSLocale *locale = [NSLocale currentLocale];
        [timeFormatter setLocale:locale];
    });
    return timeFormatter;
}

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateFormatter new];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterFullStyle];
        NSLocale *locale = [NSLocale currentLocale];
        [dateFormatter setLocale:locale];
    });
    return dateFormatter;
}

+ (NSDateFormatter *)dateTimeFormatter {
    static dispatch_once_t onceMark;
    static NSDateFormatter *dateTimeFormatter = nil;
    dispatch_once(&onceMark, ^{
        dateTimeFormatter = [NSDateFormatter new];
        [dateTimeFormatter setDateStyle:NSDateFormatterLongStyle];
        [dateTimeFormatter setTimeStyle:NSDateFormatterShortStyle];
    });
    return dateTimeFormatter;
}

+ (NSDateFormatter *)shortDateTimeFormatter {
    static dispatch_once_t onceMark;
    static NSDateFormatter *shortDateTimeFormatter = nil;
    dispatch_once(&onceMark, ^{
        shortDateTimeFormatter = [NSDateFormatter new];
        [shortDateTimeFormatter setDateStyle:NSDateFormatterShortStyle];
        [shortDateTimeFormatter setTimeStyle:NSDateFormatterShortStyle];
    });
    return shortDateTimeFormatter;
}

+ (NSDateFormatter *)technicalDateFormatter {
    static dispatch_once_t onceMark;
    static NSDateFormatter *technicalDateFormatter = nil;
    dispatch_once(&onceMark, ^{
        technicalDateFormatter = [NSDateFormatter new];
        [technicalDateFormatter setDateFormat:@"yyyy-MM-dd"];
    });
    return technicalDateFormatter;
}

+ (NSDateFormatter *)technicalDateTimeFormatter {
    static dispatch_once_t onceMark;
    static NSDateFormatter *technicalDateTimeFormatter = nil;
    dispatch_once(&onceMark, ^{
        technicalDateTimeFormatter = [NSDateFormatter new];
        [technicalDateTimeFormatter setDateFormat:@"yyyy-MM-dd_HH-mm"];
    });
    return technicalDateTimeFormatter;
}

+ (NSDateFormatter *)relativeDateFormatter {
    static NSDateFormatter *dateFormatterRelative;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatterRelative = [NSDateFormatter new];
        [dateFormatterRelative setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatterRelative setDateStyle:NSDateFormatterFullStyle];
        NSLocale *locale = [NSLocale currentLocale];
        [dateFormatterRelative setLocale:locale];
        dateFormatterRelative.doesRelativeDateFormatting = YES;
    });
    return dateFormatterRelative;
}

+ (NSDateFormatter *)relativeDateTimeFormatter {
    static NSDateFormatter *dateTimeFormatterRelative;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateTimeFormatterRelative = [NSDateFormatter new];
        [dateTimeFormatterRelative setTimeStyle:NSDateFormatterShortStyle];
        [dateTimeFormatterRelative setDateStyle:NSDateFormatterShortStyle];
        NSLocale *locale = [NSLocale currentLocale];
        [dateTimeFormatterRelative setLocale:locale];
        dateTimeFormatterRelative.doesRelativeDateFormatting = YES;
    });
    return dateTimeFormatterRelative;
}

+ (NSDateFormatter *)isoDateFormatter {
    static NSDateFormatter *isoDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isoDateFormatter = [NSDateFormatter new];
        NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        [isoDateFormatter setLocale:enUSPOSIXLocale];
        [isoDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    });
    return isoDateFormatter;
}

+ (NSString *)formatSeconds:(NSInteger)seconds {
    NSUInteger m = (seconds / 60) % 60;
    NSUInteger s = seconds % 60;
    return [NSString stringWithFormat:@"%02tu:%02tu", m, s];
}

+ (NSString *)formatSecondsText:(NSInteger)seconds {
    NSUInteger m = (seconds / 60) % 60;
    NSUInteger s = seconds % 60;
    NSString *formatted = @"";
    if (m > 0) {
        formatted = [formatted stringByAppendingFormat:@"%tu %@", m, NSLocalizedString(@"min", @"")];
    }
    formatted = [formatted stringByAppendingFormat:@"%tu %@", s, NSLocalizedString(@"sec", @"")];
    return formatted;
}

+ (NSString *)formatFileSize:(NSNumber *)fileSize {
    return [NSByteCountFormatter stringFromByteCount:[fileSize longLongValue] countStyle:NSByteCountFormatterCountStyleFile];
}

+ (NSString *)createUUID {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    return uuidString;
}

+ (NSString *)nameInitials:(NSString *)name {
    NSArray *nameParts = [name componentsSeparatedByString:@" "];
    NSMutableArray *parts = [@[] mutableCopy];
    for (NSString *namePart in nameParts) {
        if (![[namePart stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
            [parts addObject:namePart];
        }
    }
    if (parts.count >= 2) {
        NSString *firstInitial = [parts[0] length] > 0 ? [parts[0] substringToIndex:1] : nil;
        NSString *lastInitial = [parts[parts.count-1] length] > 0 ? [parts[parts.count-1] substringToIndex:1] : nil;
        if (firstInitial && lastInitial) {
            return [NSString stringWithFormat:@"%@%@", [firstInitial uppercaseString], [lastInitial uppercaseString]];
        }
    } else if (parts.count == 1) {
        NSString *firstInitial = [parts[0] length] > 0 ? [parts[0] substringToIndex:1] : nil;
        return [firstInitial uppercaseString];
    }
    return nil;
}

+ (NSCalendar *)calendar {
    return [NSCalendar currentCalendar];
}

+ (NSString *)serializeObjectToJSON:(id)object {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
    if (!error) {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonString;
    }
    return nil;
}

+ (id)deserializeJSONToObject:(NSString *)json {
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
}

@end