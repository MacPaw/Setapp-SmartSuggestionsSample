//
//  UNNotificationCategory.swift
//  SmartSuggestionsSample
//
//  Created by Vitalii Budnik on 2/11/21.
//  Copyright © 2021 Setapp Ltd. All rights reserved.
//

import Foundation
import UserNotifications

extension UNNotificationCategory {
  static let applicationPromotion = UNNotificationCategory(identifier: "application_promotions",
                                                           actions: [],
                                                           intentIdentifiers: [""])
}
