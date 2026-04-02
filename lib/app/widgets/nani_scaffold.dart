import 'package:flutter/material.dart';
import 'package:nursing_nani_app/app/theme/app_theme.dart';

class NaniScaffold extends StatelessWidget {
  const NaniScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
    this.actions,
    this.bottomSpacing = 132,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final List<Widget>? actions;
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: _NaniBackdrop()),
        SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 18, 20, bottomSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    if (actions != null) ...actions!,
                  ],
                ),
                const SizedBox(height: 24),
                child,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NaniBackdrop extends StatelessWidget {
  const _NaniBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.page),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -60,
            child: _Orb(
              size: 240,
              color: AppPalette.sky.withValues(alpha: 0.55),
            ),
          ),
          Positioned(
            top: 160,
            left: -80,
            child: _Orb(
              size: 220,
              color: AppPalette.mint.withValues(alpha: 0.6),
            ),
          ),
          Positioned(
            bottom: 60,
            right: -80,
            child: _Orb(
              size: 260,
              color: AppPalette.sand.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}