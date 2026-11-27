import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';
import 'package:serba_jaya_mobile/core/location/app_google_map.dart';
import 'package:serba_jaya_mobile/core/location/location_models.dart';
import 'package:serba_jaya_mobile/core/location/location_providers.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/session_controller.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/widgets/auth_action_button.dart';
import 'package:serba_jaya_mobile/features/profile/presentation/profile_components.dart';
import 'package:serba_jaya_mobile/features/profile/presentation/profile_field.dart';
import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';
import 'package:serba_jaya_mobile/shared/motion/app_overlays.dart';

enum AddressField {
  label,
  recipient,
  phone,
  province,
  city,
  district,
  village,
  postalCode,
  details,
  note,
}

final class ProfileAddress {
  ProfileAddress(
    Map<AddressField, String> fields, {
    required this.primary,
    this.location,
  }) : fields = Map.unmodifiable(fields);

  final Map<AddressField, String> fields;
  final bool primary;
  final LocationAddress? location;

  String operator [](AddressField field) => fields[field] ?? '';
  ProfileAddress withPrimary(bool value) =>
      ProfileAddress(fields, primary: value, location: location);
}

final profileAddressesProvider =
    NotifierProvider<ProfileAddresses, Map<int, ProfileAddress>>(
      ProfileAddresses.new,
    );

class ProfileAddresses extends Notifier<Map<int, ProfileAddress>> {
  int _nextId = 0;

  @override
  Map<int, ProfileAddress> build() {
    ref.watch(sessionProvider);
    return const {};
  }

  void save(int? id, ProfileAddress address) {
    final key = id ?? _nextId++;
    final makePrimary = address.primary || state.isEmpty;
    state = _ensurePrimary({
      for (final entry in state.entries)
        entry.key: makePrimary ? entry.value.withPrimary(false) : entry.value,
      key: address.withPrimary(makePrimary),
    });
  }

  void remove(int id) => state = _ensurePrimary({...state}..remove(id));

  Map<int, ProfileAddress> _ensurePrimary(Map<int, ProfileAddress> data) {
    if (data.isNotEmpty && !data.values.any((address) => address.primary)) {
      final first = data.entries.first;
      data[first.key] = first.value.withPrimary(true);
    }
    return Map.unmodifiable(data);
  }
}

