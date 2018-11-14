//
//  SecureStore.h
//  TeacherPlanner
//
//  Created by Oliver on 30.12.13.
//
//

#define kSecureStorePasscodeTimeout @"TeacherPlannerSecureStorePasscodeTimeout"

@interface SecureStore : NSObject

+ (SecureStore *)instance;

- (BOOL)exists;
- (BOOL)isOpen;
- (BOOL)create:(NSString *)passcode;
- (BOOL)open:(NSString *)passcode;
- (BOOL)validate:(NSString *)passcode;
- (BOOL)change:(NSString *)passcode;
- (BOOL)synchronize;
- (void)close;
- (void)reset;

- (BOOL)storePasscodeForTouchId:(NSString *)passcode;
- (void)passcodeWithTouchId:(void (^)(NSString * passcode))success error:(void (^)(void))error;

- (id)objectForKey:(id)key;
- (void)setObject:(id)anObject forKey:(id)key;
- (void)removeObjectForKey:(id)key;

- (NSData *)dataDigest:(NSData *)data;
- (NSDictionary *)encryptData:(NSData *)data;
- (NSData *)decryptData:(NSData *)data cryptInfo:(NSDictionary *)cryptInfo;

@end
