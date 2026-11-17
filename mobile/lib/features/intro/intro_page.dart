import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/app_role.dart';
import '../../core/di/injection.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_mark.dart';
import '../../core/widgets/language_picker.dart';
import '../../core/widgets/zaya_fields.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../l10n/app_localizations.dart';
import 'intro_prefs.dart';
import 'intro_slides.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key, this.onFinished});

  final VoidCallback? onFinished;

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<IntroSlide> _slides(AppLocalizations l10n) => introSlides(l10n);

  Future<void> _finish() async {
    if (sl.isRegistered<SharedPreferences>()) {
      await IntroPrefs.complete(sl<SharedPreferences>());
    }
    if (!mounted) {
      return;
    }
    if (widget.onFinished != null) {
      widget.onFinished!();
      return;
    }
    if (context.canPop()) {
      context.pop();
      return;
    }
    final home = sl<AuthBloc>().state.maybeWhen(
      authenticated: (user) => parseAppRole(user.role) == AppRole.vendor ? '/vendor/dashboard' : '/customer/home',
      orElse: () => '/login',
    );
    context.go(home);
  }

  Future<void> _next(int lastIndex) async {
    if (_index >= lastIndex) {
      await _finish();
      return;
    }
    await _controller.nextPage(duration: const Duration(milliseconds: 380), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final slides = _slides(l10n);
    final last = slides.length - 1;
    final isLast = _index >= last;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF00183D), Color(0xFF003580), Color(0xFF0B5BB5)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                child: Row(
                  children: [
                    const BrandMark(size: 40),
                    const SizedBox(width: 10),
                    const Text(
                      'ZAYA',
                      style: TextStyle(
                        color: AppTheme.yellow,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    const LanguageHeaderActions(),
                    TextButton(
                      onPressed: _finish,
                      child: Text(l10n.skip, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: slides.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, index) => _IntroPane(slide: slides[index], showLogo: index == 0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < slides.length; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 240),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: i == _index ? 28 : 8,
                            decoration: BoxDecoration(
                              color: i == _index ? AppTheme.yellow : Colors.white.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ZayaPrimaryButton(
                      label: isLast ? l10n.getStarted : l10n.next,
                      icon: isLast ? Icons.arrow_forward : Icons.chevron_right,
                      onPressed: () => _next(last),
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
}

class _IntroPane extends StatelessWidget {
  const _IntroPane({required this.slide, required this.showLogo});

  final IntroSlide slide;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360, maxHeight: 340),
                child: _IntroArt(slide: slide, showLogo: showLogo),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            slide.eyebrow.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.yellow,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800, height: 1.15),
          ),
          const SizedBox(height: 12),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _IntroArt extends StatelessWidget {
  const _IntroArt({required this.slide, required this.showLogo});

  final IntroSlide slide;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            top: 18,
            left: 28,
            child: _Orb(color: slide.accent.withValues(alpha: 0.28), size: 72),
          ),
          Positioned(
            bottom: 26,
            right: 22,
            child: _Orb(color: Colors.white.withValues(alpha: 0.08), size: 92),
          ),
          Container(
            width: 168,
            height: 168,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(44),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 28, offset: const Offset(0, 16)),
              ],
            ),
            child: Center(
              child: showLogo
                  ? const BrandMark(size: 96)
                  : Icon(slide.icon, size: 78, color: slide.accent),
            ),
          ),
          Positioned(top: 28, right: 36, child: _Satellite(icon: slide.satellites[0])),
          Positioned(left: 22, child: _Satellite(icon: slide.satellites[1])),
          Positioned(bottom: 34, child: _Satellite(icon: slide.satellites[2])),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _Satellite extends StatelessWidget {
  const _Satellite({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.16), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: Icon(icon, color: AppTheme.navy),
    );
  }
}
