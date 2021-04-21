//
//  STPDownloadedFilesEventProcessor.swift
//  SmartSuggestionsSample
//
//  Created by Vitalii Budnik on 4/2/21.
//  Copyright © 2021 Setapp Ltd. All rights reserved.
//

import Foundation

class STPDownloadedFilesEventProcessor: STPEventProcessor {
  func startEventProcessing() {
    queue.async(execute: _startEventProcessing)
  }

  func process(event: STPPromotionEvent, callback: @escaping (Bool) -> Void) {
    queue.async {
      self._process(event: event, callback: callback)
    }
  }

  func stopEventProcessing() {
    queue.async(execute: _stopEventProcessing)
  }

  private var canProcessEvents: Bool = false
  private let queue: DispatchQueue
  private let filter: (URL) -> Bool

  init(
    filter: @escaping (URL) -> Bool,
    queue: DispatchQueue = STPDispatchQueueFactory.shared.queue(label: "downloadedFilesProcessor")
  )
  {
    self.queue = queue
    self.filter = filter
  }

  private func _startEventProcessing() {
    canProcessEvents = true
  }

  private func _process(event: STPPromotionEvent, callback: @escaping (Bool) -> Void) {
    guard canProcessEvents else { return }
    guard case let STPPromotionEvent.didDownloadFile(path: path) = event else { return }

    callback(filter(path))
  }

  private func _stopEventProcessing() {
    canProcessEvents = false
  }
}
