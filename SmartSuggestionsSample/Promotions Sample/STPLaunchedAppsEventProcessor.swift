//
//  STPLaunchedAppsEventProcessor.swift
//  SmartSuggestionsSample
//
//  Created by Vitalii Budnik on 2/11/21.
//  Copyright © 2021 Setapp Ltd. All rights reserved.
//

import Foundation

/*
 Your new produced will definitely need a new processor.
 */

/// Allows further event processing if the app launched every Nth time.
class STPLaunchedAppsEventProcessor: STPEventProcessor {
  private let queue: DispatchQueue
  private let threshold: Int
  private let filter: (STPPromotionEvent) -> Bool

  init(
    queue: DispatchQueue = STPDispatchQueueFactory.shared.queue(label: "eventProcessor"),
    threshold: Int = 3,
    filter: @escaping (STPPromotionEvent) -> Bool
  )
  {
    self.queue = queue
    self.threshold = threshold
    self.filter = filter
  }

  private var appLaunchCount: Int = 0

  // MARK: - Start
  func startEventProcessing() {
    queue.async(execute: _startEventProcessing)
  }

  func _startEventProcessing() {
    appLaunchCount = 0
  }

  // MARK: - Stop

  func stopEventProcessing() {
    queue.async(execute: _stopEventProcessing)
  }

  func _stopEventProcessing() {}

  // MARK: - Processing

  func process(event: STPPromotionEvent, callback: @escaping (Bool) -> Void) {
    guard filter(event) else { return callback(false) }

    queue.async { [self] in _process(event: event, callback: callback) }
  }

  private func _process(event: STPPromotionEvent, callback: @escaping (Bool) -> Void) {
    appLaunchCount += 1

    if appLaunchCount == threshold {
      callback(true)
      appLaunchCount = 0
    } else {
      callback(false)
    }
  }
}
