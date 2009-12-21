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
		method_setImplementation(sizerMethod, (IMP)sizer);
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
	oldZoomer = method_getImplementation(zoomMethod);
	method_setImplementation(zoomMethod, (IMP)zoomer);
}

@end
