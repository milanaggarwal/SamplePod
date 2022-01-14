# Camera Core

The `CameraCore` framework written purely in swift, contains all of the business logic and standard interface elements for the camera which powers the Flipgrid iOS App as well as numerous other apps at Microsoft. It does not contain any of the Flipgrid-specific functionality or the Flipgrid-specific configuration details.

## Requirements

* iOS 13.0+
* Swift 5.0+ (XCode 13.0)
* Your XCode should be authenticated with github and FG SSO should be enabled

### Installation

### Swift Package Manager

* File > Add Packages > Select github and search for package - https://github.com/flipgrid/fg_camera_core_ios.git
* Select the core package 
* Select "Up to Next Major" with "0.0.1"
* Click on Add package button to add the package to your project
* Select the libraries in the prompt you want to add in your target

There are three type of libraries under this package:
- The Camera Libraries
- The Effect Library
- Interface (UI) Library

## The Camera Libraries

* **Camera Common** – A framework that contains the public model types, protocols, and other useful shared code. This will be a dependency of Capture, Transform, Assemble and Control so that they can interoperate without having hard dependencies.
* **Camera IO** – AV capture / recording framework.
* **Camera Transform** - Visual effects framework.
* **Camera Assemble** - Multi-clip editing and sequencing framework.

### Camera Common

Common is simply a collection of model objects and protocols that are used by the various functional frameworks. By centralizing them in this framework, the Capture, Transform, Assemble and Control frameworks will know how to communicate without having any direct dependencies on each other. This will allow us to achieve our vision of a modular system where an integrator can easily adopt only the parts of the framework their application requires.

### Camera IO

This framework will encapsulate the AVFoundation functionality: device discovery, video/audio capture and video writing. With this functionality split off into its own framework, it should be much simpler to reason about how to do implement the evolving media requirements such as audio-only recording.

This framework will provide a live preview view, but will not provide any additional interface or control elements. This will allow clients to quickly get video capture working, while providing their own UI.

This framework will also handle all file I/O within the app, managing multiple working directories.

**Goals**

* Make it simple to set up and configure for common use cases:
    * Video + audio
    * Video only
    * Audio only
* Provide hooks for adding in metadata generation to be used by Transform. Some examples might include:
    1. Detected faces.
    2. Current audio histogram.

**Future Feature Ideas:**

* Ability to specify a destination for video other than writing to a file. This could help make the framework compatible with Stream and other providers not interested in recording to disk.
* Ability to add user-specified audio tracks during recording, allowing users to add background music, sound effects, narration, etc. to the videos.

### Camera Transform

This framework provides transformation effects on video or still images. This includes the current functionality around filters, boards, stickers, etc. Transformations of the input will be conceptually managed through layers. Each layer will contribute some transformation, be it applying a filter effect or overlaying a bitmap.

The layers will be iterated using a 2-phase Update/Render cycle.

* **Update Phase** - The layer will be presented with metadata like the rendering area and device orientation as well as a general purpose dictionary that can be used to provide arbitrary content such as the locations of detected faces, or the current histogram of the audio channel. This allows the layer to perform longer-running setup computations, which decouples it from the rendering frame rate.
* **Render Phase** - The layer will be presented with a CIImage representing the content produced by "lower" layers as well as information about the rendering size and device orientation. The layer should quickly apply its transformation and reply with a CIImage of its own. If the layer fails for any reason during this step, it should return a `nil` value which will cause it to be skipped for the current rendering pass.

The idea between this 2-phase approach is that the update cycle for a layer can potentially run at a lower frequency than the render cycle, preventing layers with complex calculation requirements from slowing down the app's frame rate.

**Goals:**

* Move to a 100% GPU-accelerated Core Image rendering pipeline that eliminates the use of snapshotting APIs and other "special case" rendering techniques in favor of a standardized system.
* Provide easy hooks for a UI (be it ours or a 3rd party one) to interact with and configure the individual layers.
* Make it easy for 3rd parties to develop their own layers, including populating their own information into the feature dictionary which is passed to the layers during the Update phase.

### Camera Assemble

This framework encapsulates the powerful clip editing and sequencing present in the current app. I'm not quite as familiar with the editing functionality, so there may be omissions in this first revision. Generally, this framework will be able to:

* Play clips sequentially.
* Reorder clips.
* Mirror & Rotate clips.
* Trim clips.
* Split clips.
* Delete clips.
* Export current video to camera roll.


## The Effect Library

This is the modular collection of effects provided out of the box. By default, it will provide the UX and UI components that matches the new Flipgrid UX.

* **EffectBitmapOverlay** - A transform effect implementation to add a CIImage on buffer as an effect 
* **EffectBoard** - A type of EffectBitmap which enables user to add board effects to the camera buffer
* **EffectCommon** - Contains defination for common protocols and ui components for different effects
* **EffectFilter** - A transform effect implementation to add a CIFilter on buffer as an effect
* **EffectFrame** - A type of EffectBitmap which enables user to add a frame effect to the camera buffer
* **EffectPen** - A type of EffectBitmap which enables user to draw using pen tool on the camera buffer
* **EffectPhoto** - A type of EffectBitmap which enables user to add a photo from user library to the camera buffer
* **EffectSticker** - A type of EffectBitmap which enables user to add an available sticker bitmap to the camera buffer
* **EffectText** - A type of EffectBitmap which enables user to add customised text as a sticker to the camera buffer

**Goals:**

* Provide an easy way to integrate existing Flipgrid effects in a generic way, removing all dependency to Flipgrid APIs.
* Provide extensibility to allow 3rd party define their own set of effects and its implementations.

## Interface (UI) Library

This is the modular, configurable interface for the Capture, Transform, and Assemble frameworks. By default, it will provide the UI components that matches the new Flipgrid UX.

* **InterfaceCommon** - Contains common interface components 
* **InterfaceEdit** - Contains interface components required to setup the edit & review screen
* **InterfaceRecord** - Contains interface components required to setup the record screen
* **InterfaceSelfie** - Contains interface components required to setup the selfie capture screen

**Goals:**

* Provide an easy way to configure features/controls on and off.
* Provide extensibility to allow 3rd party Transform layers to be represented and configured within the interface.

