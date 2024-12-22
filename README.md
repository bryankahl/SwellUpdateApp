# SwellUpdate App

This is an iOS application that provides surf forecast for surf spots around the world. Users can sign up and log in, view forecasts for nearly 6,000 spots via the Forecast Table View or Map View, navigate to any surf spot, and upload their videos and images of the live conditions to specific surf spots.

## Key Features

- **User Authentication**: Allows user to sign up and log in, Firebase Authentication was used. 
- **Surf Forecast**: View live surf conditions which includes the wave height, wave direction, and wave period for many of the worldwide surf spots.
- **Map View**: Uses MapKit to show the locations of all the surf spots with interactive map markers, to view surf forecasts or navigate to. Shows live user location.
- **Favorites View**: Users can save their favorite surf spots for quick access.
- **Detail View**: Shows detailed view when user clicks on a surf spot from the Forecast Table View or Map View, and shows the name, conditions, rating, and allows for media upload.
- **Media Upload**: Users can upload pictures and videos that they took live to the surf spot they are at.
- **Forecast Rating**: The app gives spots ratings based on the wave height, including: "Excellent", "Good", and "Poor".
- **Spot Data**: testSpots.json focuses on localized spots in New Jersey because of the API limitations. With upgraded API plan, surfspots.json can fully load and be used.  

## Details

- **Platform**: iOS
- **Language**: Swift
- **Frameworks**:
  - **UIKit**: For the user interface elements that are used including labels, table views, and view controllers.
  - **MapKit**: To display maps and annotations.
  - **CoreLocation**: For utilizing the geographic coordinates.
  - **Firebase Authentication**: For user sign up and log in
- **API**: Open Meteo Marine API
- **Databases**: Firebase Realtime Database and Firebase Storage
- **Data**: SurfSpotLocation, SurfForecast, and OpenMeteoResponse allow for JSON decoding. 

## Project Structure

- **Model-View-Controller (MVC)**: Clean code and app organization.
- **Singleton Service**: SurfSpotService deals with the API actions.
- **Data Handling**: Firebase for the real time updates and codeable for parsing through the JSON.

## Limitations

- **API Limitations**: Limited to free tier API constraints, which limits the number of surf spots displayed. Use testSpots.json instead of surfspots.json to test a smaller number of spots (New Jersey).
- **Media Uploads**: Uses Firebase Storage for images and videos. Needs changes to support larger files. 

- ## Usage
- Install Xcode
- Add the GoogleService-Info.plist file for the Firebase integration to work.
- Open SwellUpdate in Xcode Project
- Select a simulator and run!
