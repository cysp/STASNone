//  Copyright (c) 2013 Scott Talbot. All rights reserved.

#import <XCTest/XCTest.h>

#import "STASN1der.h"


@interface STASN1derTests : XCTestCase
@end

@implementation STASN1derTests

- (void)testIdentifierExtraction {
	struct identifier_testcase {
		unsigned char const input;
		struct STASN1derIdentifier const expected;
		enum STASN1derIdentifierValidity const validity;
	} const testcases[] = {
		{
			.input = 0x00,
			.expected = { .class = STASN1derIdentifierClassUniversal, .constructed = false, .tag = STASN1derIdentifierTagEOC },
			.validity = STASN1derIdentifierValid,
		},
		{
			.input = 0x20,
			.expected = { .class = STASN1derIdentifierClassUniversal, .constructed = true, .tag = STASN1derIdentifierTagEOC },
			.validity = STASN1derIdentifierInvalid,
		},
		{
			.input = 0x01,
			.expected = { .class = STASN1derIdentifierClassUniversal, .constructed = false, .tag = STASN1derIdentifierTagBOOLEAN },
			.validity = STASN1derIdentifierValid,
		},
		{
			.input = 0x02,
			.expected = { .class = STASN1derIdentifierClassUniversal, .constructed = false, .tag = STASN1derIdentifierTagINTEGER },
			.validity = STASN1derIdentifierValid,
		},
		{
			.input = 0x10,
			.expected = { .class = STASN1derIdentifierClassUniversal, .constructed = false, .tag = STASN1derIdentifierTagSEQUENCE },
			.validity = STASN1derIdentifierInvalid,
		},
		{
			.input = 0x30,
			.expected = { .class = STASN1derIdentifierClassUniversal, .constructed = true, .tag = STASN1derIdentifierTagSEQUENCE },
			.validity = STASN1derIdentifierValid,
		},
	};
	unsigned int const ntestcases = sizeof(testcases) / sizeof(testcases[0]);

	for (unsigned int i = 0; i < ntestcases; ++i) {
		struct identifier_testcase testcase = testcases[i];
		struct STASN1derIdentifier const output = STASN1derIdentifierFromChar(testcase.input);
		enum STASN1derIdentifierValidity const validity = STASN1derIdentifierValidate(output);

		bool equal = !memcmp(&testcase.expected, &output, sizeof(testcase.expected));
		XCTAssertTrue(equal, @"");

		XCTAssertEqual(testcase.validity, validity, @"");
	}
}

- (void)testParseFailure {
	{
		char input_bytes[] = "\x01\x01";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];

		NSError *error = nil;
		STASN1derObject * const output = [STASN1derParser objectFromASN1Data:inputData error:&error];
		XCTAssertNil(output, @"error: %@", error);
		XCTAssertEqual(error.code, (NSInteger)STASN1derErrorUnexpectedEOD, @"");
	}

	{
		char input_bytes[] = "\x01\x04\x00";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];

		NSError *error = nil;
		STASN1derObject * const output = [STASN1derParser objectFromASN1Data:inputData error:&error];
		XCTAssertNil(output, @"error: %@", error);
		XCTAssertEqual(error.code, (NSInteger)STASN1derErrorUnexpectedEOD, @"");
	}

	{
		char input_bytes[] = "\x00\x00\x00";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];

		NSError *error = nil;
		STASN1derObject * const output = [STASN1derParser objectFromASN1Data:inputData error:&error];
		XCTAssertNil(output, @"error: %@", error);
		XCTAssertEqual(error.code, (NSInteger)STASN1derErrorUnexpectedEOD, @"");
	}
}

