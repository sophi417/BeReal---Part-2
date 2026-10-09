# Project 3 - *BeReal*

Submitted by: **Sophia Sartor**

**BeReal** is an app that lets users take a photo with their camera and share it with a time and location. You can't see other users' photos until you post your own.

Time spent: **6** hours spent in total

## Required Features

The following **required** functionality is completed:

- [x] User can launch camera to take photo instead of photo library
  - [ ] Users without iPhones to demo this feature can manually add unique photos to their simulator’s Photos app
- [x] Posts have a time and location attached to them
- [x] Users are not able to see other users’ photos until they upload their own.

The following **optional** features are implemented:

- [ ] Posts have a comment section, which displays the commenter’s username and comment context
- [ ] User receives notification when it is time to post

The following **additional** features are implemented:

- [x] Photos from other users are blurred until you post instead of being hidden
- [x] Camera photos use the phone's current location, library photos use the location saved in the photo
- [x] Feed shows the place name (city, country) along with the time
- [x] Pull to refresh and infinite scroll (within the last 24 hours)

## Video Walkthrough

<div>
    https://youtube.com/shorts/13e7vA6yPsY
</div>

## Notes

- Had two copies of the project open by mistake (the lab and BeReal), so some changes went into the wrong one.
- Running on my iPhone needed a new bundle identifier and trusting the developer certificate on the phone.
- The app crashed when opening the camera until I added the camera permission in Info.plist.
- Camera photos don't have location saved in them, so I used CLLocationManager to get the current location.

## License

    Copyright 2026 Sophia Sartor

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
