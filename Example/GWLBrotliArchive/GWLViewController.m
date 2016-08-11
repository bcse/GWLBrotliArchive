//
//  GWLViewController.m
//  GWLBrotliArchive
//
//  Created by Grey Lee on 08/11/2016.
//  Copyright (c) 2016 Grey Lee. All rights reserved.
//

#import "GWLViewController.h"
#import <GWLBrotliArchive/GWLBrotliArchive.h>

@interface GWLViewController () <GWLBrotliArchiveDelegate>

@end

@implementation GWLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *testdataRoot = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"testdata"];
    NSDirectoryEnumerator<NSString *> *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:testdataRoot];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"self ENDSWITH '.compressed'"];
    NSArray<NSString *> *compressedFiles = [enumerator.allObjects filteredArrayUsingPredicate:filter];
    
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"output"];
    
    for (NSString *fileName in compressedFiles) {
        NSString *filePath = [testdataRoot stringByAppendingPathComponent:fileName];
        NSString *originalFilePath = [filePath substringToIndex:filePath.length - 11];
        if (![[NSFileManager defaultManager] fileExistsAtPath:originalFilePath]) {
            continue;
        }
        NSError *err = nil;
        
        //BOOL success = [GWLBrotliArchive decompressFileAtPath:filePath toDestination:outputPath preserveAttributes:YES overwrite:YES password:nil error:&err delegate:self];
        BOOL success = [GWLBrotliArchive decompressFileAtPath:filePath toDestination:outputPath overwrite:YES password:nil progressHandler:^(NSString * _Nonnull entry, long entryNumber, long total) {
            
        } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
            NSLog(@"completionHandler %@ %@ %@", path, @(succeeded), error);
        }];
        
        if (success) {
            NSData *data1 = [NSData dataWithContentsOfFile:originalFilePath];
            NSData *data2 = [NSData dataWithContentsOfFile:outputPath];
            BOOL result = [data1 isEqualToData:data2];
            NSLog(@"Decompress %@ ... %@", fileName, result ? @"OK" : @"FAIL");
        }
        else {
            NSLog(@"Decompress failed! %@", fileName);
            NSLog(@"%@", err);
        }
    }
}

#pragma mark GWLBrotliArchiveDelegate

- (void)brotliArchiveWillDecompressArchiveAtPath:(NSString *)path
{
    NSLog(@"brotliArchiveWillDecompressArchiveAtPath: %@", path);
}

- (void)brotliArchiveDidDecompressArchiveAtPath:(NSString *)path decompressedPath:(NSString *)decompressedPath
{
    NSLog(@"brotliArchiveDidDecompressArchiveAtPath: %@ decompressedPath: %@", path, decompressedPath);
}

- (void)brotliArchiveProgressEvent:(unsigned long long)loaded total:(unsigned long long)total
{
    NSLog(@"brotliArchiveProgressEvent:%llu total:%llu (%.02f%%)", loaded, total, (float)loaded/total * 100);
}

@end
