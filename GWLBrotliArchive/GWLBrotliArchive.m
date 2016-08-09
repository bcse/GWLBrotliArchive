//
//  GWLBrotliArchive.m
//  GWLBrotliArchive
//
//  Created by Grey Lee on 2016/8/9.
//  Copyright © 2016年 Grey Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWLBrotliArchive.h"

@implementation GWLBrotliArchive

+ (BOOL)isFilePasswordProtectedAtPath:(NSString *)path
{
    return NO;
}

+ (BOOL)decompressFileAtPath:(NSString *)path toDestination:(NSString *)destination
{
    return [self decompressFileAtPath:path toDestination:destination delegate:nil];
}

+ (BOOL)decompressFileAtPath:(NSString *)path toDestination:(NSString *)destination overwrite:(BOOL)overwrite password:(nullable NSString *)password error:(NSError * _Nullable *)error
{
    return [self decompressFileAtPath:path toDestination:destination preserveAttributes:YES overwrite:overwrite password:password error:error delegate:nil progressHandler:nil completionHandler:nil];
}

+ (BOOL)decompressFileAtPath:(NSString *)path toDestination:(NSString *)destination delegate:(nullable id<GWLBrotliArchiveDelegate>)delegate
{
    return [self decompressFileAtPath:path toDestination:destination preserveAttributes:YES overwrite:YES password:nil error:nil delegate:delegate progressHandler:nil completionHandler:nil];
}

+ (BOOL)decompressFileAtPath:(NSString *)path toDestination:(NSString *)destination overwrite:(BOOL)overwrite password:(nullable NSString *)password error:(NSError * _Nullable *)error delegate:(nullable id<GWLBrotliArchiveDelegate>)delegate
{
    return [self decompressFileAtPath:path toDestination:destination preserveAttributes:YES overwrite:overwrite password:password error:error delegate:delegate progressHandler:nil completionHandler:nil];
}

+ (BOOL)decompressFileAtPath:(NSString *)path
               toDestination:(NSString *)destination
                   overwrite:(BOOL)overwrite
                    password:(NSString *)password
             progressHandler:(void (^)(NSString *entry, brotli_file_info fileInfo, long entryNumber, long total))progressHandler
           completionHandler:(void (^)(NSString *path, BOOL succeeded, NSError * _Nullable error))completionHandler
{
    return [self decompressFileAtPath:path toDestination:destination preserveAttributes:YES overwrite:overwrite password:password error:nil delegate:nil progressHandler:progressHandler completionHandler:completionHandler];
}

+ (BOOL)decompressFileAtPath:(NSString *)path
               toDestination:(NSString *)destination
             progressHandler:(void (^)(NSString *entry, brotli_file_info fileInfo, long entryNumber, long total))progressHandler
           completionHandler:(void (^)(NSString *path, BOOL succeeded, NSError * _Nullable error))completionHandler
{
    return [self decompressFileAtPath:path toDestination:destination preserveAttributes:YES overwrite:YES password:nil error:nil delegate:nil progressHandler:progressHandler completionHandler:completionHandler];
}

+ (BOOL)decompressFileAtPath:(NSString *)path
               toDestination:(NSString *)destination
          preserveAttributes:(BOOL)preserveAttributes
                   overwrite:(BOOL)overwrite
                    password:(nullable NSString *)password
                       error:(NSError * _Nullable *)error
                    delegate:(nullable id<GWLBrotliArchiveDelegate>)delegate
{
    return [self decompressFileAtPath:path toDestination:destination preserveAttributes:preserveAttributes overwrite:overwrite password:password error:error delegate:delegate progressHandler:nil completionHandler:nil];
}

+ (BOOL)decompressFileAtPath:(NSString *)path
               toDestination:(NSString *)destination
          preserveAttributes:(BOOL)preserveAttributes
                   overwrite:(BOOL)overwrite
                    password:(NSString *)password
                       error:(NSError * _Nullable *)error
                    delegate:(id<GWLBrotliArchiveDelegate>)delegate
             progressHandler:(void (^)(NSString *entry, brotli_file_info fileInfo, long entryNumber, long total))progressHandler
           completionHandler:(void (^)(NSString *path, BOOL succeeded, NSError * _Nullable error))completionHandler
{
    return YES;
}

@end