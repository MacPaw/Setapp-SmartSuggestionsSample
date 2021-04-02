//
//  STPEventControllersBuilder.swift
//  SmartSuggestionsSample
//
//  Created by Vitalii Budnik on 4/2/21.
//  Copyright © 2021 Setapp Ltd. All rights reserved.
//

import Foundation

class STPEventControllersBuilder {

  func launchEventsController() -> STPEventController {
    let processor = STPLaunchedAppsEventProcessor {
      let competitorsBundleIDs: [String] = [
        "com.apple.Notes",
        "com.box.box-notes",
        "net.shinyfrog.bear",
      ]

      return competitorsBundleIDs.map(STPPromotionEvent.didLaunchApp).contains($0)
    }

    let launchEventsController = STPEventController(
      producer: STPLaunchedAppsEventProducer(),
      processor: processor,
      presenter: STPDefaultPromotionPresenter()
    ) { _ in
      // Q: Will promotion texts be used for my app promotion?
      // A: If we like it - it will be used.

      STPApplicationPromotion(title: "Tired of boring notes apps?",
                              subtitle: "Try AwesomeNotes. It's in Setapp!",
                              body: "Encrypted 😱 notes with collaboration support 👍.")
      
    }

    return launchEventsController
  }

  func downloadedFilesEventsController() -> STPEventController {
    let producer = STPDownloadedFilesEventProducer()
    let processor = STPDownloadedFilesEventProcessor(
      filter: { url in url.pathExtension.lowercased() == "rar" }
    )

    let controller = STPEventController(
      producer: producer,
      processor: processor,
      presenter: STPDefaultPromotionPresenter()
    ) { event in
      // Q: Will promotion texts be used for my app promotion?
      // A: If we like it - it will be used.

      STPApplicationPromotion(title: "Can't unrar?",
                              subtitle: "Try AwesomeRar. It's in Setapp!",
                              body: "Unpack all kinds of archive with a click!")
    }

    return controller
  }
}
