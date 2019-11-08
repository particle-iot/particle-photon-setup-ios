<p align="center" >
<img src="particle-mark.png" alt="Particle" title="Particle">
</p>

# Particle Photon Setup library

### Introduction

The Particle Photon Setup library is meant for integrating the initial setup process of Particle devices (Photon, P0, P1) in your app. This library will enable you to easily invoke a standalone setup wizard UI for setting up internet-connected products powered by a Particle device (Photon, P0, P1). The setup UI can be easily customized by a customization proxy class, that includes: look & feel, colors, texts and fonts as well as custom brand logos and custom instructional video for your product. There are good defaults in place if you don’t set these properties, but you can override the look and feel as needed to suit the rest of your app.

The wireless setup process for the Photon uses very different underlying technology from the Core. Where the Core used TI SmartConfig, the Photon uses what we call “soft AP” — i.e.: the Photon advertises a Wi-Fi network, you join that network from your mobile app to exchange credentials, and then the Photon connects using the Wi-Fi credentials you supplied.

With the Photon Setup library, you make one simple call from your app, for example when the user hits a “Setup my device” button, and a whole series of screens then guide the user through the setup process. When the process finishes, the app user is back on the screen where she hit the “setup my device” button, and your code has been passed an instance of the device she just setup and claimed. iOS Photon Setup Library is implemented as an open-source Cocoapod static library and also as Carthage dynamic framework dependancy.


### Getting Started

- Refer to our [documentation](https://docs.particle.io/reference/ios/) for getting started guide, API reference, support & feedback links.
- Example app can be found [here](https://github.com/particle-iot/example-app-ios/).

Example app demonstrates invoking the setup wizard, customizing the UI and using the returned ParticleDevice instance once, as well as invoking Particle API functions via the Particle-SDK.
Contributions to the example apps are welcome by submitting pull requests.


### Communication

- If you **need help**, use [Our community website](http://community.particle.io)
- If you **found a bug**, _and can provide steps to reliably reproduce it_, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.


### Maintainers

- Raimundas Sakalauskas [Github](https://www.github.com/raimundassakalauskas)


### License

Particle iOS Photon Setup Library is available under the Apache License 2.0. See the [LICENSE file](https://github.com/particle-iot/particle-photon-setup-ios/blob/master/LICENSE) for more info.
