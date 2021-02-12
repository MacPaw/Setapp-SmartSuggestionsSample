//
//  STPEventProcessor.swift
//  SmartSuggestionsSample
//
//  Created by Vitalii Budnik on 2/11/21.
//  Copyright © 2021 Setapp Ltd. All rights reserved.
//

import Foundation

/// A protocol describing an object able to process events.
protocol STPEventProcessor {
  /// Starts event processing.
  ///
  /// - Note: Current event process should start processing events with a reseted cache, if any.
  func startEventProcessing()

  /// Processes the event.
  /// - Parameters:
  ///   - event: Event to process.
  ///   - callback: The completion handler to call when the event processing is complete.
  ///
  ///     This completion handler takes one parameter:
  ///
  ///       `canProcess` - A `Bool` indicating if the event is terminal and can be treated as a
  ///       trigger for the user applicationPromotion. `true` - the event can be treated as a trigger for
  ///       the user applicationPromotion, `false` - otherwise.
  func process(event: STPPromotionEvent, callback: @escaping (Bool) -> Void)

  /// Stops event processing.
  ///
  /// - Note: Current event process should stop processing any events.
  func stopEventProcessing()
}
