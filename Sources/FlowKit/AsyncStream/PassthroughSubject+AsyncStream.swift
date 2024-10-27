//
//  PassthroughSubject+AsyncStream.swift
//  
//
//  Created by Gerardo Grisolini on 29/01/23.
//

//import Combine
//
//public extension PassthroughSubject where Failure == Never {
//	var asyncStream: AsyncStream<Output> {
//		AsyncStream { continuation in
//			let cancellable = self.sink { continuation.yield($0) }
//			continuation.onTermination = { continuation in
//				cancellable.cancel()
//			}
//		}
//	}
//}
//
//extension AnyCancellable: @unchecked Sendable { }
