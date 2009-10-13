#import "MYClassY.h"
#import <QTKit/QTMovie.h>
#import <Quartz/Quartz.h>


@implementation MYClassY
- (void)windowDidBecomeKey:(NSNotification *)notification{
	return;
	CGContextRef cgc = BeginCGContextForApplicationDockTile();
	CGRect cgr=CGContextGetPathBoundingBox(cgc);
	NSLog(@"%f %f\n",cgr.origin.x,cgr.origin.y);
	
	/*
	NSRect rect=[window frame];
	NSPoint  mouseLoc=[NSEvent mouseLocation];
	rect.origin.x=mouseLoc.x-rect.size.width/2;
	rect.origin.y=mouseLoc.y+50;
	[window setFrame:rect display:YES];*/
}

- (IBAction)stationChanged:(id)sender{
	NSLog(@"%@\n",[[menuOutlet selectedItem] title]);
	[self playClicked:button];
}

- (IBAction)volumeChanged:(id)sender{
	NSLog(@"volume %f\n",[sender floatValue]);
	[movie setVolume:[sender floatValue]/[sender maxValue]];
	int i=(int)(floor([sender floatValue]/25.0));
	NSImage * image=[[NSImage alloc] autorelease];
	[image initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"volume%d",i] ofType:@"png"]];
	[img setImage:image];
}

- (IBAction)playClicked:(id)sender{
	[button setEnabled:NO];
	if(movie!=nil){
		[[NSNotificationCenter defaultCenter] removeObserver:self];
		[movie stop];
		[movie dealloc];
		movie=nil;
		[button setTitle:@"Play"];
		[button setEnabled:YES];
		return;
	}
	NSMutableString * base = [NSMutableString stringWithCapacity:0];
	[base appendString:@"http://hichannel.hinet.net/player/radio/index.jsp?radio_id="];
	NSString * title=[[menuOutlet selectedItem] title];
	NSArray * a=[title componentsSeparatedByString:@"\t"];
	title=[a objectAtIndex:[a count]-1];
	[base appendString:title];
	
	NSError * err=nil;
	NSLog(@"%d\n",err);
	NSString * web = [NSString stringWithContentsOfURL:[NSURL URLWithString:base] encoding:NSUTF8StringEncoding error:&err];
	if(web==nil){
		NSLog(@"No internet connection\n");
		[button setEnabled:YES];
		return;
	}
	
	NSString * regexString = [NSString stringWithString:@"(mms://.*?)(&|\")"];
	NSArray *capturesArray = nil;
	capturesArray = [web arrayOfCaptureComponentsMatchedByRegex:regexString]; 
	
	NSMutableString * movieString=[NSMutableString stringWithCapacity:0];
	[movieString appendString:[[capturesArray objectAtIndex:0] objectAtIndex:1]];
	if([movieString rangeOfString:@"http://"].location<0){
		[button setEnabled:YES];
		NSLog(@"Address not found\n");
		return;
	}
	[movieString replaceOccurrencesOfString:@"mms://" withString:@"http://" options:NSCaseInsensitiveSearch range:NSMakeRange(0,[movieString length])];
	NSLog(@"%@\n",movieString);
	movie=[[QTMovie alloc] initWithURL:[NSURL URLWithString:movieString] error:&err];
	if(err){
		NSLog(@"Error init movie\n");
		NSLog(@"%@\n",[err localizedDescription]);
		[button setEnabled:YES];
		return;
	}
	[textField setStringValue:movieString];
	//NSLog(@"volume %f/%f\n",[volumeBar floatValue]/[volumeBar maxValue]);
	//[movie setVolume:[volumeBar floatValue]/[volumeBar maxValue]];
	[movie setVolume:0.2];
	[movie setRate:1.0];
	[movie autoplay];

	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(QTMovieRateDidChangeNotificationFunuc:)
												 name: QTMovieRateDidChangeNotification
											   object: movie];
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(QTMovieLoadStateDidChangeNotificationFunc:)
												 name: QTMovieLoadStateDidChangeNotification
											   object: movie];
	/*[[NSNotificationCenter defaultCenter] addObserver: self
	 selector: @selector(QTMovieDidEndNotificationFunc:)
	 name: QTMovieDidEndNotification
	 object: movie];*/
	
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(MyMovieShouldStopFunc:)
												 name: @"MyMovieShouldStop"
											   object: nil];
	
	NSLog(@"movie rate %d\n",[movie rate]);
	NSLog(@"volume %f\n",[movie volume]);
}

