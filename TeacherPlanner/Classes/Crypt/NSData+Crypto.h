//
//  NSData+Crypto.h
//  TeacherPlanner
//
//  Created by Oliver on 30.12.13.
//
//

@interface NSData (Crypto)

- (NSData *)dataEncryptedWithKey:(NSData *)key initializationVector:(NSData *)iv;
- (NSData *)dataDecryptedWithKey:(NSData *)key initializationVector:(NSData *)iv;

@end