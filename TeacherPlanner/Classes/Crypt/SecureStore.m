//
//  SecureStore.m
//  TeacherPlanner
//
//  Created by Oliver on 30.12.13.
//
//

#import "SecureStore.h"
#import "KeychainItemWrapper.h"
#import "Crypto.h"
#import "NSData+Crypto.h"

#define kSecureStoreName          @"TeacherPlannerSecureStore"
#define kSecureStoreEncryptionKey @"EncryptionKey"
#define kSecureStoreSalt          @"salt"
#define kSecureStoreIv            @"iv"
#define kSecureStoreDigest        @"digest"
#define kSecureStoreData          @"data"

#define kKeychainItemTouchIDIdentifier  @"TouchIDKeychainEntry"
#define kKeychainItemTouchIDServiceName @"de.oklemenz.TeacherPlanner"

@interface SecureStore ()

@property (nonatomic, strong) NSMutableDictionary *data;
@property (nonatomic, strong) NSData *salt;
@property (nonatomic, strong) NSMutableData *key;
@property (nonatomic, strong) NSMutableData *encryptionKey;

@end

@implementation SecureStore

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

+ (SecureStore *)instance {
    static SecureStore *instance = nil;
	@synchronized(self) {
    	if (!instance) {
       		instance = [SecureStore new];
      	}
	}
	return instance;
}

- (BOOL)exists {
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:kSecureStoreName accessGroup:nil];
    NSData *storeData = [keychain objectForKey:(__bridge id)(kSecValueData)];
    if (storeData && storeData.length > 0) {
        return YES;
    }
    return NO;
}

- (BOOL)isOpen {
    return self.data != nil;
}

- (BOOL)create:(NSString *)passcode {
    if ([self exists]) {
        return NO;
    }
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:kSecureStoreName accessGroup:nil];
    [keychain setObject:(__bridge id)(kSecAttrAccessibleWhenUnlocked) forKey:(__bridge id)(kSecAttrAccessible)];
    
    self.data = nil;
    self.key = nil;
    self.encryptionKey = nil;
    
    self.data = [@{} mutableCopy];
    [self setObject:@(0) forKey:kSecureStorePasscodeTimeout];
    self.encryptionKey = [Crypto generateSymmetricalKey];
    [self setObject:self.encryptionKey forKey:kSecureStoreEncryptionKey];

    self.salt = [Crypto generateSalt];
    self.key = [Crypto deriveKeyFromPasscode:passcode withSalt:self.salt];

    return [self synchronize];
}

- (BOOL)open:(NSString *)passcode {
    BOOL open = NO;
    [self close];
    
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:kSecureStoreName accessGroup:nil];
    NSData *storeData = [keychain objectForKey:(__bridge id)(kSecValueData)];
    if (storeData) {
        NSDictionary *store = [NSKeyedUnarchiver unarchiveObjectWithData:storeData];
        if (store) {
            self.salt = store[kSecureStoreSalt];
            NSData *iv = store[kSecureStoreIv];
            NSData *digest = store[kSecureStoreDigest];
            NSMutableData *key = [Crypto deriveKeyFromPasscode:passcode withSalt:self.salt];
            NSData *data = [(NSData *)store[kSecureStoreData] dataDecryptedWithKey:key initializationVector:iv];
            if ([[self dataDigest:data] isEqualToData:digest]) {
                self.data = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                self.key = key;
                self.encryptionKey = [self objectForKey:kSecureStoreEncryptionKey];
                open = YES;
            }
        }
    }
    return open;
}

- (BOOL)validate:(NSString *)passcode {
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:kSecureStoreName accessGroup:nil];
    NSData *storeData = [keychain objectForKey:(__bridge id)(kSecValueData)];
    if (storeData) {
        NSDictionary *store = [NSKeyedUnarchiver unarchiveObjectWithData:storeData];
        if (store) {
            NSData *salt = store[kSecureStoreSalt];
            NSData *iv = store[kSecureStoreIv];
            NSData *digest = store[kSecureStoreDigest];
            NSMutableData *key = [Crypto deriveKeyFromPasscode:passcode withSalt:salt];
            NSData *data = [(NSData *)store[kSecureStoreData] dataDecryptedWithKey:key initializationVector:iv];
            if ([[self dataDigest:data] isEqualToData:digest]) {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)change:(NSString *)passcode {
    if (self.key) {
        KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:kSecureStoreName accessGroup:nil];
        NSData *storeData = [keychain objectForKey:(__bridge id)(kSecValueData)];
        if (storeData) {
            NSDictionary *store = [keychain objectForKey:(__bridge id)(kSecValueData)];
            if (store) {
                self.salt = [Crypto generateSalt];
                self.key = [Crypto deriveKeyFromPasscode:passcode withSalt:self.salt];
                return [self synchronize];
            }
        }
    }
    return NO;
}

- (BOOL)synchronize {
    if (self.key) {
        KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:kSecureStoreName accessGroup:nil];
        NSData *iv = [Crypto generateInitializationVector];
        NSData *dataBinary = [NSKeyedArchiver archivedDataWithRootObject:self.data];
        NSData *digest = [self dataDigest:dataBinary];
        NSData *encryptedData = [(NSData *)dataBinary dataEncryptedWithKey:self.key initializationVector:iv];
        NSDictionary *store = @{ kSecureStoreSalt   : self.salt,
                                 kSecureStoreIv     : iv,
                                 kSecureStoreDigest : digest,
                                 kSecureStoreData   : encryptedData };
        NSData *storeData = [NSKeyedArchiver archivedDataWithRootObject:store];
        [keychain setObject:storeData forKey:(__bridge id)(kSecValueData)];
        return YES;
    }
    return NO;
}

