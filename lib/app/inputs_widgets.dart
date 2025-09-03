import 'package:flutter/material.dart';

class CustomComboBoxItemModel<T> {
  final T value;
  final String label;

  CustomComboBoxItemModel({required this.value, required this.label});
}

class CustomComboBox<T> extends StatelessWidget {
  const CustomComboBox({
    super.key,
    this.value,
    this.label,
    this.items = const [],
    this.color,
    this.hintText,
    required this.constraints,
    this.onChanged,
    this.validator,
  });

  final T? value;
  final Color? color;
  final String? label;
  final String? hintText;
  final List<CustomComboBoxItemModel<T>> items;
  final BoxConstraints constraints;
  final void Function(T? value)? onChanged;
  final String? Function(T?)? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        label: label != null ? Text(label!) : null,
        hintText: hintText,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      items: items
          .map(
            (item) =>
                DropdownMenuItem<T>(value: item.value, child: Text(item.label)),
          )
          .toList(),
      selectedItemBuilder: (context) {
        return items.map((e) => Text(e.label)).toList();
      },
    );
  }
}

////////////////////////////////////////////////////////////////////////////////

class CustomTextBox extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Color? hintColor;
  final Color? textColor;
  final Color? labelColor;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final BoxConstraints constraints;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final void Function()? onEditingComplete;
  final void Function(String?)? onSaved;
  const CustomTextBox({
    super.key,
    this.hintText,
    this.controller,
    this.maxLines = 1,
    this.minLines = 1,
    this.maxLength,
    this.keyboardType,
    this.validator,
    required this.constraints,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.onTap,
    this.onChanged,
    this.labelText,
    this.readOnly = false,
    this.onEditingComplete,
    this.onSaved,
    this.hintColor,
    this.textColor,
    this.labelColor,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: (prefixIcon == null && suffixIcon == null) ? 0 : 5,
      ),
      child: Stack(
        children: [
          Transform.translate(
            offset: Offset(
              0,
              (prefixIcon == null && suffixIcon == null) ? 0 : -5,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              height: 47,
              decoration: BoxDecoration(
                color: Theme.of(context).hintColor.withAlpha(5),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Theme.of(context).hintColor.withAlpha(20),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: prefixIcon == null ? 15 : 0,
              right: suffixIcon == null ? 15 : 0,
            ),
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              minLines: minLines,
              autofillHints: autofillHints,
              maxLength: maxLength,
              keyboardType: keyboardType,
              obscureText: obscureText,
              enabled: enabled,
              readOnly: readOnly,
              textCapitalization: textCapitalization,
              textAlign: textAlign,

              decoration: InputDecoration(
                labelText: labelText,
                prefixIcon: prefixIcon == null
                    ? prefixIcon
                    : Transform.translate(
                        offset: Offset(0, -5),
                        child: prefixIcon,
                      ),
                suffixIcon: suffixIcon == null
                    ? suffixIcon
                    : Transform.translate(
                        offset: Offset(0, -5),
                        child: suffixIcon,
                      ),

                hintText: hintText,
                border: InputBorder.none,
              ),
              validator: validator,
              onTap: onTap,
              onChanged: onChanged,
              onEditingComplete: onEditingComplete,
              onSaved: onSaved,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTextBoxTwo extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Color? hintColor;
  final Color? textColor;
  final Color? labelColor;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final BoxConstraints constraints;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final void Function()? onEditingComplete;
  final void Function(String?)? onSaved;
  const CustomTextBoxTwo({
    super.key,
    this.hintText,
    this.controller,
    this.maxLines = 1,
    this.minLines = 1,
    this.maxLength,
    this.keyboardType,
    this.validator,
    required this.constraints,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.onTap,
    this.onChanged,
    this.labelText,
    this.readOnly = false,
    this.onEditingComplete,
    this.onSaved,
    this.hintColor,
    this.textColor,
    this.labelColor,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).hintColor.withAlpha(5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Theme.of(context).hintColor.withAlpha(20)),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        minLines: minLines,
        autofillHints: autofillHints,
        maxLength: maxLength,
        keyboardType: keyboardType,
        obscureText: obscureText,
        enabled: enabled,
        readOnly: readOnly,
        textCapitalization: textCapitalization,
        textAlign: textAlign,

        decoration: InputDecoration(
          labelText: labelText,

          hintText: hintText,
          border: InputBorder.none,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
        validator: validator,
        onTap: onTap,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        onSaved: onSaved,
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
