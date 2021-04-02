//
//  STPDownloadedFilesEventProducer.swift
//  SmartSuggestionsSample
//
//  Created by Vitalii Budnik on 4/2/21.
//  Copyright © 2021 Setapp Ltd. All rights reserved.
//

import Foundation

class STPDownloadedFilesEventProducer: STPEventProducer {
  var delegate: STPEventProducerDelegate?

  func startEventProducing() {
    queue.async(execute: _startEventProducing)
  }

  func stopEventProducing() {
    queue.async(execute: _stopEventProducing)
  }

  /// Working queue.
  private let queue: DispatchQueue
  /// FS monitoring queue.
  private let monitoringQueue: DispatchQueue

  /// A reference to the current file system events stream.
  private var currentStreamRef: FSEventStreamRef?

  init(
    queue: DispatchQueue = STPDispatchQueueFactory.shared.queue(label: "downloadedFilesMonitor"),
    monitoringQueue: DispatchQueue = STPDispatchQueueFactory.shared.queue(label: "downloadedFilesMonitor.monitoringQueue")
  )
  {
    self.queue = queue
    self.monitoringQueue = monitoringQueue
  }

  private func _startEventProducing() {
    guard currentStreamRef == .none else { return }

    var context = FSEventStreamContext(
      version: 0,
      info: nil,
      retain: nil,
      release: nil,
      copyDescription: nil
    )
    context.info = Unmanaged.passUnretained(self).toOpaque()

    let flags = UInt32(
      kFSEventStreamCreateFlagUseCFTypes |
        kFSEventStreamCreateFlagFileEvents |
        kFSEventStreamCreateFlagNoDefer |
        kFSEventStreamCreateFlagMarkSelf
    )

    let downloadsFolderPath = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0].path

    guard let streamRef = FSEventStreamCreate(
      kCFAllocatorDefault,
      Self.eventCallback,
      &context,
      [downloadsFolderPath] as CFArray,
      FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
      0.3,
      flags
    )
    else {
      return
    }

    FSEventStreamSetDispatchQueue(streamRef, self.monitoringQueue);
    FSEventStreamStart(streamRef)

    self.currentStreamRef = streamRef
  }

  private func _stopEventProducing() {
    guard let stream = currentStreamRef else { return }
    defer { currentStreamRef = nil }

    FSEventStreamStop(stream)
    FSEventStreamInvalidate(stream)
    FSEventStreamRelease(stream)
  }

  private static let eventCallback: FSEventStreamCallback = {
    (streamRef: ConstFSEventStreamRef,
     clientCallBackInfo: UnsafeMutableRawPointer?,
     numEvents: Int,
     eventPaths: UnsafeMutableRawPointer,
     eventFlags: UnsafePointer<FSEventStreamEventFlags>,
     eventIds: UnsafePointer<FSEventStreamEventId>) in

    let monitor: STPDownloadedFilesEventProducer = unsafeBitCast(
      clientCallBackInfo,
      to: STPDownloadedFilesEventProducer.self
    )

    guard monitor.currentStreamRef == streamRef else { return }

    monitor.handle(numEvents: numEvents,
                   eventPaths: eventPaths,
                   streamEventFlags: eventFlags,
                   eventIds: eventIds)
  }

  private func handle(
    numEvents: Int,
    eventPaths: UnsafeMutableRawPointer,
    streamEventFlags: UnsafePointer<FSEventStreamEventFlags>,
    eventIds: UnsafePointer<FSEventStreamEventId>
  )
  {
    guard let paths = unsafeBitCast(eventPaths, to: NSArray.self) as? [String] else { return }

    for index in 0..<numEvents {
      let currentFlags = streamEventFlags[index]

      // If this is file, and it was created.
      guard
        (Int(currentFlags) & kFSEventStreamEventFlagItemIsFile > 0) &&
          (Int(currentFlags) & kFSEventStreamEventFlagItemCreated > 0)
      else {
        return
      }
      let path = URL(fileURLWithPath: paths[index])

      queue.async {
        // Tell the delegate about new event.
        self.delegate?.didProduceEvent(.didDownloadFile(path: path))
      }
    }
  }
}
