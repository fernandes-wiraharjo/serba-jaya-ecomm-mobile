import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:serba_jaya_mobile/core/location/location_models.dart';
import 'package:serba_jaya_mobile/core/location/location_services.dart';
import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';

class LocationSearchSheet extends StatefulWidget {
  const LocationSearchSheet({super.key, required this.service});
  final PlacesService? service;

  @override
  State<LocationSearchSheet> createState() => _LocationSearchSheetState();
}

class _LocationSearchSheetState extends State<LocationSearchSheet> {
  final _query = TextEditingController();
  Timer? _debounce;
  CancelToken? _cancel;
  List<LocationSearchResult>? _results;
  bool _loading = false;
  bool _failed = false;
  bool _selecting = false;
  late final String _session = _newSession();

  String _newSession() {
    final random = Random.secure();
    return base64UrlEncode(List.generate(18, (_) => random.nextInt(256)));
  }

  void _cancelRequest() {
    _debounce?.cancel();
    _cancel?.cancel();
    _cancel = null;
  }

  void _search(String input) {
    _cancelRequest();
    final service = widget.service;
    final term = input.trim();
    setState(() {
      _failed = false;
      _loading = service != null && term.length >= 3;
      _results = null;
    });
    if (!_loading || service == null) return;

    final token = _cancel = CancelToken();
    _debounce = Timer(const Duration(milliseconds: 380), () async {
      try {
        final list = await service
            .autocomplete(term, sessionToken: _session, cancel: token)
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                token.cancel();
                throw TimeoutException('Places autocomplete');
              },
            );
        if (!mounted || !identical(token, _cancel)) return;
        setState(() {
          _results = list;
          _loading = false;
        });
      } on Exception {
        if (!mounted || !identical(token, _cancel)) return;
        setState(() {
          _failed = true;
          _loading = false;
        });
      }
    });
  }

  Future<void> _select(LocationSearchResult item) async {
    final service = widget.service;
    if (service == null || _selecting) return;
    _cancelRequest();
    final token = _cancel = CancelToken();
    setState(() => _selecting = true);
    try {
      final address = await service
          .details(item.placeId, sessionToken: _session, cancel: token)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              token.cancel();
              throw TimeoutException('Place details');
            },
          );
      if (mounted && identical(_cancel, token)) Navigator.pop(context, address);
    } on Exception {
      if (!mounted || !identical(_cancel, token)) return;
      setState(() {
        _selecting = false;
        _failed = true;
      });
    }
  }

  @override
  void dispose() {
    _cancelRequest();
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(22),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: constraints.maxHeight.clamp(0, 380).toDouble(),
            child: Column(
              children: [
                TextField(
                  controller: _query,
                  enabled: widget.service != null && !_selecting,
                  autofocus: widget.service != null,
                  onChanged: _search,
                  decoration: InputDecoration(labelText: s.mapsSearch),
                ),
                const SizedBox(height: 12),
                if (_loading || _selecting)
                  const LinearProgressIndicator()
                else if (widget.service == null)
                  Text(s.mapsSearchUnavailable)
                else if (_failed)
                  TextButton(
                    onPressed: () => _search(_query.text),
                    child: Text(s.mapsSearchError),
                  )
                else if (_results case final list?)
                  if (list.isEmpty)
                    Text(s.mapsNoResults)
                  else
                    Expanded(
                      child: ListView.builder(
                        primary: false,
                        itemCount: list.length,
                        itemBuilder: (_, index) => ListTile(
                          title: Text(list[index].label),
                          onTap: () => _select(list[index]),
                        ),
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}
