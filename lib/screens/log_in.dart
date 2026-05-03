import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:archiving_flutter_project/dialogs/error_dialgos/show_error_dialog.dart';
import 'package:archiving_flutter_project/models/dto/login_model.dart';
import 'package:archiving_flutter_project/providers/local_provider.dart';
import 'package:archiving_flutter_project/providers/screen_content_provider.dart';
import 'package:archiving_flutter_project/service/controller/login_controllers/login_controller.dart';
import 'package:archiving_flutter_project/utils/constants/routes_constant.dart';
import 'package:archiving_flutter_project/utils/constants/user_types_constant/user_types_constant.dart';
import 'package:archiving_flutter_project/utils/encrypt/encryption.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/language_widget/language_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/db/work_flow/setup_model.dart';
import '../service/controller/work_flow_controllers/setup_controller.dart';
import '../widget/custom_flutter_toast_message.dart';
import '../widget/side_menu/version_badge_widget.dart';

// ── Floating particle model ──────────────────────────────────────
class _Particle {
  double x, y, size, speed, opacity;
  Color color;
  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.color,
  });
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // ── Animation controllers ────────────────────────────────────────
  late AnimationController _animController;
  late AnimationController _particleController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<Offset> _brandSlideAnim;
  late Animation<double> _shimmerAnim;
  late Animation<double> _pulseAnim;

  // ── State ────────────────────────────────────────────────────────
  double width = 0;
  double height = 0;
  late AppLocalizations _locale;
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  FocusNode userNameFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  bool obsecureText = true;
  bool isLoading = false;
  late LocaleProvider localeProvider;
  late List<_Particle> _particles;
  Timer? _particleTimer;

  // ── Color palette ────────────────────────────────────────────────
  static const Color _primary = Color(0xFF185FA5);
  static const Color _primaryDark = Color(0xFF0A2E5C);
  static const Color _accent = Color(0xFF0D9B8A);
  static const Color _accentLight = Color(0xFF13C4AD);
  static const Color _gold = Color(0xFFFFB300);
  static const Color _bgLight = Color(0xFFEEF2F8);
  static const Color _purple = Color(0xFF6B4EFF);

  // Particle colors — subtle variations of the brand
  static const List<Color> _particleColors = [
    Color(0x33FFFFFF),
    Color(0x220D9B8A),
    Color(0x226B4EFF),
    Color(0x33FFB300),
  ];

  @override
  void didChangeDependencies() {
    _locale = AppLocalizations.of(context)!;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();

    // ── Entry animation ────────────────────────────────────────
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.1, 0.85, curve: Curves.easeOutCubic),
    ));
    _brandSlideAnim = Tween<Offset>(
      begin: const Offset(-0.08, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.75, curve: Curves.easeOutCubic),
    ));
    _animController.forward();

    // ── Shimmer on submit button ───────────────────────────────
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // ── Pulse on accent underline ──────────────────────────────
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // ── Floating particles ─────────────────────────────────────
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _initParticles();
    _startParticleTimer();
  }

  void _initParticles() {
    final rand = Random();
    _particles = List.generate(
        18,
        (i) => _Particle(
              x: rand.nextDouble(),
              y: rand.nextDouble(),
              size: 4 + rand.nextDouble() * 10,
              speed: 0.003 + rand.nextDouble() * 0.006,
              opacity: 0.15 + rand.nextDouble() * 0.35,
              color: _particleColors[rand.nextInt(_particleColors.length)],
            ));
  }

  void _startParticleTimer() {
    _particleTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted) return;
      setState(() {
        for (final p in _particles) {
          p.y -= p.speed;
          if (p.y < -0.05) {
            p.y = 1.05;
            p.x = Random().nextDouble();
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _particleController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _particleTimer?.cancel();
    _userNameController.dispose();
    _passwordController.dispose();
    userNameFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    localeProvider = Provider.of<LocaleProvider>(context);
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    final bool isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: _bgLight,
      body: isDesktop ? _desktopView() : _mobileView(),
    );
  }

  // ── Desktop ──────────────────────────────────────────────────────
  Widget _desktopView() {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            color: Colors.white, // ← replace the decoration with this
            child: Stack(
              children: [
                Center(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: _formCard(),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  // ← switches side based on locale
                  left: Directionality.of(context) == TextDirection.ltr
                      ? 20
                      : null,
                  right: Directionality.of(context) == TextDirection.rtl
                      ? 20
                      : null,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: const VersionBadge(baseColor: _gold),
                  ),
                ),
              ],
            ),
          ),
        ),
        // ── Branding panel ───────────────────────────────────────
        Expanded(
          flex: 5,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryDark, _primary, Color(0xFF1A7AB5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.6, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Floating particles
                ..._particles.map((p) => Positioned(
                      left: p.x * width * 0.55,
                      top: p.y * height,
                      child: Opacity(
                        opacity: p.opacity,
                        child: Container(
                          width: p.size,
                          height: p.size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: p.color,
                          ),
                        ),
                      ),
                    )),

                // Large decorative circles
                Positioned(
                  top: -100,
                  left: -100,
                  child: _circle(360, Colors.white.withOpacity(0.04)),
                ),
                Positioned(
                  bottom: -80,
                  right: -80,
                  child: _circle(300, _accent.withOpacity(0.08)),
                ),
                Positioned(
                  top: height * 0.35,
                  left: -40,
                  child: _circle(200, _purple.withOpacity(0.06)),
                ),
                Positioned(
                  top: height * 0.08,
                  right: -30,
                  child: _circle(140, _gold.withOpacity(0.06)),
                ),

                // Accent horizontal line top
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 3,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_accent, _accentLight, _purple],
                      ),
                    ),
                  ),
                ),

                // Branding content
                Center(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _brandSlideAnim,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 28),

                          // Logo with glow
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: _accent.withOpacity(0.25),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/images/logo-white.png',
                                width: 300,
                                height: 140,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          Text(
                            _locale.archivingSystem,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Animated pulsing underline
                          AnimatedBuilder(
                            animation: _pulseAnim,
                            builder: (context, _) => Container(
                              width: 60 * _pulseAnim.value,
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [_accent, _accentLight],
                                ),
                                borderRadius: BorderRadius.circular(99),
                                boxShadow: [
                                  BoxShadow(
                                    color: _accent.withOpacity(0.5),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          Text(
                            _locale.signIn,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 20,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Center(
                      child: LanguageWidget(
                        color: Colors.white,
                        onLocaleChanged: (l) =>
                            localeProvider.setLocale(l),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Mobile ───────────────────────────────────────────────────────
  Widget _mobileView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryDark, _primary, Color(0xFF1A7AB5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Particles
          ..._particles.map((p) => Positioned(
                left: p.x * width,
                top: p.y * height,
                child: Opacity(
                  opacity: p.opacity * 0.6,
                  child: Container(
                    width: p.size * 0.7,
                    height: p.size * 0.7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: p.color,
                    ),
                  ),
                ),
              )),

          Positioned(
            top: -50,
            right: -50,
            child: _circle(200, Colors.white.withOpacity(0.04)),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: _circle(160, _accent.withOpacity(0.08)),
          ),

          // Top accent line
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_accent, _accentLight, _purple],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: _accent.withOpacity(0.2),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(
                              'assets/images/logo-white.png',
                              width: 110,
                              height: 80,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _locale.archivingSystem,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 28),
                        _formCard(),
                        const SizedBox(height: 20),
                        LanguageWidget(
                          color: Colors.white,
                          onLocaleChanged: (l) => localeProvider.setLocale(l),
                        ),
                        const SizedBox(height: 12),
                        const VersionBadge(baseColor: _gold),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Form card ────────────────────────────────────────────────────
  Widget _formCard() {
    final bool isDesktop = Responsive.isDesktop(context);
    return Container(
      width: isDesktop ? 400 : double.infinity,
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.12),
            blurRadius: 50,
            spreadRadius: 0,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: _accent.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome text
          Align(
            alignment: Directionality.of(context) == TextDirection.rtl
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _locale.welcomeBack,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2340),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _locale.signInToContinue,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          _label(_locale.userName),
          const SizedBox(height: 6),
          _inputField(
            controller: _userNameController,
            focusNode: userNameFocus,
            hint: _locale.userName,
            icon: Icons.person_outline,
            isPassword: false,
            onSubmit: () => passwordFocus.requestFocus(),
          ),
          const SizedBox(height: 18),

          _label(_locale.password),
          const SizedBox(height: 6),
          _inputField(
            controller: _passwordController,
            focusNode: passwordFocus,
            hint: _locale.password,
            icon: Icons.lock_outline,
            isPassword: true,
            onSubmit: passwordAndEmailCheck,
          ),
          const SizedBox(height: 28),

          _submitButton(),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A2340),
        ),
      );

  Widget _inputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    required bool isPassword,
    required VoidCallback onSubmit,
  }) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, _) {
        final bool focused = focusNode.hasFocus;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: focused ? Colors.white : const Color(0xFFF6F8FC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: focused ? _primary : const Color(0xFFDDE3EE),
              width: focused ? 1.8 : 1,
            ),
            boxShadow: focused
                ? [
                    BoxShadow(
                      color: _primary.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                    BoxShadow(
                      color: _accent.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            autofocus: focusNode == userNameFocus,
            focusNode: focusNode,
            controller: controller,
            obscureText: isPassword ? obsecureText : false,
            // ── Key fix: Next on username, Done on password ──────
            textInputAction:
                isPassword ? TextInputAction.done : TextInputAction.next,
            onFieldSubmitted: (_) => onSubmit(),
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A2340)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              prefixIcon: Icon(icon,
                  size: 18, color: focused ? _primary : Colors.grey.shade400),
              suffixIcon: isPassword
                  ? IconButton(
                      // ── Prevent focus steal on icon tap ─────────
                      focusNode: FocusNode(skipTraversal: true),
                      icon: Icon(
                        obsecureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: Colors.grey.shade400,
                      ),
                      onPressed: () =>
                          setState(() => obsecureText = !obsecureText),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        );
      },
    );
  }

  // ── Submit button with shimmer ───────────────────────────────────
  Widget _submitButton() {
    return AnimatedBuilder(
      animation: _shimmerAnim,
      builder: (context, child) {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : passwordAndEmailCheck,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                gradient: isLoading
                    ? LinearGradient(
                        colors: [
                          _primary.withOpacity(0.7),
                          _primary.withOpacity(0.7),
                        ],
                      )
                    : LinearGradient(
                        colors: const [
                          _primaryDark,
                          _primary,
                          Color(0xFF2196F3),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                        transform: GradientRotation(_shimmerAnim.value),
                      ),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Container(
                alignment: Alignment.center,
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        _locale.signIn,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────
  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  // ── Logic ────────────────────────────────────────────────────────
  void passwordAndEmailCheck() {
    if (_userNameController.text.trim().isEmpty) {
      CustomToastMessage.error(context, _locale.emailReq)
          .then((_) => userNameFocus.requestFocus());

      // showDialog(
      //   context: context,
      //   builder: (context) => ErrorDialog(
      //     icon: Icons.error,
      //     errorTitle: _locale.error,
      //     errorDetails: _locale.emailReq,
      //     color: Colors.red,
      //     statusCode: 100,
      //   ),
      // ).then((_) => userNameFocus.requestFocus());
    } else if (_passwordController.text.trim().isEmpty) {
      CustomToastMessage.error(context, _locale.passReqField)
          .then((_) => passwordFocus.requestFocus());

      // showDialog(
      //   context: context,
      //   builder: (context) => ErrorDialog(
      //     icon: Icons.error,
      //     errorTitle: _locale.error,
      //     errorDetails: _locale.passReqField,
      //     color: Colors.red,
      //     statusCode: 100,
      //   ),
      // ).then((_) => passwordFocus.requestFocus());
    } else {
      logIn();
    }
  }

  logIn() async {
    setState(() => isLoading = true);

    String key = "archiveProj@s2024ASD/Key@team.CT";
    final iv = [0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1];
    final byteArray =
        Uint8List.fromList(iv.map((bit) => bit == 1 ? 0x01 : 0x00).toList());
    String passEncrypted = Encryption.performAesEncryption(
        _passwordController.text, key, byteArray);
    String emailEncrypted = Encryption.performAesEncryption(
        _userNameController.text, key, byteArray);

    LogInModel userModel = LogInModel(emailEncrypted, passEncrypted);
    const storage = FlutterSecureStorage();
    storage.write(key: "userName", value: _userNameController.text);

    await LoginController()
        .logInPost(userModel, AppLocalizations.of(context)!)
        .then((value) async {
      if (value) {
        await SetupController().getSetupList().then((v) async {
          int bolActive = v!.first.bolActive!;
          await storage.write(key: "bolActive", value: bolActive.toString());
        });
        await storage.read(key: "roles").then((value1) {
          if (value1 == USERTYPEADMIN) {
            context.read<ScreenContentProvider>().setPage1(0);
          } else {
            context.read<ScreenContentProvider>().setPage1(1);
          }
          GoRouter.of(context).go(mainScreenRoute);
        });
      }
    });

    if (mounted) setState(() => isLoading = false);
  }
}