- (void)testParseContentLength {
	{
		char input_bytes[] = "\x02\x81\x01\xff";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];
		long long const expected = -1;

		NSError *error = nil;
		STASN1derIntegerObject * const output = [STASN1derParser objectFromASN1Data:inputData error:&error];
		XCTAssertNotNil(output, @"error: %@", error);
		if (output) {
			XCTAssert([output isKindOfClass:[STASN1derIntegerObject class]], @"");
			XCTAssertEqual(output.value, expected, @"");
		}
	}

	{
		char input_bytes[] = "\x02\x81";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];

		NSError *error = nil;
		STASN1derObject * const output = [STASN1derParser objectFromASN1Data:inputData error:&error];
		XCTAssertNil(output, @"error: %@", error);
		XCTAssertEqual(error.code, (NSInteger)STASN1derErrorUnexpectedEOD, @"");
	}

	{
		char input_bytes[] = "\x02\x81\x01";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];

		NSError *error = nil;
		STASN1derObject * const output = [STASN1derParser objectFromASN1Data:inputData error:&error];
		XCTAssertNil(output, @"error: %@", error);
		XCTAssertEqual(error.code, (NSInteger)STASN1derErrorUnexpectedEOD, @"");
	}

	{
		char input_bytes[] = "\x02\x81\x02\xff";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];

		NSError *error = nil;
		STASN1derObject * const output = [STASN1derParser objectFromASN1Data:inputData error:&error];
		XCTAssertNil(output, @"error: %@", error);
		XCTAssertEqual(error.code, (NSInteger)STASN1derErrorUnexpectedEOD, @"");
	}

	{
		char input_bytes[] = "\x02\x82\x00\x01\xff";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];
		long long const expected = -1;

		NSError *error = nil;
		STASN1derIntegerObject * const output = [STASN1derParser objectFromASN1Data:inputData error:&error];
		XCTAssertNotNil(output, @"error: %@", error);
		if (output) {
			XCTAssert([output isKindOfClass:[STASN1derIntegerObject class]], @"");
			XCTAssertEqual(output.value, expected, @"");
		}
	}

	{
		char input_bytes[] = "\x02\x82\x00\x01\xff\x01\x01\x00";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];
		long long const expected0 = -1;
		BOOL const expected1 = NO;

		NSError *error = nil;
		NSArray * const output = [STASN1derParser objectsFromASN1Data:inputData error:&error];
		XCTAssertNotNil(output, @"error: %@", error);
		if (output) {
			STASN1derIntegerObject * const output0 = output[0];
			XCTAssert([output0 isKindOfClass:[STASN1derIntegerObject class]], @"");
			XCTAssertEqual(output0.value, expected0, @"");
			STASN1derBooleanObject * const output1 = output[1];
			XCTAssert([output1 isKindOfClass:[STASN1derBooleanObject class]], @"");
			XCTAssertEqual(output1.value, expected1, @"");
		}
	}
}

- (void)testParseNULL {
	{
		char input_bytes[] = "\x05\x00";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];

		NSError *error = nil;
		STASN1derObject * const output = [STASN1derParser objectFromASN1Data:inputData error:&error];
		XCTAssertNotNil(output, @"error: %@", error);
		if (output) {
			XCTAssert([output isKindOfClass:[STASN1derNullObject class]], @"");
		}
	}
}

- (void)testParseBOOLEAN {
	{
		char input_bytes[] = "\x01\x01\x00";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];
		BOOL const expected = 0;

		NSError *error = nil;
		STASN1derBooleanObject * const output = [STASN1derParser objectFromASN1Data:inputData error:&error];
		XCTAssertNotNil(output, @"error: %@", error);
		if (output) {
			XCTAssert([output isKindOfClass:[STASN1derBooleanObject class]], @"");
			XCTAssertEqual(output.value, expected, @"");
		}
	}

	{
		char input_bytes[] = "\x01\x01\x01";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];
		BOOL const expected = YES;

		NSError *error = nil;
		STASN1derBooleanObject * const output = [STASN1derParser objectFromASN1Data:inputData error:&error];
		XCTAssertNotNil(output, @"error: %@", error);
		if (output) {
			XCTAssert([output isKindOfClass:[STASN1derBooleanObject class]], @"");
			XCTAssertEqual(output.value, expected, @"");
		}
	}

	{
		char input_bytes[] = "\x01\x01\xff";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];
		BOOL const expected = YES;

		NSError *error = nil;
		STASN1derBooleanObject * const output = [STASN1derParser objectFromASN1Data:inputData error:&error];
		XCTAssertNotNil(output, @"error: %@", error);
		if (output) {
			XCTAssert([output isKindOfClass:[STASN1derBooleanObject class]], @"");
			XCTAssertEqual(output.value, expected, @"");
		}
	}
}

