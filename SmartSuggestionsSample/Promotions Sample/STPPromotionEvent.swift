//
//  STPPromotionEvent.swift
//  SmartSuggestionsSample
//
//  Created by Vitalii Budnik on 2/11/21.
//  Copyright © 2021 Setapp Ltd. All rights reserved.
//

import Foundation

/*
 Fell free to add new cases here.
 */

/// Setapp promotion events.
enum STPPromotionEvent: Hashable {
  /// An application did launch.
  case didLaunchApp(bundleID: String)
}
