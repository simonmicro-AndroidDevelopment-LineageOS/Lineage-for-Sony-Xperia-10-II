# LineageOS 17.1 for the Sony Xperia 10 II
_Please note this is currently for the dual-sim model ONLY. When you need a single-sim variant leave a comment, so we can work an that..._

```
/*
 * Disclaimer - your warranty may be void.
 * 
 * I'm not responsible for bricked devices, dead OTGs or you getting fired because the alarm app failed.
 * Please do some research if you have any concerns about features included in this ROM
 * before flashing it! YOU are choosing to make these modifications, and if
 * you point the finger at me for messing up your device, I will laugh at you.
 */
```

## Features
* OTA updates - always delayed for 1 day (to prevent broken rollouts); when you want it immediately, checkout my GitLab pipelines
* Increased volume steps to 25
* Over-provisioned system image (580MiB), to allow install of OpenGApps and other stuff
* Open Source (it is based on SODP, you can view all my patches and ci scripts [here](https://gitlab.simonmicro.de/android/lineage/lineage-pdx201) or [here](https://github.com/Simonmicro/Lineage-for-Sony-Xperia-10-II))
* Package signature spoofing (needed by MicroG)

## What does not work?
* Stock camera app with wide and zoom cameras, you may use [Open Camera](https://f-droid.org/en/packages/net.sourceforge.opencamera/) to circumvent that.
* Notification LED blinking - kernel driver bug ([see here](https://github.com/sonyxperiadev/bug_tracker/issues/577))
* WiFi Hotspot (native lib crashes, still investigating)
* _You tell me..._

## Download
There you have multiple options:
* To get the **complete** package (both including the `ota` and `img` parts; only needed for the initial setup) visit...
    * [AndroidFileHost](https://www.androidfilehost.com/?w=files&flid=319998)
    * [GitLab](https://gitlab.simonmicro.de/android/lineage/lineage-pdx201/-/pipelines) (make sure to download the artifacts from the `master` branch)
* To get ONLY the OTA package to update your system later on, visit (or open up the LineageOS Updater) [ota.simonmicro.de](https://ota.simonmicro.de/builds/full/) - please note that only the last recent 14 days are accessible there.

## Changelog
```
2020-12-18
Fixed cameras.

2020-11-27
Fixed ADB security.

2020-11-25
Added SELinux support.

2020-11-20
Added OpenGApps support.

2020-11-17
Initial release.
```

## How to install your system
The following guide assumes, you have setup `adb` and `fastboot` already (make sure to always use the latest version of the toolkit, otherwise you'll may get problems during flashing) - for that take a look into the internet. Also you should already downloaded the **complete** package from above!

1. Unlock the bootloader - a "how to" is [here](https://developer.sony.com/develop/open-devices/get-started/unlock-bootloader/)...
2. Download the oem binaries from [here](https://developer.sony.com/file/download/software-binaries-for-aosp-android-10-0-kernel-4-14-seine/), make sure to use _exactly_ that version!
3. Boot into the bootloader (hold "Volume up + Insert the USB cable" until led lights blue) and then update the oem partition:
```bash
fastboot flash oem_a [EXTRACTED_OEM_IMAGE_FILE]
fastboot flash oem_b [EXTRACTED_OEM_IMAGE_FILE]
```
4. Flash now the Lineage `recovery` partition as well as the `dtbo` partition (they are inside the `img` folder of the complete package):
```bash
fastboot flash recovery [EXTRACTED_RECOVERY_IMAGE_FILE]
fastboot flash dtbo [EXTRACTED_DTBO_IMAGE_FILE]
```
5. Disable the verity checks for now, as your new recovery violates the Sony verity profiles of the Stock ROM:
```bash
fastboot flash --disable-verity --disable-verification vbmeta vbmeta.img
fastboot flash --disable-verity --disable-verification vbmeta_system vbmeta_system.img
```
6. Okay, you are now ready to boot the first time into the Lineage recovery, unplug the phone NOW!
7. To boot into recovery: Hold "Volume down + Power" until it vibrates...
8. You should now be booted into the recovery. We now clean any old data from Sonys Stock ROM - this is just to make sure you have a _really_ clean install: Choose the "Factory reset" option.
9. The phone is now clean and ready to accept the new system. You now can either install just the OTA package and be done or flash every `.img` from the full package manually - the coice is
yours. When you plan to flash the images manually, make sure to include `boot`, `system`, `product`, `vendor`, `vbmeta_system`, as these are normally part of the OTA update (I extracted the
`payload.bin` to verify this!). For the latter approach you may orient yourself on my [flashall.sh](https://pastebin.com/36FZzwUP). I'll choose the simpler OTA-sideload approach for now.
10. Select "Apply update -> Apply from ADB" (now make sure the adb server runs as `root` - may use `adb kill-server && sudo adb start-server` to fix that) and execute (the OTA zip is inside the `ota` subdir):
```bash
adb sideload [OTA_SYSTEM_UPDATE_ZIP_FILENAME]
```
11. After installing the OTA, make sure to reboot your device to verify the update is indeed working. Also the update switches the slots, but the recovery needs to reboot to realize that - otherwise sideloading other stuff may won't work!

### Something went wrong - help!

#### (Step 7-8) When you now see a device corrupt error:
* Don't panic!
* You messed up the verity disable step from before - try again.
* Try to switch the current boot slot (get current `fastboot getvar current-slot` and set new `fastboot --set-active=`, you can choose between `a` and `b`) and retry disableing verity disable again!
* When your device fails to boot too many times (and crashes) the current slot could also get marked as corrupt. To reset that counter you'll need to reflash the `boot` partition - to see what is going on, try `fastboot getvar all` and look out for something like a `unbootable` flag.

#### (Step 9) When you get `Operation not permitted` during flashing
This is commonly caused by relocking and then reunlocking the bootloader (yay - buggy firmware). You'll need to relock, restore (and boot) the device with [Flashtool](http://flashtool.net/) using Sonys original ROM and start from fresh.

#### (Step 10) When you get the `kDownloadPayloadPubKeyVerificationError` error
Well, that's caused by using an other recovery than the provided one, as I use my own private keys to sign the build the recovery must also know them. Using an other recovery than the one from
the `img` folder of the complete package will most likely not include them (and when they do - I am in big trouble), and therefore fail. But you are in luck: It seems that the recovery writes
the data to the currently inactive slot and _then_ fails. You could simply switch the system slot like described above!

## Want to install Magisk?
Install the Magisk zip like the OTA system update by using `adb sideload [MAGISK_FILE_NAME]`.

## Want to install OpenGApps?
Make sure to use the `nano`-variant (or the even smaller `pico`), as the system partition is even with over-provisioning really small (as the installer extracts some more stuff on the first boot) - then install the OpenGApps zip like the OTA system update by using `adb sideload [OPENGAPPS_FILE_NAME]`.

## Credits
As much I would like, I can't do everything by myself. A huge thank you to...
* @MartinX3 for the used [local_manifests](https://github.com/MartinX3-AndroidDevelopment-LineageOS/local_manifests) and his [device tree](https://github.com/MartinX3-AndroidDevelopment-LineageOS/android_device_sony_pdx201) from his [LineageOS organization](https://github.com/MartinX3-AndroidDevelopment-LineageOS)
* ...the team behind @sonyxperiadev, for their great work (and their [kernel sources](https://github.com/sonyxperiadev/kernel))!





# Needed env vars for the CI - in case you want to run it yourself

* `PERSISTENT_DATA_STORAGE` -> path to a huge persistent drive (200GB at least)
* `BUILD_PRIVATE_KEYS` -> base64 encoded zip archive of the private keys for signing this build (represents `~/android-certs` from [here](https://wiki.lineageos.org/signing_builds.html))
* `DEPLOY_DIR` -> remote path for the [OTA api](https://github.com/julianxhokaxhiu/LineageOTA)
* `DEPLOY_HOST` -> remote SSH host for the api
* `SSH_PRIVATE_KEY` -> remote SSH key for the api

To generate `BUILD_PRIVATE_KEYS` execute (skip any password request)...
```bash
subject='/C=US/ST=California/L=Mountain View/O=Android/OU=Android/CN=Android/emailAddress=android@android.com'
mkdir ./PRIVATE_KEYS
for x in releasekey platform shared media networkstack testkey; do \
    ./development/tools/make_key ./PRIVATE_KEYS/$x "$subject"; \
done
zip -r PRIVATE_KEYS.zip PRIVATE_KEYS
base64 -w 0 PRIVATE_KEYS.zip > STORE_THIS_INTO_ENV_VAR_BUILD_PRIVATE_KEYS
rm -rfv PRIVATE_KEYS PRIVATE_KEYS.zip
```
