//
//  ViewController.m
//  GWLBrotliArchiveDemo
//
//  Created by Grey Lee on 2016/8/10.
//  Copyright © 2016年 Grey Lee. All rights reserved.
//

#import "ViewController.h"
#import <GWLBrotliArchive/GWLBrotliArchive.h>

@interface ViewController () <GWLBrotliArchiveDelegate>

@end

@implementation ViewController

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
        if ([GWLBrotliArchive decompressFileAtPath:filePath toDestination:outputPath preserveAttributes:YES overwrite:YES password:nil error:&err delegate:self]) {
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

@end
