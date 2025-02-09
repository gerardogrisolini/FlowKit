//
//  AsyncThrowingSubject.swift
//  FlowKit
//
//  Created by Gerardo Grisolini on 28/01/23.
//

/// A subject that allows for asynchronously sending values or terminating with an error.
/// `AsyncThrowingSubject` acts as a bridge between imperative code and asynchronous code, enabling
/// you to send values to an `AsyncSequence` consumer while handling potential errors gracefully.
public struct AsyncThrowingSubject<Element: Sendable>: AsyncSequence, Sendable {

    /// The type of error that can terminate the sequence.
    public typealias Failure = any Error

    /// The iterator type that produces elements of the sequence.
    public typealias AsyncIterator = AsyncThrowingStream<Element, Failure>.Iterator

    /// The underlying stream used to manage asynchronous values and errors.
    private let stream: AsyncThrowingStream<Element, Failure>

    /// The continuation used to interact with the underlying stream by sending values or errors.
    private let continuation: AsyncThrowingStream<Element, Failure>.Continuation

    /// Initializes a new `AsyncThrowingSubject`.
    /// - Parameter elementType: The type of element the subject produces. Defaults to the inferred `Element` type.
    public init(_ elementType: Element.Type = Element.self) {
        var continuation: AsyncThrowingStream<Element, Failure>.Continuation!

        // Creates an `AsyncThrowingStream` with an unbounded buffering policy.
        // The continuation is captured for use in sending values or errors.
        stream = AsyncThrowingStream(bufferingPolicy: .unbounded) {
            continuation = $0
        }
        self.continuation = continuation
    }

    /// Creates and returns an asynchronous iterator for the sequence.
    /// - Returns: An iterator that produces elements asynchronously.
    public func makeAsyncIterator() -> AsyncThrowingStream<Element, Failure>.Iterator {
        stream.makeAsyncIterator()
    }

    /// Sends a value to the sequence.
    /// - Parameter value: The value to send.
    /// - Precondition: If the value is dropped (e.g., no consumers are listening), the function triggers a `preconditionFailure`.
    public func send(_ value: Element) {
        switch continuation.yield(value) {
        case .dropped(_):
            preconditionFailure("dropped")
        default:
            break
        }
    }

    /// Completes the sequence, optionally with an error.
    /// - Parameter error: An optional error that terminates the sequence. Defaults to `nil`.
    /// - Note: Once this method is called, no further values can be sent to the sequence.
    public func finish(throwing error: (any Error)? = nil) {
        continuation.finish(throwing: error)
    }
}
