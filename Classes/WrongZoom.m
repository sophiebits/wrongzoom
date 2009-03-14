//
//  WrongZoom.m
//  WrongZoom
//

#import "WrongZoom.h"

#import <objc/objc-runtime.h>

@implementation WrongZoom

// windowWillUseStandardFrame:defaultFrame:
static NSRect sizer(id self, SEL _cmd, NSWindow *window, NSRect newFrame) {
	return newFrame;
}

static void swizzleSizer(Class class) {
	Method sizerMethod = class_getInstanceMethod(class, @selector(windowWillUseStandardFrame:defaultFrame:));
	if(sizerMethod != NULL)
		sizerMethod->method_imp = (IMP)sizer;
}

// - (void)zoom:(id)sender
static IMP oldZoomer;
static void zoomer(id self, SEL _cmd, id sender) {
	if([self delegate])
		swizzleSizer([[self delegate] class]);
	swizzleSizer([self class]);

	oldZoomer(self, _cmd, sender);
}

+ (void)load {
	NSLog(@"loaded WrongZoom");
	Class class = NSClassFromString(@"NSWindow");
	Method zoomMethod = class_getInstanceMethod(class, @selector(zoom:));
	oldZoomer = zoomMethod->method_imp;
	zoomMethod->method_imp = (IMP)zoomer;
}

@end
