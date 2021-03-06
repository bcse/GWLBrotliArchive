//
//  GWLBrotliArchive.m
//  GWLBrotliArchive
//
//  Created by Grey Lee on 2016/8/9.
//  Copyright © 2016年 Grey Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWLBrotliArchive.h"
#import "decode.h"

static const size_t kFileBufferSize = 65536;
static NSString * const kGWLBrotliArchiveErrorDomain = @"GWLBrotliArchiveError";

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
             progressHandler:(void (^)(NSString *entry, long entryNumber, long total))progressHandler
           completionHandler:(void (^)(NSString *path, BOOL succeeded, NSError * _Nullable error))completionHandler
{
    return [self decompressFileAtPath:path toDestination:destination preserveAttributes:YES overwrite:overwrite password:password error:nil delegate:nil progressHandler:progressHandler completionHandler:completionHandler];
}

+ (BOOL)decompressFileAtPath:(NSString *)path
               toDestination:(NSString *)destination
             progressHandler:(void (^)(NSString *entry, long entryNumber, long total))progressHandler
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
             progressHandler:(void (^)(NSString *entry, long entryNumber, long total))progressHandler
           completionHandler:(void (^)(NSString *path, BOOL succeeded, NSError * _Nullable error))completionHandler
{
    uint8_t *input;
    uint8_t *output;
    size_t total_out;
    size_t available_in = 0;
    const uint8_t *next_in;
    size_t available_out = kFileBufferSize;
    uint8_t *next_out;
    NSError *err = nil;
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    unsigned long long fileSize = [fileAttributes[NSFileSize] unsignedLongLongValue];
    unsigned long long currentPosition = 0;
    
    if (!overwrite && [[NSFileManager defaultManager] fileExistsAtPath:destination]) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"output file exists"};
        err = [NSError errorWithDomain:kGWLBrotliArchiveErrorDomain code:GWLBrotliArchiveErrorOutputFileExists userInfo:userInfo];
        *error = err;
        if (completionHandler) {
            completionHandler(path, NO, err);
        }
        return NO;
    }
    
    BrotliResult result = BROTLI_RESULT_ERROR;
    BrotliState *s = BrotliCreateState(NULL, NULL, NULL);
    if (!s) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"out of memory"};
        err = [NSError errorWithDomain:kGWLBrotliArchiveErrorDomain code:GWLBrotliArchiveErrorOutOfMemory userInfo:userInfo];
        *error = err;
        if (completionHandler) {
            completionHandler(path, NO, err);
        }
        return NO;
    }
    
    input = (uint8_t *)malloc(kFileBufferSize);
    output = (uint8_t *)malloc(kFileBufferSize);
    if (!input || !output) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"out of memory"};
        err = [NSError errorWithDomain:kGWLBrotliArchiveErrorDomain code:GWLBrotliArchiveErrorOutOfMemory userInfo:userInfo];
        *error = err;
        goto cleanup;
    }
    
    // Message delegate
    if ([delegate respondsToSelector:@selector(brotliArchiveWillDecompressArchiveAtPath:)]) {
        [delegate brotliArchiveWillDecompressArchiveAtPath:path];
    }
    if ([delegate respondsToSelector:@selector(brotliArchiveProgressEvent:total:)]) {
        [delegate brotliArchiveProgressEvent:currentPosition total:fileSize];
    }
    
    {
        NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:path];
        NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:destination append:NO];
        
        [inputStream open];
        [outputStream open];
        
        next_out = output;
        result = BROTLI_RESULT_NEEDS_MORE_INPUT;
        while (YES) {
            if (result == BROTLI_RESULT_NEEDS_MORE_INPUT) {
                if (!inputStream.hasBytesAvailable) {
                    break;
                }
                NSInteger read_bytes = [inputStream read:input maxLength:kFileBufferSize];
                next_in = input;
                if (read_bytes < 0) {
                    *error = inputStream.streamError;
                    break;
                }
                available_in = read_bytes;

                currentPosition += read_bytes;
                
                // Message delegate
                if ([delegate respondsToSelector:@selector(brotliArchiveProgressEvent:total:)]) {
                    [delegate brotliArchiveProgressEvent:currentPosition total:fileSize];
                }
            }
            else if (result == BROTLI_RESULT_NEEDS_MORE_OUTPUT) {
                NSInteger write_bytes = [outputStream write:output maxLength:kFileBufferSize];
                if (write_bytes < 0) {
                    *error = outputStream.streamError;
                    break;
                }
                available_out = kFileBufferSize;
                next_out = output;
            }
            else {
                break; /* Error or success. */
            }
            result = BrotliDecompressStream(&available_in, &next_in,
                                            &available_out, &next_out, &total_out, s);
        }
        if (next_out != output) {
            [outputStream write:output maxLength:next_out - output];
        }
        
        [inputStream close];
        [outputStream close];
    
        if ((result == BROTLI_RESULT_NEEDS_MORE_OUTPUT) || outputStream.streamError) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"failed to write output"};
            err = [NSError errorWithDomain:kGWLBrotliArchiveErrorDomain code:GWLBrotliArchiveErrorFailedToWriteOutput userInfo:userInfo];
            *error = err;
        }
        else if (result != BROTLI_RESULT_SUCCESS) { /* Error or needs more input. */
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"corrupt input"};
            err = [NSError errorWithDomain:kGWLBrotliArchiveErrorDomain code:GWLBrotliArchiveErrorCorruptInput userInfo:userInfo];
            *error = err;
        }
        else if (result == BROTLI_RESULT_SUCCESS) {
            // Message delegate
            if ([delegate respondsToSelector:@selector(brotliArchiveDidDecompressArchiveAtPath:decompressedPath:)]) {
                [delegate brotliArchiveDidDecompressArchiveAtPath:path decompressedPath:destination];
            }
            // final progress event = 100%
            if ([delegate respondsToSelector:@selector(brotliArchiveProgressEvent:total:)]) {
                [delegate brotliArchiveProgressEvent:currentPosition total:fileSize];
            }
        }
    }

cleanup:
    if (completionHandler) {
        completionHandler(path, (result == BROTLI_RESULT_SUCCESS), err);
    }

    free(input);
    free(output);
    BrotliDestroyState(s);
    return (result == BROTLI_RESULT_SUCCESS);
}

@end