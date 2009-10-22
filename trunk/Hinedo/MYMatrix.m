//
//  MYMatrix.m
//  Hinedo
//
//  Created by Gung Shi Jie on 2009/10/20.
//  Copyright 2009 中正大學. All rights reserved.
//

#import "MYMatrix.h"


@implementation MYMatrix
- (NSButtonCell*) makeRadioButton:(NSString *)name{
	if (!name) {
		NSButtonCell * btn=[[[NSButtonCell alloc] autorelease] initTextCell:@""];
		[btn setButtonType:NSRadioButton];
		[btn setEnabled:NO];
		return [btn retain];
	}
	NSLog(@"Make Cell for %@\n",name);
	NSButtonCell * btn=[[[NSButtonCell alloc] autorelease] initTextCell:name];
	[btn autorelease];
	[btn setButtonType:NSRadioButton];
	[btn retain];
	[btn setTarget:self];
	[btn setAction:@selector(click:)];
	return btn;
}

- (void) click:(id)sender{
	[player playChannel:[(NSButtonCell *)[(NSMatrix *)sender selectedCell] title]];
	NSLog(@"%@\n",[(NSButtonCell *)[(NSMatrix *)sender selectedCell] title]);
}

- (void) setPlayer:(id)p{
	player=p;
}

- (id)init{
	[super init];
	mdata=[[[[NSMutableArray alloc] autorelease] retain] init];
	return self;
}

- (void) addItem:(NSString *)name{
	[mdata addObject:name];
}
- (void) doLayout{
	//[self removeRow:0];
/*	[self removeColumn:0];*/
	[self addColumn];
	[self addColumn];
	[self setMode:NSRadioModeMatrix];
	[self setAutosizesCells:YES];
	[self setAllowsEmptySelection:YES];
	NSLog(@"%d\n",[mdata count]);
	int i=0;
	for(i=0;i<[mdata count]/2;i++){
		NSButtonCell * b0=[self makeRadioButton:[mdata objectAtIndex:2*i]];
		NSButtonCell * b1=[self makeRadioButton:[mdata objectAtIndex:2*i+1]];
		[self addRowWithCells:[NSArray arrayWithObjects:b0,b1,nil]];
	}
	
	if ([mdata count]%2==1) {
		NSButtonCell * b0=[self makeRadioButton:[mdata objectAtIndex:[mdata count]-1]];
		NSButtonCell * b1=[self makeRadioButton:nil];
		[self addRowWithCells:[NSArray arrayWithObjects:b0,b1,nil]];

	}
	
	[self removeRow:0];
}
@end
