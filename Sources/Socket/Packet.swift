import Foundation

extension Socket {
	
	/// Receive UInt8 from socket.
	public func recvData(length : UInt32, flags : Int32) throws -> [UInt8] {
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
	
	/// Read UInt8 from socket.
	public func readData(length : UInt32) throws -> [UInt8] {
		var result : [UInt8] = [UInt8](repeating: 0, count: Int(length))
		var read : Int = 0
		var total : Int = 0
		
		// Loop through all of grouped message bytes
		while (total < Int(length)) {
			read += try self.read(length: size_t(length), result: result.withUnsafeMutableBytes { $0.baseAddress! } + total)
			total += read
			
			// Check for recv errors
			guard read > 0 else {
				throw SocketError.readFailed(String(cString: strerror(errno)))
			}
		}
		
		return result
	}
	
	/// Send packet data for outgoing message.
	public func sendData(data : [UInt8], flags : Int32) throws {
		guard try send(data: data, flags: flags) == data.count else {
			throw SocketError.sendFailed(String(cString: strerror(errno)))
		}
	}
	
	/// Write packet data for outgoing message.
	public func writeData(data : [UInt8]) throws {
		guard try write(data: data) == data.count else {
			throw SocketError.writeFailed(String(cString: strerror(errno)))
		}
	}
}
