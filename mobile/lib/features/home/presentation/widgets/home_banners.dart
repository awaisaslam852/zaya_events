import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/localized.dart';
import '../../../../core/widgets/property_card.dart';
import '../cubit/banners_cubit.dart';

class HomeBanners extends StatefulWidget {
  const HomeBanners({super.key});

  @override
  State<HomeBanners> createState() => _HomeBannersState();
}

class _HomeBannersState extends State<HomeBanners> {
  static const _loopStart = 1000;
  final _page = PageController(initialPage: _loopStart);
  Timer? _timer;
  int _index = 0;
  int _count = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _page.dispose();
    super.dispose();
  }

  void _syncAutoPlay(int count) {
    _count = count;
    _timer?.cancel();
    if (count < 2) {
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_page.hasClients) {
        return;
      }
      _page.nextPage(duration: const Duration(milliseconds: 450), curve: Curves.easeInOut);
    });
  }

  int _realIndex(int page) {
    if (_count == 0) {
      return 0;
    }
    return page % _count;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BannersCubit, BannersState>(
      listener: (context, state) => _syncAutoPlay(state.items.length),
      builder: (context, state) {
        if (state.items.isEmpty) {
          return const SizedBox.shrink();
        }
        if (_count != state.items.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _syncAutoPlay(state.items.length);
            }
          });
        }
        final looping = state.items.length > 1;
        return Column(
          children: [
            SizedBox(
              height: 168,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (!looping) {
                    return false;
                  }
                  if (notification is ScrollStartNotification && notification.dragDetails != null) {
                    _timer?.cancel();
                  } else if (notification is ScrollEndNotification) {
                    _syncAutoPlay(state.items.length);
                  }
                  return false;
                },
                child: PageView.builder(
                  controller: _page,
                  onPageChanged: (value) => setState(() => _index = _realIndex(value)),
                  itemCount: looping ? null : 1,
                  itemBuilder: (context, index) {
                    final banner = state.items[_realIndex(index)];
                    final image = resolveMediaUrl(banner['imageKey']?.toString() ?? '');
                    final locale = Localizations.localeOf(context).languageCode;
                    final title = localized(banner['title'], locale);
                    final subtitle = localized(banner['subtitle'], locale);
                    final link = banner['linkUrl']?.toString();
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Material(
                        color: AppTheme.navy,
                        borderRadius: BorderRadius.circular(16),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: link == null || link.isEmpty
                              ? null
                              : () => launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (image.isNotEmpty)
                                CachedNetworkImage(imageUrl: image, fit: BoxFit.cover)
                              else
                                const ColoredBox(color: AppTheme.navy),
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Color(0xCC003580)],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                                    ),
                                    if (subtitle.isNotEmpty)
                                      Text(subtitle, style: const TextStyle(color: Colors.white70)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (state.items.length > 1) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < state.items.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: i == _index ? 16 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: i == _index ? AppTheme.navy : const Color(0xFFB7C4D6),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
