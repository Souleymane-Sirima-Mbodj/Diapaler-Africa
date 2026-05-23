import 'package:flutter/material.dart';
import '../data/donnees_mentors.dart';
import '../theme/theme_app.dart';

/// Stepper 3 étapes pour déposer un pitch (correspond à l'Écran 8 du doc).
class PitchPage extends StatefulWidget {
  const PitchPage({super.key});

  @override
  State<PitchPage> createState() => _PitchPageState();
}

class _PitchPageState extends State<PitchPage> {
  int _step = 0;
  static const _total = 3;

  final _title = TextEditingController();
  String? _sector;
  final _description = TextEditingController();
  final _amount = TextEditingController();

  static const _steps = [
    ('Informations', 'Présente ton projet en quelques mots'),
    ('Détails', 'Secteur, description, ambition'),
    ('Documents', 'Pitch deck, vidéo, besoin de financement'),
  ];

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < _total - 1) {
      setState(() => _step++);
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Pitch déposé ! Visible auprès des mentors.'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Étape ${_step + 1} / $_total · ${_steps[_step].$1}'),
        leading: IconButton(
          onPressed: () {
            if (_step > 0) {
              setState(() => _step--);
            } else {
              Navigator.of(context).pop();
            }
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _StepBar(step: _step, total: _total),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (c, a) =>
                    FadeTransition(opacity: a, child: c),
                child: _buildStep(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(
                    _step == _total - 1
                        ? 'PUBLIER MON PITCH'
                        : 'CONTINUER',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    return Padding(
      key: ValueKey(_step),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        children: [
          const SizedBox(height: 8),
          Text(
            _steps[_step].$2,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 22),
          if (_step == 0) ..._step1(),
          if (_step == 1) ..._step2(),
          if (_step == 2) ..._step3(),
        ],
      ),
    );
  }

  List<Widget> _step1() => [
        const _Label('Titre du projet'),
        const SizedBox(height: 6),
        TextField(
          controller: _title,
          decoration: const InputDecoration(
            hintText: 'Ex. Téranga Mode',
            prefixIcon: Icon(Icons.title_rounded, color: AppColors.subtle),
          ),
        ),
        const SizedBox(height: 16),
        const _Label('Mon élévator pitch (1 phrase)'),
        const SizedBox(height: 6),
        TextField(
          controller: _description,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Ce que tu fais, pour qui, et pourquoi.',
          ),
        ),
      ];

  List<Widget> _step2() => [
        const _Label('Secteur d\'activité'),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _sector,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.subtle),
          decoration: const InputDecoration(
            hintText: 'Choisis un secteur',
            prefixIcon:
                Icon(Icons.category_rounded, color: AppColors.subtle),
          ),
          items: allSectors
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(
                      s,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.navyDeep,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _sector = v),
        ),
        const SizedBox(height: 16),
        const _Label('Description détaillée'),
        const SizedBox(height: 6),
        const TextField(
          maxLines: 6,
          decoration: InputDecoration(
            hintText: 'Marché, équipe, traction, vision…',
          ),
        ),
      ];

  List<Widget> _step3() => [
        const _Label('Besoin de financement (FCFA)'),
        const SizedBox(height: 6),
        TextField(
          controller: _amount,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: '5 000 000',
            prefixIcon:
                Icon(Icons.payments_rounded, color: AppColors.subtle),
          ),
        ),
        const SizedBox(height: 18),
        const _UploadTile(
          icon: Icons.picture_as_pdf_rounded,
          label: 'Pitch deck (PDF)',
          subtitle: 'Glisse ton fichier ou tape pour parcourir',
          color: AppColors.red,
        ),
        const SizedBox(height: 10),
        const _UploadTile(
          icon: Icons.videocam_rounded,
          label: 'Vidéo de présentation (optionnel)',
          subtitle: '1 minute max · MP4',
          color: AppColors.blue,
        ),
      ];
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.navyDeep,
        ),
      );
}

class _StepBar extends StatelessWidget {
  final int step;
  final int total;
  const _StepBar({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      child: Row(
        children: List.generate(total, (i) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                height: 5,
                decoration: BoxDecoration(
                  color: i <= step ? AppColors.amber : AppColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _UploadTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  const _UploadTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
  });

  @override
  State<_UploadTile> createState() => _UploadTileState();
}

class _UploadTileState extends State<_UploadTile> {
  bool _selected = false;

  Widget _content() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: _selected ? 0.2 : 0.13),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _selected ? Icons.check_circle_rounded : widget.icon,
              color: widget.color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navyDeep,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _selected ? 'Fichier ajouté ✓' : widget.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: _selected ? widget.color : AppColors.muted,
                    fontWeight:
                        _selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            _selected ? Icons.check_rounded : Icons.add_rounded,
            color: _selected ? widget.color : AppColors.muted,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() => _selected = !_selected),
      child: _selected
          ? Container(
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.color, width: 1.5),
              ),
              child: _content(),
            )
          : DottedBorder(child: _content()),
    );
  }
}

class DottedBorder extends StatelessWidget {
  final Widget child;
  const DottedBorder({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedPainter(),
      child: child,
    );
  }
}

class _DottedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Offset.zero & size, const Radius.circular(12)));
    final dashed = Path();
    const dashWidth = 6.0;
    const dashGap = 4.0;
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        dashed.addPath(
          metric.extractPath(dist, dist + dashWidth),
          Offset.zero,
        );
        dist += dashWidth + dashGap;
      }
    }
    canvas.drawPath(dashed, paint);
  }

  @override
  bool shouldRepaint(_DottedPainter old) => false;
}
