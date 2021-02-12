//
//  STPDispatchQueueFactory.swift
//  SmartSuggestionsSample
//
//  Created by Vitalii Budnik on 2/11/21.
//  Copyright © 2021 Setapp Ltd. All rights reserved.
//

import Foundation

/// The factory of dispatch queues allowing to nest all internal queues under one target queue.
final class STPDispatchQueueFactory: NSObject {
  /// The target queue for new queues.
  private let targetQueue: DispatchQueue

  public init(targetQueue: DispatchQueue) {
    self.targetQueue = targetQueue
    super.init()
  }
}

extension STPDispatchQueueFactory {
  /// Returns a new dispatch queue to which you can submit blocks.
  ///
  /// - Parameters:
  ///   - label: A string label to attach to the queue to uniquely identify it in debugging tools.
  ///   - qos: The quality-of-service level to associate with the queue.
  ///   - attributes: The attributes to associate with new queues.
  private func queue(label: String, qos: DispatchQoS, attributes: DispatchQueue.Attributes) -> DispatchQueue {
    .init(
      label: targetQueue.label + "." + label,
      qos: qos,
      attributes: attributes,
      autoreleaseFrequency: .inherit,
      target: targetQueue
    )
  }

  /// Returns a new serial dispatch queue to which you can submit blocks.
  ///
  /// - Parameters:
  ///   - label: A string label to attach to the queue to uniquely identify it in debugging tools.
  ///   - qos: The quality-of-service level to associate with the queue. Default value: `.utility`.
  func queue(label: String, qos: DispatchQoS = .utility) -> DispatchQueue {
    queue(label: label, qos: qos, attributes: [])
  }

  /// Returns a new dispatch queue factory with a new underlying concurrent queue.
  ///
  /// - Parameters:
  ///   - label: A string label to attach to the queue to uniquely identify it in debugging tools.
  ///   - qos: The quality-of-service level to associate with the queue. Default value: `.utility`.
  func newFactory(label: String, qos: DispatchQoS = .utility) -> STPDispatchQueueFactory {
    .init(targetQueue: queue(label: label, qos: qos, attributes: .concurrent))
  }
}


// MARK: - Shared

extension STPDispatchQueueFactory {
  /// Shared concurrent queue.
  private static let targetQueue: DispatchQueue = .init(
    label: Bundle.main.bundleIdentifier!,
    qos: .utility,
    attributes: .concurrent
  )

  /// Shared `STPDispatchQueueFactory`.
  static let shared: STPDispatchQueueFactory = .init(targetQueue: targetQueue)
}
