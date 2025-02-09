import 'package:flutter/material.dart';
import 'package:friend_private/backend/schema/bt_device.dart';
import 'package:friend_private/pages/home/device.dart';
import 'package:friend_private/pages/home/firmware_mixin.dart';
import 'package:gradient_borders/gradient_borders.dart';

class FirmwareUpdate extends StatefulWidget {
  final DeviceInfo deviceInfo;
  final BTDeviceStruct? device;
  const FirmwareUpdate({super.key, required this.deviceInfo, this.device});

  @override
  State<FirmwareUpdate> createState() => _FirmwareUpdateState();
}

class _FirmwareUpdateState extends State<FirmwareUpdate> with FirmwareMixin {
  bool shouldUpdate = false;
  String updateMessage = '';
  bool isLoading = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        isLoading = true;
      });
      await getLatestVersion();
      var (a, b) = await shouldUpdateFirmware(widget.deviceInfo.firmwareRevision);
      setState(() {
        shouldUpdate = b;
        updateMessage = a;
        isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isDownloading && !isInstalling,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        appBar: AppBar(
          title: const Text('Firmware Update'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Center(
          child: isLoading
              ? const CircularProgressIndicator(
                  color: Colors.white,
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(14.0, 0, 14, 14),
                  child: isDownloading || isInstalling
                      ? Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 60),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(isDownloading
                                  ? 'Downloading Firmware $downloadProgress%'
                                  : 'Installing Firmware $installProgress%'),
                              const SizedBox(height: 10),
                              LinearProgressIndicator(
                                value: (isInstalling ? installProgress : downloadProgress) / 100,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                backgroundColor: Colors.grey[800],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Please do not close the app or turn off the device',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        )
                      : isInstalled
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Firmware Updated Successfully'),
                                SizedBox(height: 10),
                                Text(
                                  'Please close the app and turn off and turn on the Friend device to complete the update',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Current Firmware: ${widget.deviceInfo.firmwareRevision}'),
                                Text('Latest Firmware: ${latestFirmwareDetails['version']}'),
                                const SizedBox(height: 10),
                                Text(
                                  updateMessage,
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                shouldUpdate
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                        decoration: BoxDecoration(
                                          border: const GradientBoxBorder(
                                            gradient: LinearGradient(colors: [
                                              Color.fromARGB(127, 208, 208, 208),
                                              Color.fromARGB(127, 188, 99, 121),
                                              Color.fromARGB(127, 86, 101, 182),
                                              Color.fromARGB(127, 126, 190, 236)
                                            ]),
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: TextButton(
                                          onPressed: () async {
                                            await downloadFirmware();
                                            await startDfu(widget.device!);
                                          },
                                          child: const Text(
                                            "Download Firmware",
                                            style: TextStyle(color: Colors.white, fontSize: 16),
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                ),
        ),
      ),
    );
  }
}
