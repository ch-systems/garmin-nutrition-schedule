# Garmin Cycling Nutrition and Hydration Data Fields

This repository contains three essential Garmin data fields designed to help cyclists manage their nutrition and hydration during rides:

- **Refuel Reminder**: Reminds you to eat every 30 minutes during your ride and keeps a running count of how many times you should have refueled by the current time. Count resets to 0 after a preset amount of pause or stop time.
- **Hydration Gauge**: Reports the amount of liquid that should be left in your bottle at any given time based on a preset time for when a full bottle should be consumed. Bottle amount resets to full after a preset amount of pause or stop time.
- **Nutrition Timekeeper**: A simple HH:mm:ss timer that begins when the activity starts and resets after a preset amount of pause or stop time.

## Motivation

These data fields were developed out of a personal need for better nutrition and hydration management during long cycling events. During a recent climbing event, I found myself too exhausted to perform simple arithmetic and keep track of when to refuel. These tools were created to alleviate that burden, allowing me to focus solely on my ride.

## Features

### Refuel Reminder
- Sends a reminder to refuel every set amount of minutes.
- Keeps a count of the refuels required by the current time.
- Resets the count after a set amount of minutes of paused/stopped time.
- The timer only counts when the activity is active.

### Hydration Gauge
- Updates every set amount of minutes to indicate how much liquid should remain.
- Assumes one bottle per set amount of minutes consumption rate.
- Resets after a set amount of minutes of paused/stopped time.
- Only updates when the activity is active.

### Nutrition Timekeeper
- Displays a timer in HH:mm:ss format.
- Starts counting at the beginning of the activity.
- Resets after a set amount of minutes of paused/stopped time.

## Installation

These data fields are available on the Garmin Connect IQ store. You can install them directly to your Garmin device from the following links:

- [Refuel Reminder on Connect IQ](https://apps.garmin.com/apps/8e23810f-a32d-44e2-b04e-d6c0029fcd2c)
- [Hydration Gauge on Connect IQ](https://apps.garmin.com/apps/c5d3dade-4a53-41a7-a7cd-5f18ccabb7d4)
- [Nutrition Timekeeper on Connect IQ](https://apps.garmin.com/apps/a06c1f20-975c-4480-a9a3-0bb60316c9f7)

Alternatively, you can clone this repository and use Garmin Express or a dev environment to install the data fields on your device.

## Usage

After installing the data fields, add them to your activity profile on your Garmin device. Configure your display settings to include the desired data fields:

1. Go to the activity settings on your Garmin device.
2. Select 'Data Screens'.
3. Add a new screen or edit an existing one to include Refuel Reminder, Hydration Gauge, and/or Nutrition Timekeeper.
4. Save your settings and start your activity.

## Acknowledgments

- Thanks to the Garmin developer community for their tools and resources.
- Special thanks to all athletes who inspired the creation of these data fields.
