import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../models/pickup_location.dart';

abstract class AddressService {
  Future<PickupLocation?> detectCurrentLocation();

  // TODO(google-places): Future<List<String>> autocomplete(String query);
  // Pour activer la saisie intelligente d'adresses via Google Places API,
  // implémenter GooglePlacesAddressService avec le package google_places_flutter
  // et l'enregistrer à la place de GpsAddressService dans injection_container.dart.
}

class GpsAddressService implements AddressService {
  @override
  Future<PickupLocation?> detectCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('[GPS] Service de localisation désactivé');
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    debugPrint('[GPS] Permission initiale : $permission');

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      debugPrint('[GPS] Permission après demande : $permission');
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) {
      debugPrint('[GPS] Permission refusée définitivement');
      return null;
    }

    debugPrint('[GPS] Tentative getLastKnownPosition...');
    Position? position;
    try {
      position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        debugPrint('[GPS] Dernière position connue : ${position.latitude}, ${position.longitude}');
      }
    } catch (e) {
      debugPrint('[GPS] getLastKnownPosition échoué : $e');
    }

    if (position == null) {
      debugPrint('[GPS] Récupération de la position courante...');
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 20),
          ),
        );
        debugPrint('[GPS] Position courante : ${position.latitude}, ${position.longitude}');
      } on PlatformException catch (e) {
        debugPrint('[GPS] PlatformException : code=${e.code}, message=${e.message}');
        rethrow;
      } on LocationServiceDisabledException {
        debugPrint('[GPS] Service désactivé pendant la requête');
        return null;
      }
    }

    // Géocodage inverse — optionnel : si ça échoue on renvoie quand même les coords
    final fallbackAddress =
        '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 8));

      if (placemarks.isEmpty) {
        debugPrint('[GPS] Géocodage : aucun résultat, fallback coords');
        return PickupLocation(
          address: fallbackAddress,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }

      final p = placemarks.first;
      debugPrint('[GPS] Placemark : street=${p.street}, postal=${p.postalCode}, city=${p.locality}');

      final parts = <String>[
        if (p.street?.isNotEmpty == true) p.street!,
        if (p.postalCode?.isNotEmpty == true) p.postalCode!,
        if (p.locality?.isNotEmpty == true) p.locality!,
      ];
      final address =
          parts.isNotEmpty ? parts.join(', ') : fallbackAddress;

      return PickupLocation(
        address: address,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      // Le géocodage a échoué (réseau, Google Play Services) mais on a les coords
      debugPrint('[GPS] Géocodage échoué ($e), utilisation des coordonnées');
      return PickupLocation(
        address: fallbackAddress,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    }
  }
}
