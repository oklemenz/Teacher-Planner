//
//  NSData+Crypto.m
//  TeacherPlanner
//
//  Created by Oliver on 30.12.13.
//
//

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonKeyDerivation.h>
#import <Security/Security.h>

@implementation NSData (Crypto)

#define BLOCK_SIZE  kCCBlockSizeAES128
#define DIGEST_SIZE CC_SHA256_DIGEST_LENGTH

- (NSData*)dataEncryptedWithKey:(NSData *)key initializationVector:(NSData *)iv {
    if (key == nil) {
        return nil;
    }
    NSMutableData *encryptedData = [[NSMutableData alloc] initWithLength:self.length + BLOCK_SIZE];
    size_t dataLength = 0;
    CCCryptorStatus success = CCCrypt(kCCEncrypt,
                                      kCCAlgorithmAES128,
                                      kCCOptionPKCS7Padding,
                                      key.bytes, key.length,
                                      iv.bytes,
                                      self.bytes, self.length,
                                      encryptedData.mutableBytes, encryptedData.length,
                                      &dataLength);
    if (success == kCCSuccess) {
        [encryptedData setLength:dataLength];
    } else {
        NSLog(@"Error code: %ld", (long)success);
        encryptedData = nil;
    }
    return encryptedData;
}

- (NSData*)dataDecryptedWithKey:(NSData *)key initializationVector:(NSData *)iv {
    if (key == nil) {
        return nil;
    }
    NSMutableData *decryptedData = [[NSMutableData alloc] initWithLength:self.length + BLOCK_SIZE];
    size_t dataLength = 0;
    CCCryptorStatus success = CCCrypt(kCCDecrypt,
                                      kCCAlgorithmAES128,
                                      kCCOptionPKCS7Padding,
                                      key.bytes, key.length,
                                      iv.bytes,
                                      self.bytes, self.length,
                                      decryptedData.mutableBytes, decryptedData.length,
                                      &dataLength);
    if (success == kCCSuccess) {
        [decryptedData setLength:dataLength];
    } else {
        if (success != kCCDecodeError) {
            NSLog(@"Error code: %ld", (long)success);
        }
        decryptedData = nil;
    }
    return decryptedData;
}

@end