class ProfileAddressPage extends ConsumerWidget {
  const ProfileAddressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final addresses = ref.watch(profileAddressesProvider);
    return ProfileScreen(
      title: s.profileAddresses,
      children: [
        AuthActionButton(
          label: s.profileAddAddress,
          onPressed: () => context.pushNamed('profile-address-new'),
        ),
        const SizedBox(height: 20),
        if (addresses.isEmpty) Text(s.profileNoAddresses),
        for (final entry in addresses.entries) ...[
          ProfileSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Text(
                  entry.value[AddressField.label],
                  style: AppTypography.authHeading,
                ),
                if (entry.value.primary) Text(s.profilePrimary),
                Text(entry.value[AddressField.recipient]),
                Text(entry.value[AddressField.phone]),
                Text(
                  [
                    for (final field in [
                      AddressField.details,
                      AddressField.village,
                      AddressField.district,
                      AddressField.city,
                      AddressField.province,
                      AddressField.postalCode,
                    ])
                      entry.value[field],
                  ].join(', '),
                ),
                if (entry.value[AddressField.note].isNotEmpty)
                  Text(entry.value[AddressField.note]),
                AuthActionButton(
                  label: s.profileEditAddress,
                  filled: false,
                  onPressed: () => context.pushNamed(
                    'profile-address-edit',
                    pathParameters: {'id': entry.key.toString()},
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        if (addresses.isNotEmpty)
          Text(s.profilePrimaryHint, style: AppTypography.authCaption),
      ],
    );
  }
}

class ProfileAddressForm extends ConsumerStatefulWidget {
  const ProfileAddressForm({super.key, this.addressId});

  final int? addressId;

  @override
  ConsumerState<ProfileAddressForm> createState() => _ProfileAddressFormState();
}

class _ProfileAddressFormState extends ConsumerState<ProfileAddressForm> {
  final _form = GlobalKey<FormState>();
  final _fields = <AddressField, String>{};
  late bool _primary =
      ref.read(profileAddressesProvider)[widget.addressId]?.primary ?? false;

  static const _autofillFields = [
    AddressField.province,
    AddressField.city,
    AddressField.district,
    AddressField.village,
    AddressField.postalCode,
    AddressField.details,
  ];
  final _inputs = <AddressField, TextEditingController>{};
  LocationAddress? _location;
  final _suggestions = <AddressField, String>{};
  bool _pickerOpen = false;

  @override
  void initState() {
    super.initState();
    final address = ref.read(profileAddressesProvider)[widget.addressId];
    _location = address?.location;
    for (final field in _autofillFields) {
      _inputs[field] = TextEditingController(text: address?[field]);
    }
  }

  @override
  void dispose() {
    for (final input in _inputs.values) {
      input.dispose();
    }
    super.dispose();
  }

  Future<void> _pickLocation() async {
    if (_pickerOpen) return;
    _pickerOpen = true;
    FocusScope.of(context).unfocus();
    try {
      final result = await context.pushNamed<LocationAddress>(
        'profile-address-location',
        extra: _location,
      );
      if (!mounted || result == null) return;

      final street = [?result.street, ?result.streetNumber].join(' ');
      final suffix = <AddressField, String?>{
        AddressField.province: result.province,
        AddressField.city: result.city,
        AddressField.district: result.district,
        AddressField.village: result.village,
        AddressField.postalCode: result.postalCode,
        AddressField.details: street.isEmpty ? result.formattedAddress : street,
      };
      for (final entry in suffix.entries) {
        final input = _inputs[entry.key]!;
        final suggestion = entry.value;
        if (input.text.trim().isEmpty ||
            input.text == _suggestions[entry.key]) {
          input.text = suggestion ?? '';
          if (suggestion == null) {
            _suggestions.remove(entry.key);
          } else {
            _suggestions[entry.key] = suggestion;
          }
        }
      }
      setState(() => _location = result);
    } finally {
      _pickerOpen = false;
    }
  }

  void _saveAddress() {
    final form = _form.currentState;
    if (form?.validate() != true) return;
    form!.save();
    ref
        .read(profileAddressesProvider.notifier)
        .save(
          widget.addressId,
          ProfileAddress(_fields, primary: _primary, location: _location),
        );
    _back();
  }

  Future<void> _deleteAddress(AppLocalizations strings) async {
    final remove = await showAppDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(strings.profileDeleteAddress),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(strings.profileCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(strings.profileRemove),
          ),
        ],
      ),
    );
    if (!mounted || remove != true) return;
    ref.read(profileAddressesProvider.notifier).remove(widget.addressId!);
    _back();
  }

  void _back() =>
      context.canPop() ? context.pop() : context.go('/profile/addresses');

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final address = ref.watch(profileAddressesProvider)[widget.addressId];
    final editing = widget.addressId != null;
    final labels = {
      AddressField.label: s.profileAddressLabel,
      AddressField.recipient: s.profileRecipient,
      AddressField.phone: s.profilePhone,
      AddressField.province: s.profileProvince,
      AddressField.city: s.profileCity,
      AddressField.district: s.profileDistrict,
      AddressField.village: s.profileVillage,
      AddressField.postalCode: s.profilePostalCode,
      AddressField.details: s.profileAddressDetails,
      AddressField.note: s.profileCourierNote,
    };
    final hints = {
      AddressField.label: s.addressLabelHint,
      AddressField.recipient: s.addressRecipientHint,
      AddressField.phone: s.addressPhoneHint,
      AddressField.province: s.addressProvinceHint,
      AddressField.city: s.addressCityHint,
      AddressField.district: s.addressDistrictHint,
      AddressField.village: s.addressVillageHint,
      AddressField.postalCode: s.profilePostalCode,
      AddressField.details: s.addressDetailsHint,
      AddressField.note: s.addressNoteHint,
    };
    Widget field(AddressField field) => ProfileField(
      key: ValueKey('address-${field.name}'),
      label: field == AddressField.note ? labels[field]! : '${labels[field]} *',
      hint: hints[field],
      controller: _inputs[field],
      initialValue: _inputs.containsKey(field) ? null : address?[field],
      keyboardType: switch (field) {
        AddressField.phone => TextInputType.phone,
        AddressField.postalCode => TextInputType.number,
        _ => TextInputType.text,
      },
      lines: field == AddressField.details ? 2 : 1,
      validator: (value) =>
          field != AddressField.note && (value?.trim().isEmpty ?? true)
          ? s.profileRequired
          : null,
      onSaved: (value) => _fields[field] = value?.trim() ?? '',
    );

    return ProfileScreen(
      title: editing ? s.profileEditAddress : s.profileNewAddress,
      children: [
        if (editing && address == null)
          Text(s.profileNoAddresses)
        else
          Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 20,
              children: [
                _AddressMapPreview(
                  coordinate: _location?.coordinate,
                  onEdit: _pickLocation,
                ),
                for (final item in [
                  AddressField.label,
                  AddressField.recipient,
                  AddressField.phone,
                  AddressField.province,
                  AddressField.city,
                  AddressField.district,
                ])
                  field(item),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Expanded(child: field(AddressField.village)),
                    Expanded(child: field(AddressField.postalCode)),
                  ],
                ),
                field(AddressField.details),
                field(AddressField.note),
                ProfileSurface(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      s.profilePrimaryAddress,
                      style: ProfileField.labelStyle,
                    ),
                    value: _primary,
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.authPrimary,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xFFE5E7EB),
                    trackOutlineColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                    onChanged: (value) => setState(() => _primary = value),
                  ),
                ),
                if (editing)
                  Row(
                    spacing: 10,
                    children: [
                      Expanded(
                        child: AuthActionButton(
                          label: s.profileDeleteAddress,
                          filled: false,
                          onPressed: () => _deleteAddress(s),
                        ),
                      ),
                      Expanded(
                        child: AuthActionButton(
                          label: s.addressEditSave,
                          onPressed: _saveAddress,
                        ),
                      ),
                    ],
                  )
                else
                  AuthActionButton(
                    label: s.profileSaveAddress,
                    onPressed: _saveAddress,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _AddressMapPreview extends ConsumerWidget {
  const _AddressMapPreview({required this.coordinate, required this.onEdit});
  final LocationCoordinate? coordinate;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) => SizedBox(
    height: 166,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(child: AppGoogleMap(coordinate: coordinate)),
          if (coordinate != null &&
              ref.watch(nativeMapReadyProvider).asData?.value == true)
            const Positioned(
              top: 36,
              left: 0,
              right: 0,
              child: Center(child: AppMapMarker(size: 50)),
            ),
          Positioned(
            left: 21,
            right: 21,
            bottom: 14,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: AuthActionButton(
                label: AppLocalizations.of(context).mapsTitle,
                filled: false,
                onPressed: onEdit,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
