//
//  STPEventProducer.swift
//  SmartSuggestionsSample
//
//  Created by Vitalii Budnik on 2/11/21.
//  Copyright © 2021 Setapp Ltd. All rights reserved.
//

import Foundation

/// A protocol describing an object that can produce `STPPromotionEvent`s and delegate it's processing to
/// another object.
protocol STPEventProducer: AnyObject {
  var delegate: STPEventProducerDelegate? { get set }

  /// Start producing events.
  func startEventProducing()

  /// Stop producing events.
  func stopEventProducing()
}

/// A protocol describing an object that can handle produced `STPPromotionEvent`s.
protocol STPEventProducerDelegate: AnyObject {
  /// Tells the delegate an event is produced.
  ///
  /// - Parameter event: A produced event.
  func didProduceEvent(_ event: STPPromotionEvent)
}
