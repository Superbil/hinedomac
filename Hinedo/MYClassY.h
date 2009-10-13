#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CoreFoundation.h>
#import <QTKit/QTMovie.h>
#import "RegexKitLite.h"
#ifdef DEBUG
#define HINEDO_MAC_VERSION @"2A3B Debug\n"
#else
#define HINEDO_MAC_VERSION @"2A3B\n"
#endif

@interface MYClassY :NSObject /* Specify a superclass (eg: NSObject or NSView) */ 
{
    IBOutlet id textField;
	IBOutlet id versionInfo;
	IBOutlet id menuOutlet;
	IBOutlet id window;
	IBOutlet NSButton* button;
	IBOutlet id fReconnect;
	IBOutlet NSSlider* volumeBar;
	
	IBOutlet NSImageView* img;
	
	IBOutlet NSTabView* tabview;
	QTMovie * movie;
}
- (IBAction)playClicked:(id)sender;
- (IBAction)stationChanged:(id)sender;
- (IBAction)volumeChanged:(id)sender;
- (void)awakeFromNib;
@end

@interface NSAttributedString (Hyperlink)
+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL;
@end

@implementation NSAttributedString (Hyperlink)
+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL
{
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString: inString];
    NSRange range = NSMakeRange(0, [attrString length]);
	
    [attrString beginEditing];
    [attrString addAttribute:NSLinkAttributeName value:[aURL absoluteString] range:range];
	
    // make the text appear in blue
    [attrString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:range];
	
    // next make the text appear with an underline
    [attrString addAttribute:
	 NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:range];
	
    [attrString endEditing];
	
    return [attrString autorelease];
}
@end
