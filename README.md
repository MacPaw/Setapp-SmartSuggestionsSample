## About this repository

With smart suggestions, Setapp gives personalized recommendations to its users. For example, when a MacBook is unplugged from a power outlet, Setapp suggests an app that optimizes power consumption or battery usage.

This repository was created to help developers create smart suggestions for their apps in Setapp. The repo contains the required classes, an example of a smart suggestion trigger implementation, and an example of a pull request with such a trigger. 

This document is purely technical; for a wider smart suggestions overview and the business-related info, see ["Smart suggestions" on Setapp DevDoc](https://docs.setapp.com/docs/smart-suggestions).

## Why follow the protocols of this repository?

1. When writing triggers using our classes, you don't have to invent own code structure, so, hopefully, you save some time.
2. Common protocols is the only way for the Setapp Review Team to quickly review your code and integrate it into the Setapp codebase. 

However (and it matters a lot for us!), we ask you not to stop on our proposed implementations but go beyond and propose new ideas. We'll be happy to discuss them with you!

## Glossary

**Smart suggestion trigger** is a code that allows the Setapp desktop app to show a recommendation to a Setapp user.

Your code must conform to the `STPEventProducer` and the `STPEventProcessor` protocols, declared in the Promotions Core directory of this repository.

**App promotion** (or **app recommendation**), in the context of this doc, is a fact of presenting a recommendation of an app to a Setapp member. The display of any app recommendation is based on the logic, specified in its trigger. 

From a user's perspective, a recommendation can be either a push notification (displayed via macOS's User Notification Center) or a section on the page of the Setapp desktop app. Any recommendation includes a promotional text and a URI that instantly redirects a Setapp user to an app's page in the Setapp desktop app.

**Promotion event** is a basic entity of smart suggestions: used as a criteria of app promotion, it is produced on the basis of system events that take place on a Setapp user's Mac.

## Core logic

The smart suggestions code is executed in the Setapp's helper tool and in a non-sandboxed environment.

The objects to be used for smart suggestion triggers are in the Promotions Core directory of this repository. Let's discuss them.

### EventProducer (conforms to the [`STPEventProducer`](SmartSuggestionsSample/Promotions%20Core/STPEventProducer.swift) protocol)

The STPEventProducer protocol describes an object that monitors system events, produces a promotion event (`STPPromotionEvent`), and delegates event processing to another object (in our case, to `STPEventProcessor` via `STPEventController`).

The Producer object creates events without limitations and filters. For example, while monitoring app launches, a Producer reports every launch of every app in a system to a delegate. 

We recommend limiting a Producer to events of one type (e.g. app launched, file created, etc.) and avoid producing mixed events. This approach helps to work with **a single instance** of a Producer, making our implementations more modular and flexible.

### EventProcessor (conforms to the [`STPEventProcessor`](SmartSuggestionsSample/Promotions%20Core/STPEventProcessor.swift) protocol)

The STPEventProcessor protocol describes an object that processes promotional events: counts them, analyses their current state, and applies filters. The purpose of processing is to separate the events, required for a particular promo scenario, and to mark the separated events as "valid" for a recommendation. 

Example: for recommending a media player app, a trigger could require the events of saving certain types of media files to the user's Downloads directory. Another trigger variant could be based on opening apps with a similar functionality as the app we're trying to promote.

## Service objects

These protocols are mentioned in the repository for the reference purposes — to let you know how the entire smart suggestions system works in Setapp. You should not change the implementation of the service functions, mentioned below, for your smart suggestions.

### [STPPromotionPresenter](SmartSuggestionsSample/Promotions%20Core/STPPromotionPresenter.swift)

This protocol describes an object with a means to present recommendations.

### [STPEventController](SmartSuggestionsSample/Promotions%20Core/STPEventController.swift)

This object is a delegate for the Producer class. The Controller receives promotion events from the Producer, passes them to the Processor, and redirects "the chosen" events to `STPPromotionPresenter.swift` — once the Processor marks these events as valid.

### [STPApplicationPromotion](SmartSuggestionsSample/Promotions%20Core/STPApplicationPromotion.swift)

This object contains the texts, used for app suggestions — title, subtitle, and body.

## Example of trigger implementation

An example trigger, located in the Promotions Sample directory of this repo, is based on an imaginary app called AwesomeNotes; it encrypts all notes and provides a collaboration mode for users. 

We assumed that the app has 3 competitors in the Setapp suite. We decided to promote the app by showing a notification when a user opens any (or all) competitors' apps for 3 times.

First, we've implemented a `STPEventProducer` object that: 

1. Monitors all apps being opened on a Mac
2. Generates promotion events that include the bundle ID of the app opened
3. Triggers the delegate function (`STPEventController`)

Our next step was to implement an `STPEventProcessor`. Following our promo logic, the Processor marks an event as a trigger for presenting a promotion if the event designates the 3rd launch of a competitor app.

According to the general smart suggestion logic, the Controller checks any event, created by the EventProducer, to find out if an event can be treated as a trigger for presenting a promotion. The check is done by calling the Processor's `process(event:callback:)` method. Once an event is recognized as a trigger, the Controller creates an instance of the `STPApplicationPromotion` struct and passes it further to `STPPromotionPresenter`. As a final result, Setapp recommends the app (in our case, AwsomeNotes) to a user.

You may choose to extend this sample implementation for your smart suggestion. However, we encourage you to find more promotion possibilities for your app and provide new logic, sequences, events, producers, or processors — anything you find reasonable.

## What can Setapp monitor for smart suggestions?

On a member's Mac, the Setapp desktop app monitors these resources:

- Files in the Downloads directory, created since the last macOS launch. Setapp can match the file types with the apps from the Setapp suite
- App launches (not processes)
- WiFi-related operations: network change, signal strength, type of connection (cellular or static)
- Power Source monitor (whether the power adapter is connected)
- Pasteboard monitor (what kind of data has been added to pasteboard)
- USB device monitor (whether there's a cable connection to an iOS device)

Please note: we respect the users' privacy. That's why you **must not** monitor: user location, contacts, calendars, microphone, camera, and any input data (beyond the pasteboard).

## My code is ready. What do I do next?

**How to submit a trigger to Setapp?** Please see [this section](https://docs.setapp.com/docs/smart-suggestions#submit-your-suggestion-code) on Setapp DevDocs. 

**When are my triggers enabled?** Smart suggestions only work if your app has not been installed on a user's Mac. We check for the installation before executing the code and disable it once the app is installed.

**Am I limited to a single trigger per app, or can I provide more?** You can provide as many triggers as you want. However, please keep to our principle: suggestions must not be annoying.

**Can I update my suggestion code after submitting it to Setapp?** Sure. Write new triggers, then submit them to us for the next round of review.

---
