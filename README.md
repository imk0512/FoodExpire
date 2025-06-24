# FoodExpire

SwiftUI app for managing food expiration dates using OCR.
The main screen allows registering a food item by taking a photo or selecting
one from the library. Text recognition automatically fills the food name and
expiration date which can be edited before saving to Firestore.

The app supports both Japanese and English localizations.

## Features
- Capture or select photos and recognize text using ML Kit OCR.
- Save food items with expiration dates to Firestore.
- List saved items sorted by expiration date.
- Send notifications when items are about to expire.
- Optional in-app purchase to remove banner ads.

## Setup
1. Open `Package.swift` with Xcode 15 or later.
2. Add your Firebase configuration file `GoogleService-Info.plist` under `Sources/FoodExpire/Resources/`.
3. Select the `FoodExpire` scheme and run on an iOS 17 simulator or device.

Firebase dependencies are resolved via Swift Package Manager. Firestore and ML Kit for text recognition are included.