- (void)testParseINTEGER {
	{
		char input_bytes[] = "\x02\x01\xff";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];
		long long const expected = -1;

		NSError *error = nil;
		STASN1derIntegerObject * const output = [STASN1derParser objectFromASN1Data:inputData error:&error];
		XCTAssertNotNil(output, @"error: %@", error);
		if (output) {
			XCTAssert([output isKindOfClass:[STASN1derIntegerObject class]], @"");
			XCTAssertEqual(output.value, expected, @"");
		}
	}

	{
		char input_bytes[] = "\x02\x01\xfe";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];
		long long const expected = -2;

		NSError *error = nil;
		STASN1derIntegerObject * const output = [STASN1derParser objectFromASN1Data:inputData error:&error];
		XCTAssertNotNil(output, @"error: %@", error);
		if (output) {
			XCTAssert([output isKindOfClass:[STASN1derIntegerObject class]], @"");
			XCTAssertEqual(output.value, expected, @"");
		}
	}
}

- (void)testParseOCTETSTRING {
	{
		char input_bytes[] = "\x04\x07\x04\x0A\x3B\x5F\x29\x1C\xD0";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];
		char expected_bytes[] = "\x04\x0A\x3B\x5F\x29\x1C\xD0";
		unsigned long const expected_len = sizeof(expected_bytes) - 1;
		NSData * const expected = [[NSData alloc] initWithBytesNoCopy:expected_bytes length:expected_len freeWhenDone:NO];

		NSError *error = nil;
		STASN1derOctetStringObject * const output = [STASN1derParser objectFromASN1Data:inputData error:&error];
		XCTAssertNotNil(output, @"error: %@", error);
		if (output) {
			XCTAssert([output isKindOfClass:[STASN1derOctetStringObject class]], @"");
			XCTAssertEqualObjects(output.value, expected, @"");
		}
	}
}

- (void)testParseIA5STRING {
	{
		char input_bytes[] = "\x16\x05Hello";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];
		NSString * const expected = @"Hello";

		NSError *error = nil;
		STASN1derIA5StringObject * const output = [STASN1derParser objectFromASN1Data:inputData error:&error];
		XCTAssertNotNil(output, @"error: %@", error);
		if (output) {
			XCTAssert([output isKindOfClass:[STASN1derIA5StringObject class]], @"");
			XCTAssertEqualObjects(output.value, expected, @"");
		}
	}
}

- (void)testParseUTF8STRING {
	{
		char input_bytes[] = "\x0C\x05Hello";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];
		NSString * const expected = @"Hello";

		NSError *error = nil;
		STASN1derUTF8StringObject * const output = [STASN1derParser objectFromASN1Data:inputData error:&error];
		XCTAssertNotNil(output, @"error: %@", error);
		if (output) {
			XCTAssert([output isKindOfClass:[STASN1derUTF8StringObject class]], @"");
			XCTAssertEqualObjects(output.value, expected, @"");
		}
	}
}

