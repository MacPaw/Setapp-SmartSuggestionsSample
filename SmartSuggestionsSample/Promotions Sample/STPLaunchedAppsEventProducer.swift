//
//  STPLaunchedAppsEventProducer.swift
//  SmartSuggestionsSample
//
//  Created by Vitalii Budnik on 2/11/21.
//  Copyright © 2021 Setapp Ltd. All rights reserved.
//

import Foundation
import AppKit

/*
 You can even write your own event producer.
 */

/// Produces events describing other applications lifecycle.
class STPLaunchedAppsEventProducer: STPEventProducer {
  var delegate: STPEventProducerDelegate?

  private let notificationCenter: NotificationCenter
  private let queue: DispatchQueue

  private var notificationObserver: NSObjectProtocol?

  init(
    notificationCenter: NotificationCenter = NSWorkspace.shared.notificationCenter,
    queue: DispatchQueue = STPDispatchQueueFactory.shared.queue(label: "appsMonitor")
  )
  {
    self.notificationCenter = notificationCenter
    self.queue = queue
  }

  deinit {
    _stop()
  }

  // MARK: - Start

  func startEventProducing() {
    queue.async(execute: _start)
  }

  private func _start() {
    guard notificationObserver == nil else { return }

    notificationObserver = notificationCenter.addObserver(
      forName: NSWorkspace.didLaunchApplicationNotification,
      object: .none,
      queue: .none) { [weak self] (notification) in
      self?.handle(notification: notification)
    }
  }

  // MARK: - Stop

  func stopEventProducing() {
    queue.async(execute: _stop)
  }

  private func _stop() {
    notificationObserver.map(notificationCenter.removeObserver(_:))
    notificationObserver = .none
  }

  // MARK: - Handle

  private func handle(notification: Notification) {
    queue.async { self._handle(notification: notification) }
  }

  private func _handle(notification: Notification) {
    guard
      let userInfo = notification.userInfo,
      let runningApplication = userInfo[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
      let launchedAppBundleID = runningApplication.bundleIdentifier
    else {
      return
    }

    delegate?.didProduceEvent(.didLaunchApp(bundleID: launchedAppBundleID))
  }
}
