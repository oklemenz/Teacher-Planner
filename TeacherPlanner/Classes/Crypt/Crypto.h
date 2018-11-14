//
//  Crypto.h
//  TeacherPlanner
//
//  Created by Oliver on 30.12.13.
//
//

#import <CommonCrypto/CommonCryptor.h>

typedef CCCryptorRef CryptoContext;

@interface Crypto : NSObject

+ (NSMutableData *)generateSymmetricalKey;
+ (BOOL)isValidKey:(NSData *)key;
+ (NSData *)generateSalt;
+ (NSMutableData *)generateInitializationVector;
+ (NSMutableData *)deriveKeyFromPasscode:(NSString *)passphrase withSalt:(NSData *)salt;
+ (NSData *)calculateDigestFromData:(NSData *)data;

@end