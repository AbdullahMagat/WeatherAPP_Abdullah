# WeatherAPP_Abdullah
Features of Weather App:
-app lets user to search for a city's weather in US by entering city and state name
-used combine to get notified when user entered both city and state name so get Weather button can be enabled
-Used MVVM design pattern
-app first makes an api call to get the lattitude and longitude data and then it makes another apicall to get the weather data
-in order to handle these sequent api calls I used combine and observables
-image loading and caching is also handled by the viewmodel so that will increase the image loading performance
-I added offline support using core data so when user launches the app it fetches the last searched city data without api call
