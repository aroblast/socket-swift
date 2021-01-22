import Foundation

public class Socket {
	let socket : Int32
	let host : String?
	
	public let addressFamily : Int32
	public let socketType : Int32
	public let socketProtocol : Int32
	
	public var port : UInt16
	public var packet : UInt8 = 0
	
	var maxConnections : Int32 = 1
	
	public init(host : String?, port : UInt16, addressFamily : Int32, socketType : Int32, socketProtocol : Int32, maxConnections : Int32 = 1) throws {
		self.host = host
		self.addressFamily = addressFamily
		self.socketType = socketType
		self.socketProtocol = socketProtocol
		
		// Create socket
		socket = Darwin.socket(addressFamily, socketType, socketProtocol)
		guard self.socket != -1 else {
			throw SocketError.socketCreationFailed(String(cString: strerror(errno)))
		}
		
		// Initialize parameters
		self.port = port
		self.maxConnections = maxConnections
	}
	
	/// Connect client socket to server.
	public func connect(infos : addrinfo) throws {
		// Reset TCP packet ordering
		self.packet = 0
		
		guard Darwin.connect(socket, infos.ai_addr, socklen_t(infos.ai_addrlen)) != -1 else {
			throw SocketError.connectFailed(String(cString: strerror(errno)))
		}
	}
	
	public func connectAll(infos : [addrinfo]) throws {
		for info in infos {
			do {
				try connect(infos: info)
				return
			}
			catch {}
		}
	}
	
	/// Bind server to an address.
	public func bind(infos : addrinfo) throws {
		guard Darwin.bind(socket, infos.ai_addr, socklen_t(infos.ai_addrlen)) != -1 else {
			throw SocketError.bindFailed(String(cString: strerror(errno)))
		}
	}
	
	/// Setup server socket to listen to incoming requests.
	public func listen() throws {
		// Reset TCP packet ordering
		self.packet = 0
		
		guard Darwin.listen(socket, maxConnections) != -1 else {
			throw SocketError.listenFailed(String(cString: strerror(errno)))
		}
	}
	
	/// Disonnect socket.
	public func close() throws {
		// Reset TCP packet ordering
		self.packet = 0
		
		guard Darwin.close(socket) == 0 else {
			throw SocketError.socketShutdownFailed(String(cString: strerror(errno)))
		}
	}
	
	/// Get socket option.
	public func getOption<T>(level : Int32, option : Int32, length : UnsafeMutablePointer<socklen_t>) throws -> T {
		var result : T? = nil
		guard getsockopt(socket, level, option, withUnsafeMutablePointer(to: &result) { $0 }, length) != -1 else {
			throw SocketError.getSockOptFailed(String(cString: strerror(errno)))
		}
		
		return result!
	}
	
	/// Set socket option.
	public func setOption(level : Int32, option : Int32, value : UnsafeRawPointer, length : socklen_t) throws {
		guard setsockopt(socket, level, option, value, length) != -1 else {
			throw SocketError.getSockOptFailed(String(cString: strerror(errno)))
		}
	}
	
	/// Receive data from the connected socket.
	public func recv(length : size_t, result : UnsafeMutableRawPointer, flags : Int32) throws -> Int {
		let received : Int = Darwin.recv(socket, result, length, flags)
		guard received > 0 else {
			throw SocketError.recvFailed(String(cString: strerror(errno)))
		}
		
		return received
	}
	
	/// Read data from the connected socket.
	public func read(length : size_t, result : UnsafeMutableRawPointer) throws -> Int {
		let read : Int = Darwin.read(socket, result, length)
		guard read > 0 else {
			throw SocketError.recvFailed(String(cString: strerror(errno)))
		}
		
		return read
	}
	
	/// Send data to socket address.
	public func send(data : [UInt8], flags : Int32) throws -> Int {
		let sent : Int = Darwin.send(socket, data, size_t(data.count), flags)
		guard sent > 0 else {
			throw SocketError.sendFailed(String(cString: strerror(errno)))
		}
		
		return sent
	}
	
	/// Write data to socket address.
	public func write(data : [UInt8]) throws -> Int {
		let written : Int = Darwin.write(socket, data, size_t(data.count))
		guard written > 0 else {
			throw SocketError.writeFailed(String(cString: strerror(errno)))
		}
		
		return written
	}
	
	/// Get server address infos from host for socket connection.
	public func getAddressInfos() throws -> [addrinfo] {
		var result : [addrinfo] = []
		var hints : addrinfo = addrinfo(
			ai_flags: AI_ADDRCONFIG,
			ai_family: addressFamily,
			ai_socktype: socketType,
			ai_protocol: socketProtocol,
			ai_addrlen: 0,
			ai_canonname: nil,
			ai_addr: nil,
			ai_next: nil
		)
		var infos : UnsafeMutablePointer<addrinfo>? = nil
		
		// Get infos
		if (getaddrinfo(host, String(port), &hints, &infos) != 0) {
			throw SocketError.getAddressInfoFailed(errno)
		}
		
		while (infos != nil) {
			result.append(infos!.pointee)
			infos = infos!.pointee.ai_next
		}
		
		return result
	}

	// Signals
	public func on(event : Int32, handler : @convention(c) @escaping (Int32) -> Void) {
		signal(event, handler)
	}
}

// Enums
extension Socket {
	enum SocketError : Error {
		case socketCreationFailed(String)
		case socketShutdownFailed(String)
		case getAddressInfoFailed(Int32)
		case connectFailed(String)
		case bindFailed(String)
		case listenFailed(String)
		case sendFailed(String)
		case writeFailed(String)
		case getPeerNameFailed(String)
		case getNameInfoFailed(String)
		case acceptFailed(String)
		case recvFailed(String)
		case readFailed(String)
		case setSockOptFailed(String)
		case getSockOptFailed(String)
	}
}
