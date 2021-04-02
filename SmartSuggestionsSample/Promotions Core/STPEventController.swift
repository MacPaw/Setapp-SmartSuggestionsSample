//
//  STPEventController.swift
//  SmartSuggestionsSample
//
//  Created by Vitalii Budnik on 2/11/21.
//  Copyright © 2021 Setapp Ltd. All rights reserved.
//

import Foundation

class STPEventController: STPEventProducerDelegate {
  /// Event producer.
  private let producer: STPEventProducer
  /// Event processor.
  private let processor: STPEventProcessor
  /// Application promotions presenter.
  private let presenter: STPPromotionPresenter
  /// Promotion builder.
  ///
  /// Builds promotion based on event.
  private let promotionBuilder: (STPPromotionEvent) -> STPApplicationPromotion

  init(
    producer: STPEventProducer,
    processor: STPEventProcessor,
    presenter: STPPromotionPresenter,
    promotionBuilder: @escaping (STPPromotionEvent) -> STPApplicationPromotion
  )
  {
    self.producer = producer
    self.processor = processor
    self.presenter = presenter
    self.promotionBuilder = promotionBuilder

    producer.delegate = self
  }

  /// Stops event processor & event producer.
  func start() {
    processor.startEventProcessing()
    producer.startEventProducing()
  }

  /// Stops event producer & event processor.
  func stop() {
    producer.stopEventProducing()
    processor.stopEventProcessing()
  }

  /// Handles produced event & presents it if it's allowed by the event processor & promotions
  /// presenter can present it.
  ///
  /// - Parameter event: A produced event.
  func didProduceEvent(_ event: STPPromotionEvent) {
    processor.process(event: event) { [presenter, promotionBuilder] (canProcess) in
      guard canProcess else { return }
      presenter.present(applicationPromotion: promotionBuilder(event)) { (wasPresented) in
        if wasPresented {
          print("Yay! The app was promoted 🎉!")
        } else {
          print("Oh, no! Something went wrong 🙈.")
        }
      }
    }
  }
}
