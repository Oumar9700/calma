import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/extensions/build_context_ext.dart';
import '../models/pickup_location.dart';
import '../services/address_service.dart';

class PickupAddressField extends StatefulWidget {
  final TextEditingController controller;
  final AddressService addressService;
  final ValueChanged<PickupLocation>? onLocationDetected;

  const PickupAddressField({
    super.key,
    required this.controller,
    required this.addressService,
    this.onLocationDetected,
  });

  @override
  State<PickupAddressField> createState() => _PickupAddressFieldState();
}

class _PickupAddressFieldState extends State<PickupAddressField> {
  bool _detecting = false;
  String? _error;

  Future<void> _detect() async {
    setState(() {
      _detecting = true;
      _error = null;
    });
    try {
      final loc = await widget.addressService.detectCurrentLocation();
      if (!mounted) return;
      if (loc == null) {
        setState(() => _error = 'Localisation indisponible. Activez le GPS et autorisez l\'accès.');
      } else {
        widget.controller.text = loc.address;
        widget.onLocationDetected?.call(loc);
      }
    } catch (e, st) {
      debugPrint('[PickupAddressField] Erreur détection : $e');
      debugPrint(st.toString());
      if (!mounted) return;
      setState(() => _error = 'Erreur : ${e.toString().split('\n').first}');
    } finally {
      if (mounted) setState(() => _detecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                decoration: InputDecoration(
                  labelText: 'Adresse de retrait *',
                  hintText: 'Ex : 15 rue de Bréquigny, 35000 Rennes',
                  filled: true,
                  fillColor: context.colorSurfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: context.colorPrimary),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 14.h),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Adresse requise' : null,
                textInputAction: TextInputAction.next,
              ),
            ),
            SizedBox(width: 10.w),
            // Bouton GPS
            SizedBox(
              height: 52.h,
              width: 52.h,
              child: _detecting
                  ? Container(
                      decoration: BoxDecoration(
                        color: context.colorSurfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Center(
                        child: SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.colorPrimary,
                          ),
                        ),
                      ),
                    )
                  : Tooltip(
                      message: 'Utiliser ma position actuelle',
                      child: Material(
                        color: context.colorPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.r),
                        child: InkWell(
                          onTap: _detect,
                          borderRadius: BorderRadius.circular(10.r),
                          child: Icon(
                            Icons.my_location_outlined,
                            size: 22.w,
                            color: context.colorPrimary,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
        if (_error != null) ...[
          SizedBox(height: 6.h),
          Text(
            _error!,
            style: TextStyle(
              fontSize: 11.sp,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
        SizedBox(height: 6.h),
        Text(
          'Cette adresse sera visible par les clients pour récupérer leur commande.',
          style: TextStyle(
            fontSize: 11.sp,
            color: context.colorOnSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
