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

#import "SearchModel.h"


@implementation SearchModel

@synthesize attributes, predicate, query, queryComplete;

-(id) init {
	if (self = [super init]){
		self.query = [[NSMetadataQuery alloc] init];
		queryComplete = NO;
		attributes = [NSArray arrayWithObjects:@"kMDItemPath",				//Full Path
											   @"kMDItemFSOwnerUserID",		//Unix ID number of owner
											   @"kMDItemFSCreationDate",	//Creation Date
											   @"kMDItemFSContentChangeDate",//Modification Date
											   nil];
		notifyCenter = [NSNotificationCenter defaultCenter];
		[notifyCenter addObserver:self 
						 selector:@selector(queryStatus:) 
							 name:NSMetadataQueryDidFinishGatheringNotification 
						   object:self.query];
	}
	return self;
}
/*
Defines predicate based upon user input
 */ 
-(void) defPredicate:(NSString *)argument {
	self.predicate = [NSPredicate predicateWithFormat:(NSString *)argument]; //TODO: add exception handler here
	
	if (self.predicate == nil) {
		DDCliParseException * e =
		[DDCliParseException parseExceptionWithReason: @"Invalid query syntax\n"
		 "Predicate syntax can be found in Apple's documentation at\n"
		 "http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/Predicates/Articles/pSyntax.html"
											 exitCode: EXIT_FAILURE];
		@throw e;		
	}
	
	[query setPredicate:self.predicate];
}
/*
Executes defined query
*/	
-(void) runQuery {
	[query startQuery]; 
	 CFRunLoopRun();
}
/*
Notification receiver that sets queryComplete and stops run loop.
*/ 
-(void) queryStatus:(NSNotification *)message {
	 queryComplete = YES;
	 CFRunLoopStop(CFRunLoopGetCurrent ());
 }
/*
Parses the user provided search paths and adds them to query
*/ 
-(void) setPath:(NSString *)searchPath {
	paths = [searchPath componentsSeparatedByString:@","];
	[query setSearchScopes:paths];
}
/*
Returns results pointer
*/
-(NSArray *) queryResults {
	return [query results];
}
/*
Returns number of results returned by query
*/
-(NSUInteger) resultCount {
	return [query resultCount];
}
/*
 Parses the user provided attributes
*/ 
-(void) setAttributes:(NSString *)attr {
	attributes = [attr componentsSeparatedByString:@","];
}
@end
