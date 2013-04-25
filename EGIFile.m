//
//  EGIFile.m
//  NSImporter
//
//  Created by Peter Molfese on 9/4/08.
//  Copyright 2008 Peter Molfese. All rights reserved.
//

#import "EGIFile.h"


@implementation EGIFile

@synthesize path;
@synthesize inputFiles;
@synthesize allData;
@synthesize totalSize;
@synthesize categories;
@synthesize samplingRate;
@synthesize numChannels;
@synthesize sampleTime;

-(id)init
{
	self = [super init];
	if( self == nil )
		return nil;
	self.path = nil;
	self.inputFiles = nil;
	self.allData = nil;
	self.totalSize = 0;
	self.samplingRate = 250;
	self.categories = nil;
	self.numChannels = 129;
	self.sampleTime = 250;
	return self;
}

-(id)initWithInputFiles:(NSArray *)arrayOfInputFiles
{
	[super init];
	self.path = nil;
	self.inputFiles = [NSArray arrayWithArray:arrayOfInputFiles];
	self.allData = nil;
	totalSize = [[self inputFiles] count];
	self.samplingRate = 250;
	return self;
}

-(void)addInputFile:(NSString *)newInputFile
{
	if( totalSize == 0 || [self inputFiles] == nil )
	{
		//NSLog(@"Setting new array");
		NSMutableArray *newData = [NSMutableArray arrayWithObject:newInputFile];
		self.inputFiles = newData;
		self.totalSize++;
	}
	else
	{
		//NSLog(@"Adding to existing");
		NSMutableArray *newData = [NSMutableArray arrayWithCapacity:0];
		for( NSString *aStr in [self inputFiles] )
		{
			[newData addObject:aStr];
		}
		[newData addObject:newInputFile];
		self.inputFiles = newData;
		self.totalSize++;
	}
	//NSLog(@"Total Size = %i", self.totalSize);
}

-(void)convertTextToNS
{
	int i;
	NSCalendarDate *theDate = [NSCalendarDate calendarDate]; //gets current info
	long version = 5;
	short year = [[NSNumber numberWithInt:[theDate yearOfCommonEra]] shortValue];
	short month = [[NSNumber numberWithInt:[theDate monthOfYear]] shortValue];
	short day = [[NSNumber numberWithInt:[theDate dayOfMonth]] shortValue];
	short hour = [[NSNumber numberWithInt:[theDate hourOfDay]] shortValue];
	short minute = [[NSNumber numberWithInt:[theDate minuteOfHour]] shortValue];
	short second = [[NSNumber numberWithInt:[theDate secondOfMinute]] shortValue];
	long millisecond = 0;
	
	short SR = (short)self.samplingRate;
	short numberOfChannels = (short)self.numChannels;
	short boardgain = 1;
	short conversionBits = 0;
	short rangeOfAmp = 0;
	short numCategories = (short)(self.totalSize);	//already flipped

	
	short numberOfSegments = numCategories;
	long samplesPerSeg = (long)self.sampleTime;
	short numEventCodes = 0;
	
	//write header info to Data object -- appendBytes:length:
	NSArray *theFiles = [NSArray arrayWithArray:inputFiles];
	NSMutableData *aDataSet = [[NSMutableData alloc] initWithCapacity:0];
	
	[aDataSet appendBytes:&version length:4];
	[aDataSet appendBytes:&year length:2];
	[aDataSet appendBytes:&month length:2];
	[aDataSet appendBytes:&day length:2];
	[aDataSet appendBytes:&hour length:2];
	[aDataSet appendBytes:&minute length:2];
	[aDataSet appendBytes:&second length:2];
	[aDataSet appendBytes:&millisecond length:4];
	[aDataSet appendBytes:&SR length:2];
	[aDataSet appendBytes:&numberOfChannels length:2];
	[aDataSet appendBytes:&boardgain length:2];
	[aDataSet appendBytes:&conversionBits length:2];
	[aDataSet appendBytes:&rangeOfAmp length:2];
	[aDataSet appendBytes:&numCategories length:2];
	//NSLog(@"Data length at before categories: %i", [aDataSet length]);
	
	//add category names = const char *make = "car+";
	//time to create the p-arrays, 1 char that lists length
	for( i=0; i<self.totalSize; i++ )
	{
		const char *name = [[[self categories] objectAtIndex:i] cStringUsingEncoding:1];
		char psize = (char)[[[self categories] objectAtIndex:i] length];
		[aDataSet appendBytes:&psize length:1];
		[aDataSet appendBytes:name length:psize];
	}
	
	[aDataSet appendBytes:&numberOfSegments length:2];
	[aDataSet appendBytes:&samplesPerSeg length:4];
	NSLog(@"Samples Per Seg: %i", samplesPerSeg);
	[aDataSet appendBytes:&numEventCodes length:2];
	//NSLog(@"Num Event Codes: %i", numEventCodes);
	//const char *myevent = [[NSString stringWithString:@"eve+"] cString];
	//const char *myevent = "eve+";
	//[aDataSet appendBytes:&myevent length:sizeof(char)*4];
	//NSLog(@"Event Name: %@ Size: %i", [NSString stringWithCString:myevent length:4], sizeof(char)*4);
	
	
	//begin EEG writing
	
	
	float t_data;
	//float t_data2;
	i=0;
	short index;
	long timestamp;
	
	for( NSString *aFile in theFiles )
	{
		NSString *fileAsString = [NSString stringWithContentsOfFile:aFile];
		NSScanner *myScanner = [NSScanner scannerWithString:fileAsString];
		[myScanner setCharactersToBeSkipped:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		index = i+1;
		timestamp = i*1000;
		i++;
		
		[aDataSet appendBytes:&index length:2];
		[aDataSet appendBytes:&timestamp length:4];
		
		while( [myScanner isAtEnd] == FALSE )
		{
			[myScanner scanFloat:&t_data];
			[aDataSet appendBytes:&t_data length:4];
		}
	}
	
	self.allData = [NSData dataWithData:aDataSet];
	
}

-(void)addCategory:(NSString *)newCategoryName
{
	//NSLog(@"Attempting add in class");
	if( self.categories == nil )
	{
		NSMutableArray *cats = [NSMutableArray arrayWithCapacity:0];
		[cats addObject:newCategoryName];
		[self setCategories:cats];
	}
	else
	{
		//NSLog(@"The else");
		//[[self categories] addObject:newCategoryName]; 
		NSMutableArray *cat = [NSMutableArray arrayWithArray:[self categories]];
		[cat addObject:newCategoryName];
		[self setCategories:cat];
	}
}


@end
