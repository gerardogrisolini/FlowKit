//
//  TimerStream.swift
//  
//
//  Created by Gerardo Grisolini on 01/02/23.
//

import Foundation
import Combine

public class TimerStream<Element>: AsyncSequence, @unchecked Sendable {
	public typealias Element = Int
	
	private var cancellable: Cancellable? = nil
	private var continuation: AsyncStream<Int>.Continuation!
	public var stream: AsyncStream<Int> = AsyncStream { _ in }
	public var isRunning: Bool { cancellable != nil }
	public var countdown: Int = 0

	public func makeAsyncIterator() -> AsyncStream<Int>.Iterator {
		stream.makeAsyncIterator()
	}

	public func start(countdown: Int = 30) {

		self.countdown = countdown
		
		var continuation: AsyncStream<Int>.Continuation!
		stream = AsyncStream(bufferingPolicy: .unbounded) {
			continuation = $0
		}
		self.continuation = continuation

		cancellable = Timer
			.publish(every: 1, on: .main, in: .common)
			.autoconnect()
			.sink { [weak self] _ in
				self?.onChange()
			}

	}
	
	private func onChange() {
		
		countdown -= 1
		continuation.yield(countdown)
		
		if countdown <= 0 { stop() }

	}
	
	public func stop() {
		
		cancellable?.cancel()
		cancellable = nil
		
		continuation.finish()
		
	}
	
}
