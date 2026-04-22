import 'dart:typed_data';
import 'package:archiving_flutter_project/models/db/user_models/update_user_password_model.dart';
import 'package:archiving_flutter_project/service/controller/users_controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import '../dialogs/error_dialgos/show_error_dialog.dart';
import '../utils/constants/colors.dart';
import '../utils/encrypt/encryption.dart';
import '../utils/func/responsive.dart';
import '../widget/dashboard_components/custom_elevated_button.dart';

// ── Design tokens ─────────────────────────────────────────────────
const Color _cpPrimary = Color(0xFF185FA5);
const Color _cpPrimaryDark = Color(0xFF0D3F73);
const Color _cpBorder = Color(0xFFDDE3EE);
const Color _cpLabel = Color(0xFF8A94A6);
const Color _cpText = Color(0xFF1A2340);
const Color _cpBg = Color(0xFFF0F4F8);
const Color _cpError = Color(0xFFA32D2D);

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  double width = 0;
  double height = 0;
  bool isDesktop = false;
  late AppLocalizations _locale;
  bool isLoading = false;

  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();

  bool obscureOldPassword = true;
  bool obscureNewPassword = true;
  bool obscureConfirmNewPassword = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _locale = AppLocalizations.of(context)!;
    isDesktop = Responsive.isDesktop(context);
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: _cpBg,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Card ────────────────────────────────────────────
              Container(
                width: isDesktop ? width * 0.38 : width * 0.92,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _cpPrimary.withOpacity(0.10),
                      blurRadius: 40,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Header ─────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: _cpPrimary.withOpacity(0.04),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        border: Border(
                          bottom: BorderSide(color: _cpBorder, width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _cpPrimary.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.lock_outline_rounded,
                              color: _cpPrimary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _locale.changePassword,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: _cpText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _locale.editPassword,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _cpLabel,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ── Fields ──────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _passwordField(
                            hint: _locale.oldPass,
                            controller: oldPasswordController,
                            obscure: obscureOldPassword,
                            onToggle: () => setState(
                                () => obscureOldPassword = !obscureOldPassword),
                          ),
                          const SizedBox(height: 16),
                          _passwordField(
                            hint: _locale.newPass,
                            controller: newPasswordController,
                            obscure: obscureNewPassword,
                            onToggle: () => setState(
                                () => obscureNewPassword = !obscureNewPassword),
                          ),
                          const SizedBox(height: 16),
                          _passwordField(
                            hint: _locale.newPassConfirm,
                            controller: confirmNewPasswordController,
                            obscure: obscureConfirmNewPassword,
                            onToggle: () => setState(() =>
                                obscureConfirmNewPassword =
                                    !obscureConfirmNewPassword),
                          ),
                          const SizedBox(height: 28),

                          // ── Submit ─────────────────────────────────
                          CustomElevatedButton(
                            text: _locale.save,
                            color: _cpPrimary,
                            icon: Icons.save_rounded,
                            width: double.infinity,
                            height: 48,
                            fontSize: 15,
                            isLoading: isLoading,
                            onPressed: _validate,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Password field ───────────────────────────────────────────────
  Widget _passwordField({
    required String hint,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    final bool isFilled = controller.text.isNotEmpty;

    return _StyledPasswordField(
      hint: hint,
      controller: controller,
      obscure: obscure,
      onToggle: onToggle,
    );
  }

  // ── Validation ───────────────────────────────────────────────────
  void _validate() {
    if (oldPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmNewPasswordController.text.isEmpty) {
      _showError(_locale.pleaseAddAllRequiredFields);
    } else if (newPasswordController.text !=
        confirmNewPasswordController.text) {
      _showError(_locale.passwordNotEquals);
    } else {
      _save();
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        icon: Icons.error,
        errorDetails: message,
        errorTitle: _locale.error,
        color: Colors.red,
        statusCode: 200,
      ),
    );
  }

  Future<void> _save() async {
    if (newPasswordController.text.contains(' ') ||
        oldPasswordController.text.contains(' ')) {
      _showError(_locale.noSpacesAllowed);
      return;
    }

    setState(() => isLoading = true);

    String key = "archiveProj@s2024ASD/Key@team.CT";
    final iv = [0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1];
    final byteArray =
        Uint8List.fromList(iv.map((bit) => bit == 1 ? 0x01 : 0x00).toList());

    String passEncrypted = Encryption.performAesEncryption(
        oldPasswordController.text.trim(), key, byteArray);
    String passEncryptedNew = Encryption.performAesEncryption(
        newPasswordController.text.trim(), key, byteArray);

    UpdateUserPassword updateUserPassword = UpdateUserPassword(
        oldPassword: passEncrypted, password: passEncryptedNew);

    var response =
        await UserController().updateCurrentUserPassword(updateUserPassword);

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => ErrorDialog(
          icon: Icons.done_all,
          errorDetails: _locale.done,
          errorTitle: _locale.editDoneSucess,
          color: Colors.green,
          statusCode: 200,
        ),
      ).then((_) {
        oldPasswordController.clear();
        newPasswordController.clear();
        confirmNewPasswordController.clear();
      });
    }
  }
}

// ── Styled password field widget ─────────────────────────────────
class _StyledPasswordField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  const _StyledPasswordField({
    required this.hint,
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });

  @override
  State<_StyledPasswordField> createState() => _StyledPasswordFieldState();
}

class _StyledPasswordFieldState extends State<_StyledPasswordField> {
  final FocusNode _focus = FocusNode();
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      setState(() => _isFocused = _focus.hasFocus);
    });
    widget.controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  bool get _hasValue => widget.controller.text.isNotEmpty;
  bool get _shouldFloat => _hasValue || _isFocused;

  Color get _borderColor {
    if (_isFocused) return _cpPrimary;
    if (_isHovered) return _cpPrimary.withOpacity(0.5);
    return _cpBorder;
  }

  double get _borderWidth {
    if (_isFocused) return 1.8;
    if (_isHovered) return 1.2;
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: TextFormField(
        focusNode: _focus,
        controller: widget.controller,
        obscureText: widget.obscure,
        style: const TextStyle(fontSize: 14, color: _cpText),
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
        ],
        decoration: InputDecoration(
          // ── OutlineInputBorder draws label cutout ──────
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _cpBorder, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: _isHovered ? _cpPrimary.withOpacity(0.5) : _cpBorder,
              width: _isHovered ? 1.2 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _cpPrimary, width: 1.8),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _cpError, width: 1),
          ),

          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),

          // ── Label floats above border when has value ───
          floatingLabelBehavior: _shouldFloat
              ? FloatingLabelBehavior.always
              : FloatingLabelBehavior.auto,

          label: Text(
            widget.hint,
            style: TextStyle(
              fontSize: 13,
              color: _isFocused ? _cpPrimary : _cpLabel,
            ),
          ),
          floatingLabelStyle: TextStyle(
            fontSize: 11,
            color: _isFocused ? _cpPrimary : _cpLabel,
            fontWeight: FontWeight.w500,
            backgroundColor: Colors.white,
          ),

          // ── Lock icon prefix ───────────────────────────
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            size: 18,
            color: _isFocused ? _cpPrimary : _cpLabel,
          ),

          // ── Toggle visibility suffix ───────────────────
          suffixIcon: IconButton(
            onPressed: widget.onToggle,
            icon: Icon(
              widget.obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 18,
              color: _cpLabel,
            ),
          ),
        ),
      ),
    );
  }
}
