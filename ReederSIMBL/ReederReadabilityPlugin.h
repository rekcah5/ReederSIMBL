//
//  ReederReadabilityPlugin.h
//  ReederSIMBL
//
//  Created by Nick Maultsby on 3/22/18.
//  Copyright © 2018 Nick Maultsby. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ReederReadabilityPlugin : NSWindowController
+ (void) load;
+ (void) insertMenuItem;
- (void) Readability_didChangeContent: (id) viewId;
- (void) ReederReadabilitytoggleReadability:(id)arg1;
@end