- (void)setupMenu{
	[menuOutlet removeAllItems];
	NSRect f;
	
	NSFileHandle * fmenu = [NSFileHandle fileHandleForReadingAtPath:[[NSBundle mainBundle] pathForResource:@"menu" ofType:@""]];
	//[img setImage: [[[NSImage alloc] autorelease] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"volume_high" ofType:@"png"]]];
	NSString * line=nil;
	NSData* aData=nil;
	aData=[fmenu readDataToEndOfFile];
	line=[[[NSString alloc] autorelease]initWithData:aData encoding:NSUTF8StringEncoding];
	
	//NSArray *chunks = [line componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]];
	NSArray *chunks = [line componentsSeparatedByString:@"\n"];

	//printf("%d chunks\n",[chunks count]);
	
	int  cat=1;
	for(int i=0;i<[chunks count];i++){
		NSString * item=[chunks objectAtIndex:i];
		if([item length]>0){
			char c = [item characterAtIndex:[item length]-1];
			if(c<'0' || c>'9'){
				//if([(NSString *)[chunks objectAtIndex:i] length] <4){
				NSMutableString * cat = [NSMutableString stringWithString:@""];
				[cat appendString:@"=="];
				[cat appendString:(NSString *)[chunks objectAtIndex:i]];
				[cat appendString:@"=="];
				[menuOutlet addItemWithTitle: cat];
				
				NSTabViewItem * tvitem = [[[NSTabViewItem alloc] autorelease] initWithIdentifier:nil];
				[tvitem setLabel:(NSString *)[chunks objectAtIndex:i]];
				[tabview addTabViewItem:tvitem];
				cat++;
				/*IKImageView * imview=[[IKImageView alloc] init];
				f=[imview frame];
				f.origin=NSMakePoint(0, 0);
				NSRect tmp=[[tvitem view] frame];
				f.size=NSMakeSize(tmp.size.width,tmp.size.height);
				NSLog(@"%f %f\n",tmp.size.width,tmp.size.height);
				imview.frame=f;
				[imview setBackgroundColor:[NSColor yellowColor]];
				[[tvitem view] addSubview:imview];*/
			}else{
				[menuOutlet addItemWithTitle:(NSString *)[chunks objectAtIndex:i]];
				NSTabViewItem * tvitem=[tabview viewWithTag:(cat-1)];
				
				/*NSArray * items=[tabview tabViewItems];
				NSTabViewItem * tvitem=[items objectAtIndex:[items count]-1];*/
			}
		}
	}
	
	
	[fmenu closeFile];
	srand(time(0));
	NSError * err=nil;
	NSString * version = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.cs.ccu.edu.tw/~ksc91u/mac/hinedo.version"] encoding:NSASCIIStringEncoding error:&err];
	if ([version length]==5) {
		if ([version compare:HINEDO_MAC_VERSION]>0) {
			NSLog(@"Update\n");
			
			[versionInfo setAllowsEditingTextAttributes: YES];
			[versionInfo setSelectable: YES];
			
			NSURL* url = [NSURL URLWithString:@"http://ksc91u.googlepages.com/hinedomac"];
			
			NSMutableAttributedString* string = [[NSMutableAttributedString alloc] init];
			[string appendAttributedString: [NSAttributedString hyperlinkFromString:@"Update Available" withURL:url]];
			
			// set the attributed string to the NSTextField
			[versionInfo setAttributedStringValue: string];
			[string dealloc];
			
		}else {
			[versionInfo setTextColor:[NSColor grayColor]];
			[versionInfo setStringValue:[NSString stringWithFormat:@"Ver:%@",HINEDO_MAC_VERSION]];
			NSLog(@"%@ %@\n",HINEDO_MAC_VERSION,version);
		}
		
	}
	NSLog(@"%@ %d\n",version,[version length]);
	[self windowDidBecomeKey:nil];
}

- (void)awakeFromNib{
	[self setupMenu];
}

- (void)QTMovieRateDidChangeNotificationFunuc:(NSNotification *)notification
{
	if ([movie rate]==0) {
		NSLog(@"Movie Stopped\n");
		[button setTitle:@"Play"];
		[button setEnabled:YES];
		NSNotification * notify = [NSNotification notificationWithName:@"MyMovieShouldStop" object:nil];
		[[NSNotificationQueue defaultQueue] enqueueNotification:notify postingStyle:NSPostASAP];
		NSLog(@"movie retainCount %d\n",[movie retainCount]);
	}else{
		NSLog(@"Movie Begin %d\n",[movie rate]);
		[button setTitle:@"Stop"];
		[button setEnabled:YES];
	}
}

- (void)QTMovieLoadStateDidChangeNotificationFunc:(NSNotification *)notification
{
	long loadState = [[movie attributeForKey:QTMovieLoadStateAttribute] longValue];
	if (loadState ==  QTMovieLoadStateError ) {
		NSLog(@"Load failed\n");
		[button setTitle:@"Play"];
		[button setEnabled:YES];
		[movie stop];
	}
}

-(void)MyMovieShouldStopFunc:(NSNotification *)notification
{
	NSLog(@"Movie reset notify\n");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	NSLog(@"movie retainCount %d\n",[movie retainCount]);
	if([movie retainCount]>0)
		sleep(5);
	NSLog(@"movie retainCount %d\n",[movie retainCount]);
	[movie dealloc];
	movie=nil;
	if([fReconnect state]){
		[self playClicked:button];
	}
}

@end
