//
//  EGIFile.h
//  NSImporter
//
//  Created by Peter Molfese on 9/4/08.
//  Copyright 2008 Peter Molfese. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface EGIFile : NSObject 
{
	NSString *path;
	NSArray *inputFiles;
	NSData *allData;
	NSArray *categories;
	NSUInteger totalSize;
	NSUInteger samplingRate;
	NSUInteger numChannels;
	NSUInteger sampleTime;
}
@property(readwrite,copy) NSString *path;
@property(readwrite,copy) NSArray *inputFiles;
@property(readwrite,copy) NSArray *categories;
@property(readwrite,copy) NSData *allData;
@property(readwrite) NSUInteger totalSize;
@property(readwrite) NSUInteger samplingRate;
@property(readwrite) NSUInteger numChannels;
@property(readwrite) NSUInteger sampleTime;
-(id)init;
-(id)initWithInputFiles:(NSArray *)arrayOfInputFiles;
-(void)addInputFile:(NSString *)newInputFile;
-(void)addCategory:(NSString *)newCategoryName;
-(void)convertTextToNS;

@end
