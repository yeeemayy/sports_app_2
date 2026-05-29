import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/shared_widgets/custom_text_field.dart';

class CountryPhoneNumberTextField extends StatefulWidget {
  final TextEditingController textEditingController;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onCountryCodeChanged;

  const CountryPhoneNumberTextField({
    super.key,
    required this.textEditingController,
    this.validator,
    this.onCountryCodeChanged,
  });

  @override
  State<CountryPhoneNumberTextField> createState() =>
      _CountryPhoneNumberTextFieldState();
}

class _CountryPhoneNumberTextFieldState
    extends State<CountryPhoneNumberTextField> {
  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      textEditingController: widget.textEditingController,
      keyboardType: TextInputType.phone,
      hintText: 'auth.field.telephone_hint'.tr(),
      prefixIcon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          spacing: 10,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('+86'),
            SizedBox(width: 8),
            const SizedBox(
              height: 20,
              width: 0,
              child: VerticalDivider(color: Colors.grey),
            ),
          ],
        ),
      ),
      // CountryCodePicker(
      //   builder: (countryCode) => Padding(
      //     padding: const EdgeInsets.symmetric(horizontal: 8.0),
      //     child: Row(
      //       spacing: 10,
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //         Text(countryCode?.dialCode ?? ''),
      //         const Icon(Icons.keyboard_arrow_down, size: 16),
      //         const SizedBox(height: 20, width: 0, child: VerticalDivider(color: Colors.grey)),
      //       ],
      //     ),
      //   ),
      //   onChanged: (code) {
      //     widget.onCountryCodeChanged?.call(code.dialCode ?? '+86');
      //   },
      //   initialSelection: 'CN',
      //   favorite: const ['+86', 'CN'],
      //   showFlag: false,
      //   showFlagDialog: true,
      //   showCountryOnly: false,
      //   showOnlyCountryWhenClosed: false,
      //   alignLeft: false,
      //   searchPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      //   headerText: 'auth.field.select_country_region'.tr(),
      //   searchDecoration: InputDecoration(
      //     hintText: 'auth.field.search_country_region'.tr(),
      //     hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
      //     prefixIcon: const Icon(Icons.search_outlined),
      //     filled: true,
      //     fillColor: const Color(0xfff5f5f5),
      //     enabledBorder: const OutlineInputBorder(
      //       borderSide: BorderSide(color: Colors.transparent),
      //       borderRadius: BorderRadius.all(Radius.circular(30)),
      //     ),
      //     focusedBorder: const OutlineInputBorder(
      //       borderSide: BorderSide(color: ArenaColors.accent),
      //       borderRadius: BorderRadius.all(Radius.circular(30)),
      //     ),
      //   ),
      // ),
      validator: widget.validator,
    );
  }
}
