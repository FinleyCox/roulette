import 'dart:math';
import 'package:flutter/material.dart';

class Particle {
  Offset position;
  Color color;
  double size;
  double speed;
  double angle;
  double life;
  double decay;

  Particle({
    required this.position,
    required this.color,
    required this.size,
    required this.speed,
    required this.angle,
    required this.life,
    required this.decay,
  });

  void update() {
    position += Offset(cos(angle) * speed, sin(angle) * speed);
    life -= decay;
    size *= 0.95; // Shrink over time
  }
}

class ScratchEffectOverlay extends StatefulWidget {
  final Stream<Offset>? touchStream;

  const ScratchEffectOverlay({super.key, this.touchStream});

  @override
  State<ScratchEffectOverlay> createState() => _ScratchEffectOverlayState();
}

class _ScratchEffectOverlayState extends State<ScratchEffectOverlay>
    with SingleTickerProviderStateMixin {
  final List<Particle> particles = [];
  late AnimationController _controller;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 100),
          )
          ..addListener(_updateParticles)
          ..repeat();

    widget.touchStream?.listen((position) {
      _emitParticles(position);
    });
  }

  void _emitParticles(Offset position) {
    // スクラッチの削りカスのようなパーティクル
    for (int i = 0; i < 3; i++) {
      particles.add(
        Particle(
          position: position,
          color: Colors.grey[400]!,
          size: _random.nextDouble() * 4 + 2,
          speed: _random.nextDouble() * 2 + 1,
          angle: _random.nextDouble() * 2 * pi,
          life: 1.0,
          decay: 0.05 + _random.nextDouble() * 0.05,
        ),
      );
    }
  }

  void _updateParticles() {
    for (var i = particles.length - 1; i >= 0; i--) {
      particles[i].update();
      if (particles[i].life <= 0) {
        particles.removeAt(i);
      }
    }
    if (particles.isNotEmpty) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: ParticlePainter(particles),
        size: Size.infinite,
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.life)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(particle.position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
