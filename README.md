## About this repository

This repo contains a sample code for Setapp's Smart Suggestion Initiative. 

To know more about the Initiative, see ["Smart suggestions"](https://docs.setapp.com/docs/smart-suggestions) in Setapp DevDocs. For technical implementation info, read the sections below.

## Writing the trigger code for smart suggestions

### About the sample (basic) code

**Why do we need a sample code?** If we asked every Setapp partner to provide us with an unstructured code, our team would not be able to review, process, and integrate it into Setapp. That's why we've created this public repository with a sample suggestion trigger, which your own triggers must conform to.

However (and it matters a lot for us!), we ask you not to stop on this implementation but go beyond and develop your own ideas and methods. We'll be happy to discuss any ideas with you.

**What's in the repo?** The sample is based on an imaginary app called AwesomeNotes; it encrypts all notes and provides a collaboration mode for users. We also assumed the app has 3 competitors. As app owners, we decided that the best way of promotion in Setapp would be to show a notification when users open the competitors' apps for 3 times.

That's why we’ve started with implementing an object conforming to the `STPEventProducer` protocol. In our case, it monitors which apps have been open, generates events that include the bundle ID of the app opened, and informs the delegate function about these apps.

Our next step was to implement the `STPEventProcessor` to process the events from the `Producer`. Following the promo logic, we allowed event processing only if the competitor apps had been open for at least 3 times.

Surely, you can change the logic in the `Producer` and the `Processor` files as you find necessary.

Your future working directory is `Promotions Sample`; we'll talk about it in the Implementation section below. Lastly, the `Promotions Core` directory should be used as a reference of the working principles, which smart suggestions are based on.

### Creating your implementation

**Resources to modify.** We encourage you to find more promotion possibilities for your app and provide new logic, triggers, sequences, events, producers, or processors — anything you find reasonable. The  files you'll be working on most often are grouped in the `Promotions Sample` directory:

- `STPPromotionEvent.swift`, where new events are to be added
- `STPLaunchedAppsEventProducer.swift` that defines the system events for monitoring
- `STPLaunchedAppsEventProcessor.swift` that processes events from the `Producer` to later pass them for display (on banners with suggestions)

**Execution.** The smart suggestions code is executed in the Setapp's helper tool and is not sandboxed.

**When are my triggers enabled?** Smart suggestions only work if your app has not been installed on a user's Mac. We check for the installation before executing the code and disable it once the app is installed.

**Which events can I monitor?** Apps being opened, files downloaded, devices connected via USB or Bluetooth, and many others. The only thing we require is to respect the users' privacy. That's why **you must not monitor**: user location, contacts, calendars, microphone, camera, and any input data.

**Am I limited to a single trigger per app, or can I provide more?** You can provide as many triggers as you want. However, please keep to our principle: suggestions must not be annoying.

**Can I update my suggestion code after submitting it to Setapp?**  Sure. Write new triggers, then submit them to us for the next round of review.
