/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "ComFactisresearchHtml2pdfModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

@interface UIPrintPageRenderer (PDF)

- (NSData*) printToPDF;

@end

@implementation UIPrintPageRenderer (PDF)

- (NSData*) printToPDF
{
    NSMutableData *pdfData = [NSMutableData data];
    
    UIGraphicsBeginPDFContextToData( pdfData, CGRectZero, nil );
    
    [self prepareForDrawingPages: NSMakeRange(0, self.numberOfPages)];
    
    CGRect bounds = UIGraphicsGetPDFContextBounds();
    
    for ( int i = 0 ; i < self.numberOfPages ; i++ )
    {
        UIGraphicsBeginPDFPage();
        
        [self drawPageAtIndex: i inRect: bounds];
    }
    
    UIGraphicsEndPDFContext();
    
    return pdfData;
}
@end

@implementation ComFactisresearchHtml2pdfModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"195aae55-5ec4-4f9b-85c6-64962ba21ad7";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"com.factisresearch.html2pdf";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
    NSLog(@"[INFO] listener added, type: %@", type);
	if (count == 1 && [type isEqualToString:@"ready"])
	{
		// the first (of potentially many) listener is being added 
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
    NSLog(@"[INFO] listener removed, type: %@", type);
	if (count == 0 && [type isEqualToString:@"ready"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return TRUE;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    UIPrintPageRenderer *render = [[UIPrintPageRenderer alloc] init];
    [render addPrintFormatter:webView.viewPrintFormatter startingAtPageAtIndex:0];
    
    CGRect printableRect = CGRectMake(36,
                                      72,
                                      540,
                                      684);
    
    CGRect paperRect = CGRectMake(0, 0, 612, 792);
    
    [render setValue:[NSValue valueWithCGRect:paperRect] forKey:@"paperRect"];
    [render setValue:[NSValue valueWithCGRect:printableRect] forKey:@"printableRect"];

    NSData *pdfData = [render printToPDF];
    
    NSArray *dirPaths;
    NSString *path;
    
    dispatch_queue_t heavy_lifting = dispatch_queue_create("com.fscz.html2pdf", NULL);
    dispatch_async(heavy_lifting, ^{
        NSArray *dirPaths;
        NSString *path;
        dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                       NSUserDomainMask, YES);

        path = [NSString stringWithFormat:@"%@/%@",[dirPaths objectAtIndex:0], filename];
        TiBlob* pdfBlob = [[[TiBlob alloc] initWithData:pdfData
                                               mimetype:@"application/octet-stream"] autorelease];
        NSLog(@"[INFO] writing blob to: %@", path)
        [pdfBlob writeTo: path error:NULL];
        
        NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:path, @"pdf", nil];
        NSLog(@"[INFO] firing 'pdfready' event");
        
        [self fireEvent:@"pdfready" withObject:event];
    });
}

#pragma Public APIs
- (void) setHtmlString:(id)args {
    ENSURE_TYPE_OR_NIL(args,NSArray);
    if ([args count] > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([args count] > 1) {
                filename = [[args objectAtIndex:1] retain];
            } else {
                filename = @"attachment.pdf";
            }
            NSString* html = [[args objectAtIndex:0] retain];
            webview = [[UIWebView alloc] initWithFrame: CGRectMake(0, 0, 1, 1)];
            [webview setDelegate: self];
            [webview loadHTMLString:html baseURL: nil];
        });
    }
}

@end


