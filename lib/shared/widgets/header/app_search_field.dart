import 'package:flutter/material.dart';
import 'package:serba_jaya_mobile/app/theme/app_assets.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';

class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    this.query = '',
    this.hintText = 'Cari Produk',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  final String query;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(covariant AppSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != oldWidget.query && widget.query != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.query,
        selection: TextSelection.collapsed(offset: widget.query.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.headerField,
      border: Border.all(color: AppColors.headerFieldBorder, width: 0.5),
      borderRadius: BorderRadius.circular(AppRadius.authField),
    ),
    child: SizedBox(
      height: 38,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            style: AppTypography.headerSearch,
            onChanged: (value) {
              setState(() {});
              widget.onChanged?.call(value);
            },
            onSubmitted: widget.onSubmitted,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: AppTypography.headerSearchHint,
              isDense: true,
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.only(
                left: 13,
                right: 40,
                top: 9,
                bottom: 9,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.authField),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            Positioned(
              right: 11,
              child: Semantics(
                key: const Key('app-search-clear'),
                button: true,
                label: 'Hapus pencarian',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _clear,
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Image(
                      image: AssetImage(AppAssets.headerClear),
                      width: 18,
                      height: 18,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );

  void _clear() {
    _controller.clear();
    setState(() {});
    widget.onChanged?.call('');
    widget.onClear?.call();
  }
}
