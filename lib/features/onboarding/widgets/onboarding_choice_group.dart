import 'package:flutter/material.dart';
import 'onboarding_option_cell.dart';

/// Một lựa chọn trong [OnboardingChoiceGroup].
class OnboardingChoice<T> {
  final T value;
  final String label;

  const OnboardingChoice({required this.value, required this.label});
}

/// Nhóm lựa chọn (single select) kèm ô "Other" cho câu trả lời tự do.
///
/// Dùng cho các bước onboarding trước đây bắt người dùng gõ tay:
/// chọn 1 phương án có sẵn, chỉ gõ khi thật sự cần (chọn "Other").
class OnboardingChoiceGroup<T> extends StatefulWidget {
  final List<OnboardingChoice<T>> choices;

  /// Giá trị đang được chọn (null nếu chưa chọn gì hoặc đang chọn "Other").
  final T? selected;

  /// True khi người dùng đang ở lựa chọn "Other".
  final bool isOtherSelected;

  /// Nội dung đã nhập ở ô "Other".
  final String otherText;

  final ValueChanged<T> onSelected;
  final VoidCallback onOtherSelected;
  final ValueChanged<String> onOtherTextChanged;

  final String otherLabel;
  final String otherHint;

  const OnboardingChoiceGroup({
    super.key,
    required this.choices,
    required this.selected,
    required this.isOtherSelected,
    required this.otherText,
    required this.onSelected,
    required this.onOtherSelected,
    required this.onOtherTextChanged,
    this.otherLabel = 'Other',
    this.otherHint = 'Describe it in your own words',
  });

  @override
  State<OnboardingChoiceGroup<T>> createState() =>
      _OnboardingChoiceGroupState<T>();
}

class _OnboardingChoiceGroupState<T> extends State<OnboardingChoiceGroup<T>> {
  late final TextEditingController _otherController;
  late final FocusNode _otherFocus;

  @override
  void initState() {
    super.initState();
    _otherController = TextEditingController(text: widget.otherText);
    _otherFocus = FocusNode();
  }

  @override
  void dispose() {
    _otherController.dispose();
    _otherFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final choice in widget.choices) ...[
          OnboardingOptionCell(
            text: choice.label,
            isSelected:
                !widget.isOtherSelected && widget.selected == choice.value,
            onTap: () {
              // Chọn phương án có sẵn thì đóng bàn phím của ô "Other"
              FocusScope.of(context).unfocus();
              widget.onSelected(choice.value);
            },
          ),
          const SizedBox(height: 12),
        ],
        OnboardingOptionCell(
          text: widget.otherLabel,
          isSelected: widget.isOtherSelected,
          onTap: () {
            widget.onOtherSelected();
            // Đưa con trỏ thẳng vào ô nhập để đỡ một thao tác
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _otherFocus.requestFocus();
            });
          },
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: widget.isOtherSelected
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    height: 54,
                    child: TextField(
                      controller: _otherController,
                      focusNode: _otherFocus,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                      onChanged: widget.onOtherTextChanged,
                      decoration: InputDecoration(
                        hintText: widget.otherHint,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFBEBAB3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFBEBAB3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFBEBAB3)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
