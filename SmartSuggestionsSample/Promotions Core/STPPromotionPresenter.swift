//
//  STPPromotionPresenter.swift
//  SmartSuggestionsSample
//
//  Created by Vitalii Budnik on 2/11/21.
//  Copyright © 2021 Setapp Ltd. All rights reserved.
//

import Foundation
import UserNotifications

/// A protocol describing an object capable of presenting application promotions.
protocol STPPromotionPresenter {
  /// Checks if the app can display application promotions.
  ///
  /// - Parameter callback: A callback to call when ability to present application promotions is
  ///   determined.
  ///
  ///     The callback takes one argument:
  ///
  ///       `canPresent` - A `Bool` variable having the `true` value if application promotion was
  ///       can be presented to the user, `false` - when app has no permission to display
  ///       application promotions.
  func canPresentApplicationPromotions(callback: @escaping (Bool) -> Void)

  /// Presents the application promotion as user notification.
  ///
  /// - Parameters:
  ///   - applicationPromotion: An application promotion to present.
  ///   - callback: A callback to call when user notification is presented or at least scheduled.
  ///
  ///     The callback takes one argument:
  ///
  ///       `wasPresented` - A `Bool` variable having the `true` value if application promotion was
  ///       successfully converted to the user notification and presented, `false` - when app has no
  ///       permission to display user notification as alert (hello Big Sur).
  func present(applicationPromotion: STPApplicationPromotion, callback: @escaping (Bool) -> Void)
}

/// Presents application promotions via User Notification Center.
class STPDefaultPromotionPresenter: STPPromotionPresenter {
  let userNotificationCenter: UNUserNotificationCenter

  init(userNotificationCenter: UNUserNotificationCenter = .current()) {
    self.userNotificationCenter = userNotificationCenter

    userNotificationCenter.getNotificationCategories { (currentCategories) in
      let predefinedCategories: [UNNotificationCategory] = [
        .applicationPromotion,
      ]
      let newCategories = currentCategories.union(predefinedCategories)
      userNotificationCenter.setNotificationCategories(newCategories)
    }
  }

  func canPresentApplicationPromotions(callback: @escaping (Bool) -> Void) {
    userNotificationCenter.canShowNotificationAlert(completionHandler: callback)
  }

  func present(applicationPromotion: STPApplicationPromotion, callback: @escaping (Bool) -> Void) {
    userNotificationCenter.canShowNotificationAlert { [weak self] (canShow) in
      guard canShow, let self = self else { return }

      self.scheduleNotification(for: applicationPromotion, callback: callback)
    }
  }
}

private extension STPDefaultPromotionPresenter {
  func scheduleNotification(
    for applicationPromotion: STPApplicationPromotion,
    callback: @escaping (Bool) -> Void
  )
  {
    let request = self.request(for: applicationPromotion)

    userNotificationCenter.add(request) { (error) in
      callback(error == nil)
    }
  }

  private func request(
    for applicationPromotion: STPApplicationPromotion
  ) -> UNNotificationRequest
  {
    UNNotificationRequest(
      identifier: UUID().uuidString,
      content: content(for: applicationPromotion),
      trigger: .none
    )
  }

  private func content(
    for applicationPromotion: STPApplicationPromotion
  ) -> UNNotificationContent
  {
    let content = UNMutableNotificationContent()

    content.categoryIdentifier = UNNotificationCategory.applicationPromotion.identifier

    content.title = applicationPromotion.title
    content.subtitle = applicationPromotion.subtitle
    content.body = applicationPromotion.body

    return content
  }
}
