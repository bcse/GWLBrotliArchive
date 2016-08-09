//
//  GWLBrotliArchive.h
//  GWLBrotliArchive
//
//  Created by Grey Lee on 2016/8/9.
//  Copyright © 2016年 Grey Lee. All rights reserved.
//

#ifndef _GWLBROTLIARCHIVE_H
#define _GWLBROTLIARCHIVE_H

#import <UIKit/UIKit.h>

//! Project version number for GWLBrotliArchive.
FOUNDATION_EXPORT double GWLBrotliArchiveVersionNumber;

//! Project version string for GWLBrotliArchive.
FOUNDATION_EXPORT const unsigned char GWLBrotliArchiveVersionString[];

NS_ASSUME_NONNULL_BEGIN

struct brotli_file_info {
    
};
typedef struct brotli_file_info brotli_file_info;

@protocol GWLBrotliArchiveDelegate;

@interface GWLBrotliArchive : NSObject

// Password check
+ (BOOL)isFilePasswordProtectedAtPath:(NSString *)path;

// Decompress
+ (BOOL)decompressFileAtPath:(NSString *)path toDestination:(NSString *)destination;
+ (BOOL)decompressFileAtPath:(NSString *)path toDestination:(NSString *)destination delegate:(nullable id<GWLBrotliArchiveDelegate>)delegate;

+ (BOOL)decompressFileAtPath:(NSString *)path toDestination:(NSString *)destination overwrite:(BOOL)overwrite password:(nullable NSString *)password error:(NSError * _Nullable *)error;
+ (BOOL)decompressFileAtPath:(NSString *)path toDestination:(NSString *)destination overwrite:(BOOL)overwrite password:(nullable NSString *)password error:(NSError * _Nullable *)error delegate:(nullable id<GWLBrotliArchiveDelegate>)delegate NS_REFINED_FOR_SWIFT;

+ (BOOL)decompressFileAtPath:(NSString *)path
               toDestination:(NSString *)destination
          preserveAttributes:(BOOL)preserveAttributes
                   overwrite:(BOOL)overwrite
                    password:(nullable NSString *)password
                       error:(NSError * _Nullable *)error
                    delegate:(nullable id<GWLBrotliArchiveDelegate>)delegate;

+ (BOOL)decompressFileAtPath:(NSString *)path
               toDestination:(NSString *)destination
             progressHandler:(void (^)(NSString *entry, brotli_file_info fileInfo, long entryNumber, long total))progressHandler
           completionHandler:(void (^)(NSString *path, BOOL succeeded, NSError * _Nullable error))completionHandler;

+ (BOOL)decompressFileAtPath:(NSString *)path
               toDestination:(NSString *)destination
                   overwrite:(BOOL)overwrite
                    password:(nullable NSString *)password
             progressHandler:(void (^)(NSString *entry, brotli_file_info fileInfo, long entryNumber, long total))progressHandler
           completionHandler:(void (^)(NSString *path, BOOL succeeded, NSError * _Nullable error))completionHandler;

@end

@protocol GWLBrotliArchiveDelegate <NSObject>

@optional

- (void)brotliArchiveWillDecompressArchiveAtPath:(NSString *)path fileInfo:(brotli_file_info)fileInfo;
- (void)brotliArchiveDidDecompressArchiveAtPath:(NSString *)path fileInfo:(brotli_file_info)fileInfo decompressedPath:(NSString *)decompressedPath;

- (BOOL)brotliArchiveShouldDecompressFileAtIndex:(NSInteger)fileIndex totalFiles:(NSInteger)totalFiles archivePath:(NSString *)archivePath fileInfo:(brotli_file_info)fileInfo;
- (void)brotliArchiveWillDecompressFileAtIndex:(NSInteger)fileIndex totalFiles:(NSInteger)totalFiles archivePath:(NSString *)archivePath fileInfo:(brotli_file_info)fileInfo;
- (void)brotliArchiveDidDecompressFileAtIndex:(NSInteger)fileIndex totalFiles:(NSInteger)totalFiles archivePath:(NSString *)archivePath fileInfo:(brotli_file_info)fileInfo;
- (void)brotliArchiveDidDecompressFileAtIndex:(NSInteger)fileIndex totalFiles:(NSInteger)totalFiles archivePath:(NSString *)archivePath decompressedFilePath:(NSString *)decompressedFilePath;

- (void)brotliArchiveProgressEvent:(unsigned long long)loaded total:(unsigned long long)total;
- (void)brotliArchiveDidDecompressArchiveFile:(NSString *)brotliFile entryPath:(NSString *)entryPath destPath:(NSString *)destPath;

@end

NS_ASSUME_NONNULL_END

#endif