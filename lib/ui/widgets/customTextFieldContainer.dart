// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eschool/utils/utils.dart';

class CustomTextFieldContainer extends StatelessWidget {
  final String hintTextKey;
  final bool hideText;
  final double? bottomPadding;
  final Widget? suffixWidget;
  final TextEditingController? textEditingController;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  CustomTextFieldContainer({
    Key? key,
    required this.hintTextKey,
    required this.hideText,
    this.bottomPadding,
    this.suffixWidget,
    this.textEditingController,
    this.keyboardType,
    this.inputFormatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: EdgeInsets.only(bottom: bottomPadding ?? 20.0),
      padding: const EdgeInsetsDirectional.only(
        start: 20.0,
        // Note: We don't need explicit end padding here because the
        // suffixWidget's own padding will naturally create the gap.
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Utils.getColorScheme(context).secondary),
      ),
      child: Row(
        children: [
          // 1. The TextField takes up all remaining space
          Expanded(
            child: TextField(
              controller: textEditingController,
              obscureText: hideText,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              enableInteractiveSelection: true,
              enableSuggestions: keyboardType != TextInputType.number,
              autofocus: false,
              decoration: InputDecoration(
                hintText: Utils.getTranslatedLabel(hintTextKey),
                hintStyle: TextStyle(color: Utils.getColorScheme(context).secondary),
                border: InputBorder.none,
                isDense: true, // Helps with vertical alignment
                // Perfectly centers text vertically in the 50px height container
                contentPadding: const EdgeInsets.symmetric(vertical: 12.5),
              ),
            ),
          ),

          // 2. The suffix widget sits neatly on the right, completely decoupled
          if (suffixWidget != null)
            suffixWidget!,
        ],
      ),
    );
  }
}