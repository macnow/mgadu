static void SlyvLog(NSString *message, ...)
{
	NSFileHandle *file;
	NSString	*fileName = [[NSString alloc]initWithString:@"/tmp/mgadu.log"];
	file = [NSFileHandle fileHandleForWritingAtPath:fileName];
	[file truncateFileAtOffset:[file seekToEndOfFile]];
	
	va_list		ap; /* Points to each unamed argument in turn */ 
	NSString	*debugMessage;
	va_start(ap, message); /* Make ap point to the first unnamed argument */
	debugMessage = [[NSString alloc] initWithFormat:message arguments:ap]; 
	
	[file writeData:[debugMessage dataUsingEncoding:NSUTF8StringEncoding]];
	NSString *newline = [[NSString alloc]initWithString:@"\n"]; 
	[file writeData:[newline dataUsingEncoding:nil]];
}