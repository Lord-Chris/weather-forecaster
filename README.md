# Weather Forecaster

This is a simple weather forecaster that uses the OpenWeatherMap API to get the weather forecast for a given city. The user can input the city name to search from a predefined list of cities. Clicking on a city will display the weather forecast for the next 5 days.

![Weather Forecaster](videos/Weather%20Forecaster.gif)

## Features

- **View Current Weather**: View the current weather for a given city, including minimum and maximum temperatures.
- **5-day forecast**: View the weather forecast for the next 5 days.

## Getting Started

### Prerequisites

- Ensure you have [Flutter](https://flutter.dev/docs/get-started/install) installed on your machine.
- You will need an API key from [OpenWeatherMap](https://openweathermap.org/api) to access the weather data.

### Steps

1. **Clone the Repository**

   First, clone this repository to your local machine using Git.

   ```bash
   git clone https://github.com/Lord-Chris/weather-forecaster.git
   cd weather-forecaster
   ```

2. **Install Dependencies**

   Navigate to the project directory and run the following command to install the necessary Flutter dependencies:

   ```bash
   flutter pub get
   ```

3. **Run the App**

   Ensure an emulator is running or a device is connected to your computer. You can check connected devices with:

   ```bash
   flutter devices
   ```

   Then, execute the following command to run the app:

   ```bash
   flutter run --dart-define=OPEN_WEATHER_API_KEY=${API_KEY} 
   ```

## Using the App

1. **Select a City**

   Click on the search bar to select a city from the list of predefined cities.

2. **View Weather Forecast**

   Click on a city to view the weather forecast for the next 5 days.

3. **Refresh Data**
   
   Pull down the screen to refresh the weather data.


## Running Tests

Execute the following command to run the tests:

```bash
flutter test

```

To generate a coverage report, run the following command:

```bash
flutter test --coverage
```

The coverage report will be generated in the `coverage` directory.

---
> Truth can only be found in one place: the code. <br/>
> -- Robert C. Martin

> ... and Assurance can be found in one place: the tests.<br>
> -- LordChris