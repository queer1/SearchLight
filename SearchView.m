/* (c) 2011, Joshua Shomo
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list 
 of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this 
 list of conditions and the following disclaimer in the documentation and/or other 
 materials provided with the distribution.
* Neither the name of the AppleExaminer.com nor the names of its contributors may be 
 used to endorse or promote products derived from this software without specific 
 prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
 SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED 
 TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
 BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
 ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH 
 DAMAGE.
*/

#import "SearchView.h"

@implementation SearchView

@synthesize csv, outFile, shortOutput;

-(id) init {
	if (self = [super init]){
		self.shortOutput = NO;
		self.outFile = @"/dev/stdout";
	}
	return self;
}

/*
Displays help information to stdout.
*/ 
-(void) printHelp {
	printf("Usage: searchlight [-p path] [-o file] [-f format] [-s] query\n"
		   "Queries the Spotlight database for the provided path. Default path is current drive.\n"
		   "-p,--path		A comma-separated list of mounted drives whose Spotlight database are being queried.\n"
		   "-o,--output		Filename or path of file where output should be redirected.\n"
		   "-f,--format		Format of query output.  Currently supported formats: CSV.\n"
		   "-a,--attributes	A comma-separated list of metadata attributes. Returns results in CSV format\n",
		   "-s,--short		Print only the file name in the results, not the entire file path.\n"
		   "-c,--count		Print only the number of results returned by the query.\n"
		   "--version		Current version number.\n"
		   "Default attributes for formatted files: kMDItemPath,kMDItemFSOwnerUserID,\n"
		   "kMDItemFSCreationDate,kMDItemFSContentChangeDate");
	
}

/*
Prints current version number to stdout.
*/
-(void) printVersion {
    ddprintf(@"Searchlight version %i\n", CURRENT_VERSION);
}

/*
 Prints the number of results returned by [model query] to outFile.
*/
-(void) printCount:(NSUInteger)count {
	NSString *countString = [NSString stringWithFormat:@"%lu results returned.\n",count];
	[countString writeToFile:self.outFile
			atomically:NO
			  encoding:NSASCIIStringEncoding
				 error:NULL]; //TODO: add error handler here.
}

/*
 Prints error to stderr if no query is specified on the command line.
 */
-(void) noQuery {
	printf("No query provided!\n");
	[self printHelp];
}

/*
Default output method.  Prints query results to outFile.
*/
-(int) defaultOutput:(NSArray *)results {
	NSError *errorCode = nil;
	NSMetadataItem *item;
	NSMutableString *fileString = [[NSMutableString alloc] init];

	//Iterate through results array
	for (item in results){
		if (shortOutput) {
			//Prints just the file name
			[fileString appendFormat:@"%@\n",[item valueForAttribute:@"kMDItemFSName"]];
		} else {
			//Prints the entire file path
			[fileString appendFormat:@"%@\n",[item valueForAttribute:@"kMDItemPath"]]; 
		}
	}
		//Write to outFile
		BOOL returnCode = [fileString writeToFile:self.outFile 
									   atomically:NO
										 encoding:NSUnicodeStringEncoding
											error:&errorCode];
		if (!returnCode) {
				NSLog(@"Error printing results: %@",errorCode);
			return EXIT_FAILURE;
		} 
	return EXIT_SUCCESS;
}

/*
 CSV output method.  Prints query results to outFile in comma-separated format.
 Default output method if attributes specified.
*/
-(int) csvOutput:(NSArray *)results attributes:(NSArray *)attr {
	NSError *errorCode = nil;
	NSMetadataItem *item;
	NSString *attrVal;
	NSMutableString *fileString = [[NSMutableString alloc] init];
	
	//Create Header with attribute names
	for (attrVal in attr){
		[fileString appendFormat:@"%@,",attrVal];
	}
	
	[fileString appendFormat:@"\n"];	//Append newline
	
	//Append attribute values from the results	 
	for (item in results){
		for (attrVal in attr){
			[fileString appendFormat:@"%@,",[item valueForAttribute:attrVal]];
		}
		[fileString appendFormat:@"\n"];
	}
	BOOL returnCode = [fileString writeToFile:self.outFile 
								   atomically:NO
									 encoding:NSUnicodeStringEncoding
										error:&errorCode];
	if (!returnCode) {
		NSLog(@"Error printing results: %@",errorCode);
		return EXIT_FAILURE;
	} 
	return EXIT_SUCCESS;
}
@end
