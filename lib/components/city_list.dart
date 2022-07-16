import 'package:assincronismo_app/components/city_distance_card.dart';
import 'package:assincronismo_app/components/geolocation_error.dart';
import 'package:assincronismo_app/components/my_location.dart';
import 'package:assincronismo_app/models/city.dart';
import 'package:assincronismo_app/models/city_distance.dart';
import 'package:assincronismo_app/models/exceptions.dart';
import 'package:assincronismo_app/models/location.dart';
import 'package:assincronismo_app/resources/strings.dart';
import 'package:assincronismo_app/topics/future_builder/geolocation.dart';
import 'package:flutter/material.dart';
import 'package:assincronismo_app/utils/city_helper.dart' as city_helper;

class CityList extends StatefulWidget {
  final Geolocation geolocation;
  const CityList({Key? key, required this.geolocation}) : super(key: key);

  @override
  State<CityList> createState() => _CityListState();
}

class _CityListState extends State<CityList> with WidgetsBindingObserver {
  final cities = List<City>.from(city_helper.cities);
  bool requestedEnableGps = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.geolocation.listenToMyLocation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && requestedEnableGps) {
      final isGpsEnabled = await widget.geolocation.isGpsEnabled();
      if (isGpsEnabled) {
        widget.geolocation.closeMyLocationStream();
        setState(() {
          widget.geolocation.listenToMyLocation();
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.geolocation.closeMyLocationStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: StreamBuilder<Location>(
        stream: widget.geolocation.myLocationStream,
        builder: (context, snapshot) {
          debugPrint('Location: $snapshot');
          if (snapshot.connectionState == ConnectionState.active) {
            final myLocation = snapshot.data;
            if (myLocation != null) {
              final cityDistanceList = getCityDistanceList(myLocation);
              return Column(
                children: [
                  MyLocation(location: myLocation),
                  Expanded(
                    child: ListView.separated(
                      itemCount: cityDistanceList.length,
                      itemBuilder: (context, index) {
                        final cityDistance = cityDistanceList[index];
                        return CityDistanceCard(cityDistance: cityDistance);
                      },
                      separatorBuilder: (context, index) => const SizedBox(height: 5),
                    ),
                  ),
                ],
              );
            }
            if (snapshot.hasError) {
              if (snapshot.error is GpsDisabledException) {
                return GeolocationError(
                  icon: Icons.location_off,
                  title: Strings.errorGpsDisabledTitle,
                  description: Strings.errorGpsDisabledDescription,
                  actionText: Strings.enableLocationService,
                  action: () {
                    requestedEnableGps = true;
                    widget.geolocation.openLocationSettings();
                  },
                );
              }
            }
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  List<CityDistance> getCityDistanceList(Location myLocation) {
    return cities
        .map((city) => CityDistance(
            city,
            widget.geolocation.distanceBetween(
              myLocation,
              city.location,
            )))
        .toList()
      ..sort((cityA, cityB) => cityA.distance.compareTo(cityB.distance));
  }
}
