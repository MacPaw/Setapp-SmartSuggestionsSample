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

  private var eventsControllers: [STPEventController]!

  private var isStarted: Bool = false {
    didSet { setupStartStopAvailability() }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let eventControllersBuilder = STPEventControllersBuilder()

    eventsControllers = [
      eventControllersBuilder.launchEventsController(),
    ]

    setupStartStopAvailability()
  }

  private func setupStartStopAvailability() {
    startButton.isEnabled = !isStarted
    stopButton.isEnabled = isStarted
  }

  @IBAction private func startPressed(_ sender: NSButton) {
    isStarted = true
    eventsControllers.forEach { $0.start() }
  }

  @IBAction private func stopPressed(_ sender: NSButton) {
    isStarted = false
    eventsControllers.forEach { $0.stop() }
  }
}

