//
//  ReederReadabilityPlugin.m
//  ReederSIMBL
//
//  Created by Nick Maultsby on 3/22/18.
//  Copyright © 2018 Nick Maultsby. All rights reserved.
//

#import "ReederReadabilityPlugin.h"
#import <Cocoa/Cocoa.h>
#import <objc/objc-class.h>
#import "ZKSwizzle.h"

NSMutableDictionary* ReederReadability_ivars = nil;
static BOOL enabled = YES;

@implementation ReederReadabilityPlugin

#define EXISTS(cls, sel)                                                 \
do {                                                                 \
if (!class_getInstanceMethod(cls, sel))                          \
{                                                                \
NSLog(@"[ReederReadabilityPlugin] ERROR: Got nil Method for [%@ %@]", cls, \
NSStringFromSelector(sel));                            \
return;                                                      \
}                                                                \
} while (0)

+ (void) load
{
    NSLog(@"[ReederReadabilityPlugin] load");
    Class controller = NSClassFromString(@"ItemsViewController");
    if (!controller)
    {
        NSLog(@"[ReederReadabilityPlugin] ERROR: Got nil Class for ItemsViewController");
        return;
    }
    
    Class articleController = NSClassFromString(@"ArticleViewController");
    if (!articleController)
    {
        NSLog(@"[ReederReadabilityPlugin] ERROR: Got nil Class for ArticleViewController");
        return;
    }
    
    EXISTS(controller, @selector(controller:didChangeContent:));
    EXISTS(articleController, @selector(toggleReadability:));
    // Initialize instance vars before any swizzling so nothing bad happens
    // if some methods are swizzled but not others.
    ReederReadability_ivars = [[NSMutableDictionary alloc] init];
    
    ZKSwizzle(HookArticleViewController, ArticleViewController);
    ZKSwizzle(HookItemsViewController, ItemsViewController);
    
    [self insertMenuItem];
    
    NSLog(@"[ReederReadabilityPlugin] done loading");
}

+ (IBAction) toggle: (NSMenuItem*) sender
{
    [sender setState: ![sender state]];
    enabled = [sender state];
    
    NSLog(@"[ReederReadabilityPlugin] toggled %hhd", enabled);
}

+ (void) insertMenuItem;
{
    NSMenu* shellMenu = [[[NSApp mainMenu] itemAtIndex: 7] submenu];
    if (!shellMenu)
    {
        NSLog(@"[ReederReadabilityPlugin] ERROR: Shell menu not found");
        return;
    }
    
    [shellMenu addItem: [NSMenuItem separatorItem]];
    NSBundle *bundle = [NSBundle bundleForClass: self];
    NSString* t = NSLocalizedStringFromTableInBundle(@"Force Article Preview", nil,
                                                     bundle, nil);
    NSMenuItem* item = [shellMenu addItemWithTitle: t
                                            action: @selector(toggle:)
                                     keyEquivalent: @"m"];
    if (!item)
    {
        NSLog(@"[ReederReadabilityPlugin] ERROR: Unable to create menu item");
        return;
    }
    
    [item setKeyEquivalentModifierMask: (NSShiftKeyMask | NSCommandKeyMask)];
    [item setTarget: self];
    [item setState: NSOnState];
    [item setEnabled: YES];
}

@end

@interface HookItemsViewController : NSObject
- (void)controller:(id)arg1 didChangeContent:(id)arg2;
@end

@implementation HookItemsViewController
- (void)controller:(id)arg1 didChangeContent:(id)arg2
{
    NSLog(@"[ReederReadabilityPlugin] didChangeContent");
}
@end

@interface HookArticleViewController : NSObject
- (void)toggleReadability:(id)arg1;
- (void)setItem:(id)arg1 mark:(BOOL)arg2;
@end

@implementation HookArticleViewController
- (void)toggleReadability:(id)arg1
{
    NSLog(@"[ReederReadabilityPlugin] toggleReadability");
    NSLog(@"[ReederReadabilityPlugin] %@", [NSThread callStackSymbols]);
    _orig(void);
}
- (void)setItem:(id)arg1 mark:(BOOL)arg2

{
    NSLog(@"[ReederReadabilityPlugin] HookArticleViewController setItem");
    _orig(void, arg1, arg2);
    if (enabled)
    {
        [self performSelector:@selector(toggleReadability:)];
    }
}
@end
