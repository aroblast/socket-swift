//
//  SocketTest.swift
//  Socket
//
//  Created by Bastien LE CORRE on 2021-01-07.
//

import XCTest
import Socket

class SocketTests : XCTestCase {
	
	var socket : Socket? = nil
	
	override func setUpWithError() throws {
		socket = try Socket(
			host: "eu-cdbr-west-03.cleardb.net",
			port: 3306,
			addressFamily: AF_INET,
			socketType: SOCK_STREAM,
			socketProtocol: 0
		)
		try socket!.connect()
	}
	
	override func tearDownWithError() throws {
		try socket!.close()
	}
	
	func testRead() throws {
		return
	}
}
