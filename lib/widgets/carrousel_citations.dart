import 'dart:async';
import 'package:flutter/material.dart';
import '../data/citations.dart';
import '../theme/theme_app.dart';

/// Carrousel auto-rotatif de citations. `onDark = true` pour rendu sur fond
/// navy (wordmark, splash). `onDark = false` pour rendu carte sur fond clair.
class QuoteCarousel extends StatefulWidget {
  final bool onDark;
  final Duration interval;
  final double height;

  const QuoteCarousel({
    super.key,
    this.onDark = false,
    this.interval = const Duration(seconds: 3),
    this.height = 130,
  });

  @override
  State<QuoteCarousel> createState() => _QuoteCarouselState();
}

class _QuoteCarouselState extends State<QuoteCarousel> {
  late final PageController _ctrl;
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(viewportFraction: 1.0);
    _timer = Timer.periodic(widget.interval, (_) {
      if (!mounted) return;
      _index = (_index + 1) % quotes.length;
      _ctrl.animateToPage(
        _index,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _ctrl,
              onPageChanged: (i) => setState(() => _index = i),
              itemCount: quotes.length,
              itemBuilder: (_, i) =>
                  _QuoteSlide(quote: quotes[i], onDark: widget.onDark),
            ),
          ),
          const SizedBox(height: 10),
          _Dots(index: _index, count: quotes.length, onDark: widget.onDark),
        ],
      ),
    );
  }
}

class _QuoteSlide extends StatelessWidget {
  final Quote quote;
  final bool onDark;
  const _QuoteSlide({required this.quote, required this.onDark});

  @override
  Widget build(BuildContext context) {
    final textColor = onDark ? Colors.white : AppColors.navyDeep;
    final mutedColor = onDark ? Colors.white70 : AppColors.muted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '“ ${quote.text} ”',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              color: textColor,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '— ${quote.author}  ${quote.emoji}',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: onDark ? AppColors.flagYellow : AppColors.amber,
              letterSpacing: 0.3,
            ),
          ),
          Text(
            quote.role,
            style: TextStyle(fontSize: 10.5, color: mutedColor),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int index;
  final int count;
  final bool onDark;
  const _Dots({required this.index, required this.count, required this.onDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active
                ? (onDark ? AppColors.flagYellow : AppColors.navy)
                : (onDark ? Colors.white24 : AppColors.border),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}
