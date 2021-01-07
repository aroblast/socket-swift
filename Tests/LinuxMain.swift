import XCTest

import SocketTests

var tests = [XCTestCaseEntry]()
tests += SocketTests.allTests()
XCTMain(tests)
