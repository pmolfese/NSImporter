#import <Foundation/Foundation.h>
#import "EGIFile.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int i;
	int catFlag = 0;
	
	EGIFile *myFile = [[EGIFile alloc] init];
	
	if( argc < 4 )
	{
		NSLog(@"Error: Insufficient Number of Command Arguments");
		NSLog(@"./NSImporter <OutputFile> <inputFile1> <inputFile2> <inputFile3> <flag> <Category1> <Category2>");
		NSLog(@"Flags Supported: \n -c: \t begins definition of categories");
		NSLog(@"Flags Supported: \n -t: \t declares the number of time points");
		exit(0);
	}
	
	for( i=2; i<argc; i++ )
	{
		if( [[NSString stringWithCString:argv[i]] caseInsensitiveCompare:@"-t"] == 0 )
		{
			i++;
			[myFile setSampleTime:[[NSString stringWithCString:argv[i]] intValue]];
		}
		else if( [[NSString stringWithCString:argv[i]] caseInsensitiveCompare:@"-c"] == 0 || catFlag == 1 )
		{
			catFlag = 1;
			i++;
			NSLog(@"Added Category: %@", [NSString stringWithCString:argv[i]]);
			[myFile addCategory:[NSString stringWithCString:argv[i]]];
			if( [[NSString stringWithCString:argv[i]] caseInsensitiveCompare:@"-t"] == 0 )
			{
				i++;
				[myFile setSampleTime:[[NSString stringWithCString:argv[i]] intValue]];
			}
		}
		else if( catFlag == 0 )
		{
			NSLog(@"Added file: %@", [NSString stringWithCString:argv[i]]);
			[myFile addInputFile:[NSString stringWithCString:argv[i]]];
		}
		
	}
	
	NSLog(@"Beginning Conversion...");
	[myFile convertTextToNS];			//parallel-point
	
	NSData *mydata = [NSData dataWithData:[myFile allData]];
	NSString *myPath = [NSString stringWithString:[NSString stringWithCString:argv[1]]];	//first thing in series of commands
								 
	[mydata writeToFile:[NSString stringWithCString:argv[1]] atomically:YES];
	
	NSFileManager *myManager = [NSFileManager defaultManager];
	NSNumber *HFS_Creator = [NSNumber numberWithUnsignedLong:'NETs'];
	NSNumber *HFS_Type_Code = [NSNumber numberWithUnsignedLong:'eGLY'];
	NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:HFS_Creator, NSFileHFSCreatorCode, HFS_Type_Code, NSFileHFSTypeCode, nil];
	[myManager setAttributes:attr ofItemAtPath:myPath error:NULL];
	
	//changeFileAttributes:atPath
	
    [pool drain];
    return 0;
}
