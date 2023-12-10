import 'package:flutter/material.dart';

import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfig extends StatefulWidget {

  const RemoteConfig({super.key});

  @override
  State<RemoteConfig> createState() => _RemoteConfigState();
}

class _RemoteConfigState extends State<RemoteConfig> {

  final remoteConfig = FirebaseRemoteConfig.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  void _init() async {

    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await remoteConfig.setDefaults(const {
      "update_force": false,
      "version": "0.0.0",
    });

    remoteConfig.onConfigUpdated.listen((RemoteConfigUpdate event) async {
      await remoteConfig.activate();

      print("CAMBIOOO");
      print(event.updatedKeys);
    });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Remote Config"),
      ),
      body: Center(
        child: FutureBuilder(
          future: remoteConfig.fetchAndActivate(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    remoteConfig.getString("version"),
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    remoteConfig.getString("update_force"),
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    remoteConfig.lastFetchStatus.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    remoteConfig.lastFetchTime.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await remoteConfig.fetchAndActivate();
                      setState(() {});
                    },
                    child: const Text("Update"),
                  ),
                ],
              );
            }
            return const CircularProgressIndicator();
          },
        )
      ),
    );
  }
}
