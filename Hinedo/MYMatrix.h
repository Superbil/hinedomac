//
//  MYMatrix.h
//  Hinedo
//
//  Created by Gung Shi Jie on 2009/10/20.
//  Copyright 2009 中正大學. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MYMatrix : NSMatrix {
	NSMutableArray * mdata;
	id	player;
}
- (NSButtonCell*) makeRadioButton:(NSString *)name;
- (void) addItem:(NSString *)name;
- (void) doLayout;
- (void) click:(id)sender;
- (void) setPlayer:(id)p;
@end
