//
//  Crypto.m
//  TeacherPlanner
//
//  Created by Oliver on 30.12.13.
//
//

#import "Crypto.h"
#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonKeyDerivation.h>

const size_t kKeySize    = kCCKeySizeAES256;
const size_t kIVSize     = kCCBlockSizeAES128;

const size_t kDigestSize = CC_SHA256_DIGEST_LENGTH;
const size_t kSaltSize   = CC_SHA256_DIGEST_LENGTH;

@implementation Crypto

+ (NSMutableData *)generateSymmetricalKey {
    uint8_t bytes[kKeySize];
    if (SecRandomCopyBytes(kSecRandomDefault, kKeySize, bytes) == 0) {
        return [[NSMutableData alloc] initWithBytes:bytes length:kKeySize];
    }
    return nil;
}

+ (BOOL)isValidKey:(NSData *)key {
    NSData *invalidKey = [[NSMutableData alloc] initWithBytes:key.bytes length:kKeySize];
    return (key != nil && ![key isEqualToData:invalidKey]);
}

+ (NSData *)generateSalt {
    uint8_t bytes[kSaltSize];
    if (SecRandomCopyBytes(kSecRandomDefault, kSaltSize, bytes) == 0) {
        return [[NSData alloc] initWithBytes:bytes length:kSaltSize];
    }
    return nil;
}

+ (NSMutableData *)generateInitializationVector {
    uint8_t bytes[kIVSize];
    if (SecRandomCopyBytes(kSecRandomDefault, kIVSize, bytes) == 0) {
       return [[NSMutableData alloc] initWithBytes:bytes length:kIVSize];
    }
    return nil;
}

+ (NSMutableData *)deriveKeyFromPasscode:(NSString *)passcode withSalt:(NSData *)salt {
    NSData *passcodeData = [passcode dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t bytes[kKeySize];
    if (CCKeyDerivationPBKDF(kCCPBKDF2,
                             passcodeData.bytes, passcodeData.length,
                             salt.bytes, salt.length,
                             kCCPRFHmacAlgSHA256,
                             10000,
                             bytes, kKeySize) == kCCSuccess) {
        return [[NSMutableData alloc] initWithBytes:bytes length:kKeySize];
    }
    return nil;
}

+ (NSData *)calculateDigestFromData:(NSData*)data {
    if (data == nil) {
        return nil;
    }
    uint8_t bytes[kDigestSize];
    NSData *digest = nil;
    uint8_t *result = CC_SHA256(data.bytes, (CC_LONG)data.length, bytes);
    if (result != nil) {
        digest = [[NSData alloc] initWithBytes:result length:kDigestSize];
    }
    return digest;
}

@end