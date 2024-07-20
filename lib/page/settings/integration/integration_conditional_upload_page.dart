import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:scrobblium/service/method_channel_service.dart';

class IntegrationConditionalUploadPage extends StatefulWidget {
  const IntegrationConditionalUploadPage({super.key});

  @override
  State<IntegrationConditionalUploadPage> createState() => _IntegrationConditionalUploadPageState();
}

class _IntegrationConditionalUploadPageState extends State<IntegrationConditionalUploadPage> {
  @override
  Widget build(BuildContext context) {
    return SettingsScreen(
      title: "Conditional Upload",
      children: [
        enableConditionalUpload()
      ],
    );
  }
  Widget enableConditionalUpload() {
    return SettingsGroup(title: "Enable", children: [
      SwitchSettingsTile(
        // topPadding: 0,
        title: "Enable Conditional Upload",
        defaultValue: false,
        settingKey: "enable-conditional-upload",
        // childrenPadding: EdgeInsets.zero,
        childrenIfEnabled: [
          SettingsGroup(title: "Settings", children: [
              updateRate(),
              conditionCheck()
            ],
          ),
          SettingsGroup(title: "Conditions", children: [
            networkModeCondition(),
            // wlanSSIDCondition(), //TODO: Revisit this. Currently i just saw that you need location access to get the ssid. Why the hell
            batteryChargingCondition()
          ])
        ],
      )
    ]);
  }
  Widget updateRate() {
    return const TextInputSettingsTile(
      // topPadding: 0,
      title: "Update Rate",
      initialValue: "60",
      settingKey: "update-rate",
      unit: "min",
    );
  }
  Widget networkModeCondition() {
    return DropDownSettingsTile(
        title: "Network Mode",
        settingKey: "condition-network-mode",
        selected: "wlan",
        onChange: (p0) => setState(() {}),
        values: const <String, String>{
          "wlan": 'WLAN',
          "mobile": 'Mobile',
          "both": 'Both',
        },
    );
  }
  // Widget wlanSSIDCondition() {
  //   return Visibility(
  //     visible: SettingsUtil.getValueString("condition-network-mode", "wlan") == "wlan",
  //       child: TextInputSettingsTile(
  //         topPadding: 0,
  //         title: "WLAN SSID",
  //         settingKey: 'condition-wlan-ssid',
  //         initialValue: "any",
  //       ));
  // }
  Widget batteryChargingCondition() {
    return const SwitchSettingsTile(
        title: "Battery Charging",
        settingKey: "condition-battery-charging",
        defaultValue: false,
    );
  }

  Widget conditionCheck() {
    return FutureBuilder(future: MethodChannelService.callFunction(CHECK_CONDITIONAL_UPLOAD), builder: (context, snapshot) {
      return SimpleSettingsTile(
        title: "Condition met",
        subtitle: snapshot.hasData ? snapshot.data?.getDataAsString() : "No data yet",
        onTap: () => setState(() {}),
      );
    });
  }
}
