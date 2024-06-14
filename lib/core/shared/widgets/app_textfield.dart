import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/_constants.dart';

class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final bool obscureText;
  final InputBorder? border;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onTap;
  final void Function()? onEditingComplete;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextAlignVertical? textAlignVertical;
  final TextAlign? textAlign;
  final Widget? suffix;
  final Widget? prefix;
  final Widget? bottomWidget;
  final bool readOnly;
  final bool expands;
  final bool hasBorder;
  final int? minLines, maxLines, maxLength;
  final bool enabled;
  final Color? fillColor;
  final InputDecoration? decoration;
  final List<TextInputFormatter>? inputFormatters;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.border,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.suffix,
    this.obscureText = false,
    this.prefix,
    this.initialValue,
    this.focusNode,
    this.readOnly = false,
    this.expands = false,
    this.hasBorder = true,
    this.minLines,
    this.maxLines,
    this.maxLength,
    this.enabled = true,
    this.onChanged,
    this.onFieldSubmitted,
    this.fillColor,
    this.onTap,
    this.onEditingComplete,
    this.decoration,
    this.textAlign,
    this.textAlignVertical,
    this.bottomWidget,
    this.inputFormatters,
  }) : assert(initialValue == null || controller == null);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.medium14.copyWith(
              color: AppColors.gray700,
            ),
          ),
          Spacing.vertExtraTiny(),
          Spacing.vertTiny()
        ],
        TextFormField(
          enabled: enabled,
          controller: controller,
          initialValue: initialValue,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          onTap: onTap,
          keyboardType: keyboardType,
          cursorWidth: 1,
          textCapitalization: textCapitalization,
          obscureText: obscureText,
          obscuringCharacter: '●',
          readOnly: readOnly,
          focusNode: focusNode,
          expands: expands,
          maxLines: maxLines,
          validator: validator,
          minLines: minLines,
          // maxLength: maxLength,
          inputFormatters: [
            LengthLimitingTextInputFormatter(maxLength),
            ...inputFormatters ?? []
          ],
          textAlignVertical: textAlignVertical ?? TextAlignVertical.center,
          textAlign: textAlign ?? TextAlign.start,
          onEditingComplete:
              onEditingComplete ?? () => FocusScope.of(context).nextFocus(),
          style: AppTextStyles.regular16.copyWith(
            height: 1.5,
          ),
          decoration: decoration ??
              InputDecoration(
                hintText: hint,
                suffixIcon: suffix != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: suffix!,
                          ),
                        ],
                      )
                    : null,
                prefixIcon: prefix != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: prefix!,
                          ),
                        ],
                      )
                    : null,
                enabled: enabled,
                border: border,
                alignLabelWithHint:
                    maxLines != null && keyboardType == TextInputType.multiline,
              ),
        ),
        if (bottomWidget != null) ...[Spacing.vertTiny(), bottomWidget!],
      ],
    );
  }
}

class AppDropdownField<T> extends StatelessWidget {
  final List<T>? items;
  final T? value;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final Widget Function(T)? customItem;
  final String Function(T)? displayItem;
  final String? label, hint;
  final String? headingText;
  final Widget? prefix;
  final FocusNode? focusNode;
  final bool enabled;
  final Color? fillColor;
  final bool hasBorder;
  final void Function()? onTap;
  final EdgeInsetsGeometry? contentPadding;

  const AppDropdownField({
    super.key,
    required this.items,
    required this.value,
    this.onChanged,
    this.validator,
    this.label,
    this.hint,
    this.headingText,
    this.prefix,
    this.enabled = true,
    this.fillColor,
    this.focusNode,
    this.customItem,
    this.displayItem,
    this.hasBorder = true,
    this.onTap,
    this.contentPadding,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.medium14.copyWith(
              color: AppColors.gray700,
            ),
          ),
          Spacing.vertExtraTiny(),
          Spacing.vertTiny()
        ],
        InkWell(
          onTap: onTap,
          child: DropdownButtonFormField<T>(
            items: items?.map(
              (T item) {
                if (customItem != null) {
                  return DropdownMenuItem(
                    value: item,
                    child: customItem!(item),
                  );
                }
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    displayItem != null ? displayItem!(item) : item.toString(),
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: AppTextStyles.regular16.copyWith(
                      color: AppColors.gray600,
                      height: .4,
                    ),
                  ),
                );
              },
            ).toList(),
            isExpanded: true,
            onChanged: onChanged,
            validator: validator,
            value: value,
            focusNode: focusNode,
            icon: const Icon(Icons.keyboard_arrow_down, size: 0),
            style: AppTextStyles.regular16,
            decoration: InputDecoration(
              isCollapsed: contentPadding != null,
              contentPadding: contentPadding,
              hintText: hint,
              prefixIcon: prefix != null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: prefix!,
                        ),
                      ],
                    )
                  : null,
              enabled: enabled,
              suffixIcon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.gray400,
                size: 25,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AppSearchField extends StatelessWidget {
  const AppSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: AppTextStyles.regular16,
      cursorHeight: 20,
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.gray500,
        ),
        suffixIcon: const Icon(
          Icons.mic_none_outlined,
          color: AppColors.gray500,
        ),
        filled: true,
        fillColor: AppColors.gray50,
        hintText: 'Search assets',
        hintStyle: AppTextStyles.regular16.copyWith(
          color: AppColors.gray400,
        ),
        contentPadding: const EdgeInsets.all(8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gray50),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gray50),
        ),
      ),
    );
  }
}
