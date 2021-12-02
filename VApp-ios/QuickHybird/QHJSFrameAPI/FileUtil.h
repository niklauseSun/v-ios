//
//  FileUtil.h
//  VApp-ios
//
//  Created by 孙玉建 on 2021/11/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileUtil : NSObject

+ (NSString *)getHomePath;

// 获取tmp路径
+ (NSString *)getTmpPath;

// 获取Documents路径
+ (NSString *)getDocumentsPath;

// 获取Library路径
+ (NSString *)getLibraryPath;

// 获取LibraryCache路径
+ (NSString *)getLibraryCachePath;

// 检查文件、文件夹是否存在
+ (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)isDir;

// 创建路径
+ (void)createDirectory:(NSString *)path;

// 创建文件
+ (NSString *)createFile:(NSString *)filePath fileName:(NSString *)fileName;

// 复制 文件or文件夹
+ (void)copyItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath;

// 移动 文件or文件夹
+ (void)moveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath;

// 删除 文件or文件夹
+ (void)removeItemAtPath:(NSString *)path;

// 获取目录下所有内容
+ (NSArray *)getContentsOfDirectoryAtPath:(NSString *)docPath;

+ (NSString *)getMd5HashOfString:(NSString *)filePath;

+ (NSArray *)splitFileToPart: (NSString *)filePath;

@end

NS_ASSUME_NONNULL_END
