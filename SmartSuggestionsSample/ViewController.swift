//
//  ViewController.swift
//  SmartSuggestionsSample
//
//  Created by Vitalii Budnik on 2/11/21.
//  Copyright © 2021 Setapp Ltd. All rights reserved.
//

import Cocoa

/// Manages activities of `STPEventController` with just two buttons (start & stop).
class ViewController: NSViewController {
  @IBOutlet private var startButton: NSButton!
  @IBOutlet private var stopButton: NSButton!

  private var eventsController: STPEventController!

  private var isStarted: Bool = false {
    didSet { setupStartStopAvailability() }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let processor = STPLaunchedAppsEventProcessor {
      let competitorsBundleIDs: [String] = [
        "com.apple.Notes",
        "com.box.box-notes",
        "net.shinyfrog.bear",
      ]

      return competitorsBundleIDs.map(STPPromotionEvent.didLaunchApp).contains($0)
    }

    eventsController = STPEventController(
      producer: STPLaunchedAppsEventProducer(),
      processor: processor,
      presenter: STPDefaultPromotionPresenter()
    )

    setupStartStopAvailability()
  }

  private func setupStartStopAvailability() {
    startButton.isEnabled = !isStarted
    stopButton.isEnabled = isStarted
  }

  @IBAction private func startPressed(_ sender: NSButton) {
    isStarted = true
    eventsController.start()
  }

  @IBAction private func stopPressed(_ sender: NSButton) {
    isStarted = false
    eventsController.stop()
  }
}