- (void)close {
    self.data = nil;
    self.salt = nil;
    if (self.key) {
        [self.key resetBytesInRange:NSMakeRange(0, self.key.length)];
        self.key = nil;
    }
    if (self.encryptionKey) {
        [self.encryptionKey resetBytesInRange:NSMakeRange(0, self.encryptionKey.length)];
        self.encryptionKey = nil;
    }
}

- (void)reset {
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:kSecureStoreName accessGroup:nil];
    [keychain resetKeychainItem];
    [self close];
}

- (BOOL)storePasscodeForTouchId:(NSString *)passcode {
    NSData *data = [passcode dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary	*attributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        (__bridge id)(kSecClassGenericPassword), kSecClass,
                                        kKeychainItemTouchIDIdentifier, kSecAttrAccount,
                                        kKeychainItemTouchIDServiceName, kSecAttrService, nil];
    CFErrorRef accessControlError = NULL;
    SecAccessControlRef accessControlRef = SecAccessControlCreateWithFlags(
                                                                           kCFAllocatorDefault,
                                                                           kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                                                           kSecAccessControlUserPresence,
                                                                           &accessControlError);
    if (accessControlRef == NULL || accessControlError != NULL) {
        return NO;
    }
    attributes[(__bridge id)kSecAttrAccessControl] = (__bridge id)accessControlRef;
    attributes[(__bridge id)kSecUseNoAuthenticationUI] = @YES;
    attributes[(__bridge id)kSecValueData] = data;
    CFTypeRef result;
    OSStatus osStatus = SecItemAdd((__bridge CFDictionaryRef)attributes, &result);
    if (osStatus != noErr) {
        return NO;
    }
    return YES;
}

- (void)passcodeWithTouchId:(void (^)(NSString *passcode))success error:(void (^)(void))error {
    NSString *secUseOperationPrompt = NSLocalizedString(@"Touch to Unlock", @"");
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSMutableDictionary * query = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       (__bridge id)(kSecClassGenericPassword), kSecClass,
                                       kKeychainItemTouchIDIdentifier, kSecAttrAccount,
                                       kKeychainItemTouchIDServiceName, kSecAttrService,
                                       secUseOperationPrompt, kSecUseOperationPrompt,
                                       nil];
        CFTypeRef result = nil;
        OSStatus userPresenceStatus = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (noErr == userPresenceStatus) {
                NSData *data = (__bridge NSData *)result;
                NSString *passcode = [NSString stringWithUTF8String:[data bytes]];
                success(passcode);
            } else {
                error();
            }
        });
    });
}

- (id)objectForKey:(id)key {
    if (self.data) {
        return [self.data objectForKey:key];
    }
    return nil;
}

- (void)setObject:(id)object forKey:(id)key {
    if (self.data) {
        [self.data setObject:object forKey:key];
    }
}

- (void)removeObjectForKey:(id)key {
    if (self.data) {
        [self.data removeObjectForKey:key];
    }
}

- (NSData *)dataDigest:(NSData *)data {
    return [Crypto calculateDigestFromData:data];
}

- (NSDictionary *)encryptData:(NSData *)data {
    if (self.encryptionKey) {
        NSData *iv = [Crypto generateInitializationVector];
        NSData *encryptedData = [data dataEncryptedWithKey:self.encryptionKey initializationVector:iv];
        return @{ kSecureStoreIv   : iv,
                  kSecureStoreData : encryptedData };
    }
    return nil;
}

- (NSData *)decryptData:(NSData *)data cryptInfo:(NSDictionary *)cryptInfo {
    if (self.encryptionKey) {
        NSData *iv = cryptInfo[kSecureStoreIv];
        NSData *digest = cryptInfo[kSecureStoreDigest];
        NSData *decryptedData = [data dataDecryptedWithKey:self.encryptionKey initializationVector:iv];
        if ([[self dataDigest:decryptedData] isEqualToData:digest]) {
            return decryptedData;
        }
        return nil;
    }
    return nil;
}

- (void)dealloc {
    [self close];
}

@end