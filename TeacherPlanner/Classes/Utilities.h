//
//  Utilities.h
//  TeacherPlanner
//
//  Created by Oliver on 29.12.13.
//
//

#import <Foundation/Foundation.h>

#define kApplicationExtension @"tpa"
#define kBrandingExtension    @"tpb"
#define kClassExtension       @"tpc.zip"
#define kPDFExtension         @"pdf"
#define kCSVExtension         @"csv"
#define kXLSExtension         @"xls"
#define kJPGExtension         @"jpg"
#define kZIPExtension         @"zip"

@class JSONEntity;

@interface Utilities : NSObject

+ (BOOL)createFolder:(NSString *)folder;
+ (NSString *)createTempFolder;
+ (BOOL)pathExists:(NSString *)path;
+ (BOOL)deletePath:(NSString *)path;
+ (NSData *)read:(NSString *)path;
+ (NSArray *)readContent:(NSString *)folder;
+ (NSDictionary *)readAttributes:(NSString *)path;

+ (NSURL *)writeGeneratedFile:(NSData *)data path:(NSString *)path;

+ (NSString *)tempFolder;
+ (NSString *)generatedFolder;
+ (NSString *)entityFolder;
+ (NSString *)exportFolder;
+ (NSString *)backupFolder;

+ (BOOL)clearGeneratedFolder;

+ (NSArray *)readEntities;
+ (NSDictionary *)readEntityAttributes:(NSString *)name;
+ (BOOL)createEntityFolder:(NSString *)name;
+ (BOOL)entityExists:(NSString *)name;
+ (BOOL)isEntityFolder:(NSString *)name;

+ (BOOL)writeEntity:(NSString *)name folder:(NSString *)folder entity:(JSONEntity *)entity;
+ (BOOL)exportEntity:(NSString *)name folder:(NSString *)folder entity:(JSONEntity *)entity;
+ (JSONEntity *)readEntity:(NSString *)name folder:(NSString *)folder class:(Class)class;
+ (BOOL)deleteEntityFolder:(NSString *)name;
+ (BOOL)deleteEntity:(NSString *)name folder:(NSString *)folder;

+ (BOOL)zipFolder:(NSString *)folderPath targetPath:(NSString *)targetPath password:(NSString *)password;
+ (BOOL)unzipFolder:(NSString *)path targetPath:(NSString *)targetPath password:(NSString *)password;

+ (BOOL)copyApplication:(NSString *)name;
+ (BOOL)backupApplication:(NSString *)name;
+ (BOOL)restoreApplication:(NSString *)path;
+ (BOOL)exportApplication:(NSString *)name fileName:(NSString *)fileName password:(NSString *)password;
+ (BOOL)importApplication:(NSString *)filePath password:(NSString *)password;

+ (NSDate *)dayDateForDate:(NSDate *)date;

+ (NSDateFormatter *)timeFormatter;
+ (NSDateFormatter *)dateFormatter;
+ (NSDateFormatter *)dateTimeFormatter;
+ (NSDateFormatter *)shortDateTimeFormatter;
+ (NSDateFormatter *)technicalDateFormatter;
+ (NSDateFormatter *)technicalDateTimeFormatter;
+ (NSDateFormatter *)relativeDateFormatter;
+ (NSDateFormatter *)relativeDateTimeFormatter;
+ (NSDateFormatter *)isoDateFormatter;

+ (NSString *)formatSeconds:(NSInteger)seconds;
+ (NSString *)formatSecondsText:(NSInteger)seconds;
+ (NSString *)formatFileSize:(NSNumber *)fileSize;

+ (NSString *)createUUID;
+ (NSString *)nameInitials:(NSString *)name;
+ (NSCalendar *)calendar;

+ (NSString *)serializeObjectToJSON:(id)object;
+ (id)deserializeJSONToObject:(NSString *)json;

@end