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
		
		// Set socket options
		var value : Int32 = 1;
		try socket!.setOption(level: SOL_SOCKET, option: SO_REUSEADDR, value: &value, length: socklen_t(MemoryLayout<Int32>.size))
		try socket!.setOption(level: SOL_SOCKET, option: SO_KEEPALIVE, value: &value, length: socklen_t(MemoryLayout<Int32>.size))
		try socket!.setOption(level: SOL_SOCKET, option: SO_NOSIGPIPE, value: &value, length: socklen_t(MemoryLayout<Int32>.size))
		
		// Try all connections
		try socket!.connectAll(infos: try socket!.getAddressInfos())
	}
}
