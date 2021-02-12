//
//  UNUserNotificationCenter.swift
//  SmartSuggestionsSample
//
//  Created by Vitalii Budnik on 2/11/21.
//  Copyright © 2021 Setapp Ltd. All rights reserved.
//

import Foundation
import UserNotifications

extension UNUserNotificationCenter {
  private func requestAuthorization(
    options: UNAuthorizationOptions = .applicationPromotionOptions,
    completion: @escaping (Bool) -> Void
  )
  {
    requestAuthorization(options: options) { (result, error) in
      completion(result)
    }
  }

  func canShowNotificationAlert(completionHandler: @escaping (Bool) -> Void) {
    getNotificationSettings { [self] (settings) in
      guard settings.authorizationStatus != .authorized && settings.authorizationStatus != .provisional else {
        return completionHandler(settings.alertSetting == .enabled)
      }
      if settings.authorizationStatus == .notDetermined {
        requestAuthorization { [self] wasGrantedPermissions in
          if wasGrantedPermissions {
            DispatchQueue.main.async { [self] in
              canShowNotificationAlert(completionHandler: completionHandler)
            }
          } else {
            completionHandler(false)
          }
        }
      } else {
        completionHandler(false)
      }
    }
  }
}
