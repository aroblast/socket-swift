import Foundation

public struct Packet {
	public let id : UInt8
	public let data : [UInt8]
}

extension Socket {
	
	/// Receive UInt8 from socket.
	public func recvUInt8(length : Int32, flags : Int32) throws -> [UInt8] {
		var result : [UInt8] = [UInt8](repeating: 0, count: Int(length))
		var received : Int = 0
		var total : Int = 0
		
		// Loop through all of grouped message bytes
		while (total < Int(length)) {
			received += try recv(length: size_t(length), result: result.withUnsafeMutableBytes { $0.baseAddress! } + total, flags: flags)
			total += received
			
			// Check for recv errors
			guard received > 0 else {
				throw SocketError.recvFailed(String(cString: strerror(errno)))
			}
		}
		
		return result
	}
	
	/// Receive header data for incoming message.
	public func recvHeader(length : Int32, flags : Int32 = 0) throws -> (UInt8, UInt16) {
		let result : [UInt8] = try recvUInt8(length: length, flags: flags)
		let packet : UInt8 = try recvUInt8(length: 1, flags: flags)[0]
		
		return (packet, result.withUnsafeBytes { $0.load(as: UInt16.self) })
	}
	
	/// Receive packet data for incoming message.
	public func recvPacket(headerLength : Int32, flags : Int32 = 0) throws -> Packet {
		let (packet, length) : (UInt8, UInt16) = try recvHeader(length: headerLength)
		let data : [UInt8] = try recvUInt8(length: Int32(length), flags: flags)
		
		return Packet(id: packet, data: data)
	}
	
	/// Send header data for outgoing  message.
	public func sendHeader(data : [UInt8], flags : Int32 = 0) throws {
		guard try send(data: data, flags: flags) > 0 else {
			throw SocketError.sendFailed(String(cString: strerror(errno)))
		}
	}
	
	/// Send packet data for outgoing message.
	public func sendPacket(header : [UInt8], data : [UInt8], flags : Int32 = 0) throws {
		try sendHeader(data: header)
		guard try send(data: data, flags: flags) == data.count else {
			throw SocketError.sendFailed(String(cString: strerror(errno)))
		}
	}
}
