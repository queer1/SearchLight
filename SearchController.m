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

#import "SearchController.h"


@implementation SearchController

-(id) init {
	if (self = [super init]) {
		view = [[SearchView alloc] init];
		model = [[SearchModel alloc] init];
	}
	return self;
}

-(void) application: (DDCliApplication *) app
    willParseOptions: (DDGetoptLongParser *) optionsParser {
    [optionsParser setGetoptLongOnly: YES];
    DDGetoptOption optionTable[] = 
    {
        // Long         Short   Argument options
        {@"output",     'o',    DDGetoptRequiredArgument}, //Output file
		{@"path",		'p',	DDGetoptRequiredArgument}, //Search path
		{@"format",		'f',	DDGetoptRequiredArgument}, //Output format
		{@"attributes",	'a',	DDGetoptRequiredArgument}, //Selected attributes
		{@"short",		's',	DDGetoptNoArgument},	   //Short path names
		{@"count",		'c',	DDGetoptNoArgument},	   //Print result count	
        {@"help",       'h',    DDGetoptNoArgument},       //Help
		{@"version",	0,		DDGetoptNoArgument},	   //Software version
        {nil,           0,      0},
    };
    [optionsParser addOptionsFromTable: optionTable];
}
/*
Actual application controller.
Manipulates the model and view objects based upon the specified command line options
*/ 
-(int) application: (DDCliApplication *) app
   runWithArguments: (NSArray *) arguments {
	if (_version){
		[view printVersion];
		return EXIT_SUCCESS;
	}
	if (_help) {
		[view printHelp];
		return EXIT_SUCCESS;
	}
	if ([arguments count] < 1) {
		[view noQuery];
		return EXIT_FAILURE;
	} else {
		[model defPredicate:[arguments objectAtIndex:0]];
	}
	if (_attributes.length > 0){
		[model setAttributes:_attributes];
		view.csv = YES;
	}	
	if (_path.length > 0){
		[model setPath:_path];
	}
	if (_output.length > 0) {
		view.outFile = _output; 
	}
	if (_format.length > 0){	//TODO: create stirng format parser
		view.csv = YES;		//update this when formats other than
	}						//CSV are added.		

	[model runQuery];
	
	if (_count) {		
		[view printCount:[model resultCount]];
	} else if ([view csv]){
		return [view csvOutput:[model queryResults] attributes:[model attributes]];
	} else {
		return [view defaultOutput:[model queryResults]];
	}
	
	return EXIT_SUCCESS;
}
@end
