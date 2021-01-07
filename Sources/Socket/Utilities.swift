import Foundation

extension sockaddr_in {
	init(_ from: sockaddr, port : UInt16) {
		self.init()
		
		// Init from sockaddr
		self.sin_family = from.sa_family
		self.sin_port = port.bigEndian
	}
}
