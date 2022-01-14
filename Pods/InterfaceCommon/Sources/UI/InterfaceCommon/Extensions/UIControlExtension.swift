import Combine
import UIKit

/// An extension of UIControl that allows the use of Combine for event handling.
extension UIControl {
    
    /// A custom Combine Publisher event handling struct.
    public struct EventPublisher: Publisher {
        
        /// Declare that the publisher emits Void and cannot fail.
        public typealias Output = Void
        public typealias Failure = Never

        fileprivate var control: UIControl
        fileprivate var event: Event

        /// Combine Protocol method for the Publisher.
        public func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
            /// Create the subscriber instance and subscribe to the publisher.
            let subscription = EventSubscription<S>()
            subscription.target = subscriber
            subscriber.receive(subscription: subscription)
            
            /// Lastly, use the control's add Target method.
            control.addTarget(subscription, action: #selector(subscription.trigger), for: event)
        }
    }
    
    /// The class subscriber referenced by the EventPublisher Struct to handle event subscription..
    private final class EventSubscription<Target: Subscriber>: Subscription where Target.Input == Void {
        /// The target subscriber (UIView/UIButton/etc).
        var target: Target?

        /// Combine Protocol method requirement
        func request(_ demand: Subscribers.Demand) {  /* Do nothing*/ }

        /// Invalidate target on subscription cancellation.
        func cancel() { target = nil }

        /// Forward gesture events received by using Combine.
        @objc func trigger() {  _ = target?.receive(()) }
    }
}

/// A general UIControl extension for Event Publishing
extension UIControl {
    public var tapPublisher: EventPublisher {
        publisher(for: .touchUpInside)
    }
    
    public func publisher(for event: Event) -> EventPublisher {
        EventPublisher(control: self, event: event)
    }
}
