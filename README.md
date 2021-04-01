# capacitor-mapbox-navigation

## 1. Add iOS platform to current project
```
npx cap add ios
```

## 2. Install plugin from bitbucket
```
npm install 'plugin-url'
```
You can get "plugin-url" from [here](https://absurd.tech/private-bitbucket-repositories-in-package-json/)

## 3. Sync project
```
npx cap sync
```

## 4. Apis
### - Load Moabox Navigation
```
import { Plugins } from '@capacitor/core';
const { CapacitorMapboxNavigation } = Plugins;

// Call this function when you are going to show mapbox navigation
CapacitorMapboxNavigation.show({
    routes: [
        {latitude: 37.77440680146262, longtitude: -122.43539772352648},
        {latitude: 37.76556957793795, longtitude: -122.42409811526268},
    ]
}).then(() => {
    console.log("Mapbox is loaded")
});
```

### - Listen location history
```
window.addEventListener("location_updated", callback);
```


### - Get location history({lastLocation, locationHistory})
```
CapacitorMapboxNavigation.history()
```


routes: position list of route. First element of array is starting point and last element of array is target point.

## 4. Run iOS project.
```
ionic capacitor run ios -l --external
```