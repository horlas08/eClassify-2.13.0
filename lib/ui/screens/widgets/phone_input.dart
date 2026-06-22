import 'dart:developer';

import 'package:country_picker/country_picker.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/ui/screens/location/helpers/debounce_search_mixin.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';

class PhoneInput extends StatefulWidget {
  const PhoneInput({
    required this.controller,
    this.focusNode,
    this.readOnly = false,
    this.required = true,
    super.key,
  });

  final PhoneInputController controller;
  final FocusNode? focusNode;
  final bool readOnly;
  final bool required;

  @override
  State<PhoneInput> createState() => _PhoneInputState();
}

class _PhoneInputState extends State<PhoneInput> with DebounceSearchMixin {
  late final TextEditingController _controller;
  String _phoneCode = AppConfig.defaultPhoneCode;
  late CountryWithPhoneCode _country;
  final _countries = CountryManager().countries;
  bool _isValid = false;

  late String _countryFlag;

  @override
  void initState() {
    super.initState();
    setCountry(widget.controller.regionCode);
    _phoneCode = _country.phoneCode;
    _countryFlag =
        CountryService().findByCode(_country.countryCode)?.flagEmoji ?? '';
    final formatted = formatNumberSync(
      widget.controller.phoneNumber,
      country: _country,
      inputContainsCountryCode: false,
    );
    _controller = TextEditingController(text: formatted);
    validate(_controller.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void setCountry(String countryCode) {
    _country = _countries.firstWhere(
      (element) =>
          element.countryCode.toLowerCase() == countryCode.toLowerCase(),
      orElse: () => CountryWithPhoneCode.us(),
    );
  }

  Future<void> validate(String? value) async {
    if (widget.controller.text.isNotEmpty) {
      widget.controller.clear();
    }
    if (value == null || value.isEmpty) {
      _isValid = !widget.required;
    } else {
      final result = await getFormattedParseResult(value, _country);
      log('${result?.e164} ${_country.countryName}');
      if (result == null) {
        _isValid = false;
      } else {
        final phoneCode = _country.phoneCode;
        // Increase the length by 1 to account for '+'.
        final number = result.e164.substring(phoneCode.length + 1);
        widget.controller.phoneCode = phoneCode;
        widget.controller.phoneNumber = number;
        widget.controller.regionCode = _country.countryCode;
        widget.controller.formattedNumber = result.formattedNumber;
        _isValid = true;
      }
    }
  }

  @override
  Duration get debounceDuration => const Duration(milliseconds: 200);

  @override
  void onDebouncedSearch(String? value) async => validate(value);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: TextFormField(
        autofocus: false,
        focusNode: widget.focusNode,
        controller: _controller,
        keyboardType: TextInputType.number,
        readOnly: widget.readOnly,
        onChanged: onChanged,
        validator: (value) {
          return _isValid
              ? null
              : 'pleaseEnterValidPhoneNumber'.translate(context);
        },
        inputFormatters: [
          LibPhonenumberTextFormatter(
            country: _country,
            shouldKeepCursorAtEndOfInput: false,
          ),
        ],
        decoration: InputDecoration(
          hintText: _country.exampleNumberMobileInternational.substring(
            _country.phoneCode.length + 1,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: GestureDetector(
              onTap: () {
                showCountryPicker(
                  context: context,
                  showPhoneCode: true,
                  onSelect: (country) {
                    setState(() {
                      _phoneCode = country.phoneCode;
                      _countryFlag = country.flagEmoji;
                      setCountry(country.countryCode);
                    });
                    _controller.clear();
                  },
                );
              },
              child: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 5,
                  children: [
                    Flexible(
                      child: Text(
                        _countryFlag,
                        style: context.titleMedium,
                        maxLines: 1,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        '${_phoneCode.startsWith('+') ? _phoneCode : '+$_phoneCode'}',
                        style: context.titleSmall.bold,
                        maxLines: 1,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 20,
                      color: context.color.textDefaultColor,
                    ),
                    SizedBox(
                      height: 20,
                      child: VerticalDivider(
                        color: context.color.textDefaultColor,
                        width: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
      ),
    );
  }
}

class PhoneInputController extends TextEditingController {
  PhoneInputController();

  factory PhoneInputController.empty() => PhoneInputController()..clear();

  String _phoneCode = AppConfig.defaultPhoneCode;

  String get phoneCode => _phoneCode;

  set phoneCode(String? value) {
    if (value == null) return;
    _phoneCode = value;
  }

  String _phoneNumber = '';

  String get phoneNumber => _phoneNumber;

  set phoneNumber(String? value) {
    if (value == null) return;
    _phoneNumber = value;
    notifyListeners();
  }

  String _regionCode = AppConfig.defaultCountryCode;

  String get regionCode => _regionCode;

  set regionCode(String? value) {
    if (value == null) return;
    _regionCode = value;
  }

  String _formattedNumber = '';

  String get formattedNumber => _formattedNumber;

  set formattedNumber(String? value) {
    if (value == null) return;
    _formattedNumber = value;
  }

  void clear() {
    _phoneNumber = '';
    _phoneCode = AppConfig.defaultPhoneCode;
    _regionCode = AppConfig.defaultCountryCode;
    notifyListeners();
  }

  @override
  TextEditingValue get value =>
      TextEditingValue(text: '+$phoneCode $_phoneNumber');

  @override
  String toString() {
    return 'PhoneInputController{_phoneCode: $_phoneCode, _phoneNumber: $_phoneNumber}';
  }
}
