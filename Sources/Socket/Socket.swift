import Foundation

public class Socket {
	let socket : Int32
	let addressFamily : Int32
	let socketType : Int32
	let socketProtocol : Int32
	
	var port : UInt16
	var infos : addrinfo = addrinfo()
	
	var maxConnections : Int32 = 1
	
	public init(host : String, port : UInt16, addressFamily : Int32, socketType : Int32, socketProtocol : Int32, maxConnections : Int32 = 1) throws {
		// Create socket
		self.addressFamily = addressFamily
		self.socketType = socketType
		self.socketProtocol = socketProtocol
		
		socket = Darwin.socket(addressFamily, socketType, socketProtocol)
		guard self.socket != -1 else {
			throw SocketError.socketCreationFailed(String(cString: strerror(errno)))
		}
		
		// Initialize parameters
		self.port = port
		self.maxConnections = maxConnections
		
		// Socket infos
		self.infos = try getAddrInfo(host)
		
		// MARK: SQL server only!
		// Set socket options
		var value : Int32 = 1;
		try setOption(level: SOL_SOCKET, option: SO_REUSEADDR, value: &value, length: socklen_t(MemoryLayout<Int32>.size))
		try setOption(level: SOL_SOCKET, option: SO_KEEPALIVE, value: &value, length: socklen_t(MemoryLayout<Int32>.size))
		try setOption(level: SOL_SOCKET, option: SO_NOSIGPIPE, value: &value, length: socklen_t(MemoryLayout<Int32>.size))
	}
	
	/// Connect client socket to server.
	public func connect() throws {
		guard Darwin.connect(socket, infos.ai_addr, socklen_t(infos.ai_addrlen)) != -1 else {
			throw SocketError.connectFailed(String(cString: strerror(errno)))
		}
	}
	
	/// Bind server to an address.
	public func bind() throws {
		guard Darwin.bind(socket, infos.ai_addr, socklen_t(infos.ai_addrlen)) != -1 else {
			throw SocketError.bindFailed(String(cString: strerror(errno)))
		}
	}
	
	/// Setup server socket to listen to incoming requests.
	public func listen() throws {
		guard Darwin.listen(socket, maxConnections) != -1 else {
			throw SocketError.listenFailed(String(cString: strerror(errno)))
		}
	}
	
	/// Disonnect socket.
	public func close() throws {
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
	
	// -- Utility --
	/// Get server address infos from host for socket connection.
	private func getAddrInfo(_ host : String) throws -> addrinfo {
		var hints : addrinfo = addrinfo(
			ai_flags: AI_ALL,
			ai_family: addressFamily,
			ai_socktype: socketType,
			ai_protocol: 0,
			ai_addrlen: 0,
			ai_canonname: nil,
			ai_addr: nil,
			ai_next: nil
		)
		var serverInfos : UnsafeMutablePointer<addrinfo>? = nil
		
		// Get infos
		if (getaddrinfo(nil, String(port), &hints, &serverInfos) != 0) {
			throw SocketError.getAddressInfoFailed(errno)
		}
		
		return serverInfos!.pointee
	}
}

// Enums
extension Socket {
	enum SocketError : Error {
		case socketCreationFailed(String)
		case socketShutdownFailed(String)
		case getAddressInfoFailed(Int32)
		case convertAddressFailed(String)
		case connectFailed(String)
		case bindFailed(String)
		case listenFailed(String)
		case writeFailed(String)
		case getPeerNameFailed(String)
		case convertingPeerNameFailed
		case getNameInfoFailed(String)
		case acceptFailed(String)
		case recvFailed(String)
		case setSockOptFailed(String)
		case getSockOptFailed(String)
	}
}
