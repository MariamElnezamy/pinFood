# Rescounts iOS App

## Overview
The Rescounts iOS app allows a user to find a restaurant, make a reservation (either pickup or a table for a number of people), order items, add more items later, and ultimately pay/tip/review when they're done.

## Tech Overview
- written in Swift 4
- AlamoFire used for networking
- CocoaPods used for dependency management
  - Crashlytics for crash logs
  - Facebook SDKs for login
  - Google SDKs for login
- UI created programmatically
- Project config handled by .xcconfig files (CocoaPods setup customized to avoid xcconfig conflicts)

## Project Organization
The code is arranged into the following folders:

- Screens
  - These are the view controllers for each screen, as well as the custom UI that is specific to a certain screen
- Common UI
  - Custom views and controls which are used throughout the app, such as star ratings or Rescounts-styled buttons
- Data
  - Our data models, and the singleton managers which control access to the data
- Services
  - Our network calls. These classes generally all subclass BaseService, so this is a good place to set breakpoints if you're looking to understand how the app is communicating with the server.
- Extensions
  - A collection of extensions, some of which are Rescounts-specific (such as branded constants of UIColor and UIFont), while others are more for convenience (such as adding Closure support to UIControls)
- Misc
  - Everything else, such as the bridging header, constants, and some helper code.

## Building
After installing the pods, the project should compile for production as-is. If you'd like to change away from the production environment, look at the `setupEnvironmentToProd(Bool)` method in AppDelegate. Passing in false will run the app against the dev server.

## Startup Flow
1. When the app starts up for the first time, we take the user to a landing screen where they can either create an account (Rescounts, FB, or Google), or login to an existing account. We save the login token locally, so if the user has already logged in previous, we skip to step #2
1. The loading screen is where we setup all data for the user. We refresh the login token, fetch user details, setup location and notification permissions, fetch any open tables they're in the middle of, etc. If we find the user has an incomplete profile or the token refresh fails, we take them back to step #1
1. Once startup is complete, we take the user to the BrowseViewController where they can start looking at restaurants.