- (void)testParseSEQUENCE {
	{
		char input_bytes[] = "\x30\x03\x01\x01\x00";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];
		BOOL const expected0 = NO;

		NSError *error = nil;
		STASN1derSequenceObject * const output = [STASN1derParser objectFromASN1Data:inputData error:&error];
		XCTAssertNotNil(output, @"error: %@", error);
		if (output) {
			XCTAssert([output isKindOfClass:[STASN1derSequenceObject class]], @"");
			STASN1derBooleanObject * const output0 = output[0];
			XCTAssert([output0 isKindOfClass:[STASN1derBooleanObject class]], @"");
			XCTAssertEqual(output0.value, expected0, @"");
		}
	}

	{
		char input_bytes[] = "\x30\x03\x01\x01\xff";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];
		BOOL const expected0 = YES;

		NSError *error = nil;
		STASN1derSequenceObject * const output = [STASN1derParser objectFromASN1Data:inputData error:&error];
		XCTAssertNotNil(output, @"error: %@", error);
		if (output) {
			XCTAssert([output isKindOfClass:[STASN1derSequenceObject class]], @"");
			STASN1derBooleanObject * const output0 = output[0];
			XCTAssert([output0 isKindOfClass:[STASN1derBooleanObject class]], @"");
			XCTAssertEqual(output0.value, expected0, @"");
		}
	}

	{
		char input_bytes[] = "\x30\x06\x01\x01\x00\x01\x01\xff";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];
		BOOL const expected0 = NO;
		BOOL const expected1 = YES;

		NSError *error = nil;
		STASN1derSequenceObject * const output = [STASN1derParser objectFromASN1Data:inputData error:&error];
		XCTAssertNotNil(output, @"error: %@", error);
		if (output) {
			XCTAssert([output isKindOfClass:[STASN1derSequenceObject class]], @"");
			STASN1derBooleanObject * const output0 = output[0];
			XCTAssert([output0 isKindOfClass:[STASN1derBooleanObject class]], @"");
			XCTAssertEqual(output0.value, expected0, @"");
			STASN1derBooleanObject * const output1 = output[1];
			XCTAssert([output1 isKindOfClass:[STASN1derBooleanObject class]], @"");
			XCTAssertEqual(output1.value, expected1, @"");
		}
	}

	{
		char input_bytes[] = "\x30\x0a\x16\x05Smith\x01\x01\xff";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];
		NSString * const expected0 = @"Smith";
		BOOL const expected1 = YES;

		NSError *error = nil;
		STASN1derSequenceObject * const output = [STASN1derParser objectFromASN1Data:inputData error:&error];
		XCTAssertNotNil(output, @"error: %@", error);
		if (output) {
			XCTAssert([output isKindOfClass:[STASN1derSequenceObject class]], @"");
			STASN1derIA5StringObject * const output0 = output[0];
			XCTAssert([output0 isKindOfClass:[STASN1derIA5StringObject class]], @"");
			XCTAssertEqualObjects(output0.value, expected0, @"");
			STASN1derBooleanObject * const output1 = output[1];
			XCTAssert([output1 isKindOfClass:[STASN1derBooleanObject class]], @"");
			XCTAssertEqual(output1.value, expected1, @"");
		}
	}
}

- (void)testParsePKCS7File {
	NSBundle * const bundle = [NSBundle bundleForClass:[self class]];
	NSURL * const url = [bundle URLForResource:@"sequence.0.signed" withExtension:nil subdirectory:@"t"];
	NSData * const inputData = [[NSData alloc] initWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:NULL];

	NSError *error = nil;
	NSArray * const output = [STASN1derParser objectFromASN1Data:inputData error:&error];
	XCTAssertNotNil(output, @"error: %@", error);
	XCTAssertEqual([output count], (NSUInteger)2, @"");
	if ([output count] == 2) {
		{
			id object1 = output[0];
			XCTAssertTrue([object1 isKindOfClass:[STASN1derObject class]], @"");
			if ([object1 isKindOfClass:[STASN1derObject class]]) {
				STASN1derObject *o = object1;
				XCTAssertEqual(o.identifier.class, STASN1derIdentifierClassUniversal, @"");
				XCTAssertEqual(o.identifier.constructed, (bool)false, @"");
				XCTAssertEqual(o.identifier.tag, STASN1derIdentifierTagOBJECTIDENTIFIER, @"");
			}
		}
		{
			id object2 = output[1];
			XCTAssertTrue([object2 isKindOfClass:[STASN1derObject class]], @"");
			if ([object2 isKindOfClass:[STASN1derObject class]]) {
				STASN1derObject *o = object2;
				XCTAssertEqual(o.identifier.class, STASN1derIdentifierClassContextSpecific, @"");
				XCTAssertEqual(o.identifier.constructed, (bool)true, @"");
				XCTAssertEqual(o.identifier.tag, (enum STASN1derIdentifierTag)0, @"");
			}
		}
	}
}

- (void)testOIDDecode {
	uint8_t const oidBytes[] = { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x07, 0x02 };
	size_t const nOidBytes = sizeof(oidBytes) / sizeof(oidBytes[0]);
	NSData * const oidData = [[NSData alloc] initWithBytesNoCopy:(void *)oidBytes length:nOidBytes freeWhenDone:NO];
	NSIndexPath * const oid = STASN1derObjectIdentifierIndexPathFromData(oidData);

	NSUInteger const expectedIndexes[] = { 1, 2, 840, 113549, 1, 7, 2 };
	NSUInteger const nExpectedIndexes = sizeof(expectedIndexes) / sizeof(expectedIndexes[0]);
	NSIndexPath * const expected = [[NSIndexPath alloc] initWithIndexes:expectedIndexes length:nExpectedIndexes];

	XCTAssertEqualObjects(oid, expected, @"");
}

@end
