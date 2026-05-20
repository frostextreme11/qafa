import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum CelebrationType {
  qada5,    // Standard milestone (Multiples of 5%)
  qada20,   // Major milestone (Multiples of 20%)
  qada100,  // Ultimate milestone (100% Completed / Lunas)
  water50,  // Hydration halfway milestone (50%)
  water100, // Hydration complete milestone (100%)
}

class CelebrationOverlay extends StatefulWidget {
  final CelebrationType type;
  final int percentage;
  final bool isDark;

  const CelebrationOverlay({
    super.key,
    required this.type,
    required this.percentage,
    required this.isDark,
  });

  // Static helper to display the overlay
  static void show(BuildContext context, {
    required CelebrationType type,
    required int percentage,
    required bool isDark,
  }) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: type != CelebrationType.qada100, // force click okay for 100% lunas
        barrierColor: Colors.black.withOpacity(0.3),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: CelebrationOverlay(
              type: type,
              percentage: percentage,
              isDark: isDark,
            ),
          );
        },
      ),
    );
  }

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay> with TickerProviderStateMixin {
  late AnimationController _cardController;
  late AnimationController _sunburstController;
  late AnimationController _particleController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final List<_PhysicsParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Card entry animation
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeIn),
    );

    // Sunburst rotation animation
    _sunburstController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Particle update ticker controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16), // dummy value
    )..addListener(_updatePhysics);

    _particleController.repeat();

    // Initialize particles based on target celebration type
    _initializeParticles();

    // Trigger card entry
    _cardController.forward();

    // Auto-dismiss standard/small milestones after a few seconds
    if (widget.type == CelebrationType.qada5 || widget.type == CelebrationType.water50) {
      Future.delayed(const Duration(milliseconds: 4000), () {
        if (mounted) {
          _closeOverlay();
        }
      });
    }
  }

  void _closeOverlay() {
    _cardController.reverse().then((_) {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _cardController.dispose();
    _sunburstController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _initializeParticles() {
    int particleCount = 0;
    if (widget.type == CelebrationType.qada5) {
      particleCount = 25; // light rising stars
    } else if (widget.type == CelebrationType.qada20) {
      particleCount = 80; // beautiful falling confetti
    } else if (widget.type == CelebrationType.qada100) {
      particleCount = 180; // giant royal gold & emerald burst
    } else if (widget.type == CelebrationType.water50) {
      particleCount = 35; // gentle rising blue bubbles
    } else if (widget.type == CelebrationType.water100) {
      particleCount = 90; // rich oceanic rising bubbles
    }

    final bool isWater = widget.type == CelebrationType.water50 || widget.type == CelebrationType.water100;
    final bool isUltimate = widget.type == CelebrationType.qada100;
    final bool isStandard = widget.type == CelebrationType.qada5;

    for (int i = 0; i < particleCount; i++) {
      _particles.add(
        _PhysicsParticle.create(
          random: _random,
          isWater: isWater,
          isUltimate: isUltimate,
          isStandard: isStandard,
        ),
      );
    }
  }

  void _updatePhysics() {
    if (!mounted) return;
    setState(() {
      for (var particle in _particles) {
        particle.update(
          random: _random,
          isWater: widget.type == CelebrationType.water50 || widget.type == CelebrationType.water100,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isStandard = widget.type == CelebrationType.qada5 || widget.type == CelebrationType.water50;

    // Background blur details based on Light/Dark
    final Color backdropColor = widget.isDark 
        ? Colors.black.withOpacity(0.55) 
        : Colors.white.withOpacity(0.55);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. Translucent Blur Layer
          GestureDetector(
            onTap: isStandard ? _closeOverlay : null, // standard standard tap outer can close
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: backdropColor,
            ),
          ),

          // 2. Rotating Sunburst Backdrop for major achievements
          if (!isStandard)
            Center(
              child: AnimatedBuilder(
                animation: _sunburstController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _sunburstController.value * 2 * pi,
                    child: CustomPaint(
                      size: const Size(600, 600),
                      painter: _SunburstPainter(
                        color: widget.type == CelebrationType.qada100
                            ? const Color(0xFFFFD700).withOpacity(0.12)
                            : (widget.type == CelebrationType.water100
                                ? const Color(0xFF00B0FF).withOpacity(0.12)
                                : const Color(0xFF4CAF50).withOpacity(0.10)),
                      ),
                    ),
                  );
                },
              ),
            ),

          // 3. Physics Particles Layer (Canvas)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ParticlePainter(particles: _particles, type: widget.type),
              ),
            ),
          ),

          // 4. Milestone Card Details
          Center(
            child: AnimatedBuilder(
              animation: _cardController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: _buildMilestoneCard(size),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard(Size screenSize) {
    switch (widget.type) {
      case CelebrationType.qada5:
        return _buildStandardCard(
          title: 'Alhamdulillah!',
          subtitle: 'Qada Fasting +${widget.percentage}% Completed!',
          desc: 'Setiap langkah kecil membawamu lebih dekat kepada ketaatan yang sempurna.',
          accentColor: const Color(0xFF4CAF50),
        );
      case CelebrationType.water50:
        return _buildStandardCard(
          title: 'Segar & Berkah!',
          subtitle: 'Hydration 50% Terpenuhi!',
          desc: 'Jaga tubuhmu tetap terhidrasi dengan baik demi kesehatan ibadahmu.',
          accentColor: const Color(0xFF03A9F4),
        );
      case CelebrationType.qada20:
        return _buildMajorCard(
          title: 'Luar Biasa!',
          subtitle: 'Pencapaian ${widget.percentage}% Qada Puasa!',
          dalilArabic: 'كُلُّ عَمَلِ ابْنِ آدَمَ لَهُ إِلَّا الصِّيَامَ فَإِنَّهُ لِي وَأَنَا أَجْزِي بِهِ',
          dalilTranslation: '"Setiap amalan kebaikan anak Adam dilipatgandakan... Allah berfirman: Kecuali puasa, karena puasa itu untuk-Ku dan Aku sendiri yang akan membalasnya."',
          dalilSource: 'Hadits Riwayat Bukhari & Muslim',
          motivation: 'MasyaAllah, Anda telah menyelesaikan kelipatan 20% target qada Anda! Tetap istiqomah melunasi kewajiban mulia ini.',
          accentColor: const Color(0xFF2E7D32),
          headerIcon: Icons.workspace_premium_rounded,
        );
      case CelebrationType.water100:
        return _buildMajorCard(
          title: 'Hidrasi Sempurna!',
          subtitle: 'Target Air Minum 100% Tercapai!',
          dalilArabic: 'وَجَعَلْنَا مِنَ الْمَاءِ كُلَّ شَيْءٍ حَيٍّ',
          dalilTranslation: '"Dan dari air Kami jadikan segala sesuatu yang hidup. Maka mengapa mereka tidak juga beriman?"',
          dalilSource: 'Al-Quran - Surah Al-Anbya: 30',
          motivation: 'Alhamdulillah, hari ini tubuhmu mendapat hidrasi yang optimal! Jaga pola hidup bersih dan sehat untuk kelancaran ibadah.',
          accentColor: const Color(0xFF0288D1),
          headerIcon: Icons.water_drop_rounded,
        );
      case CelebrationType.qada100:
        return _buildUltimateCard();
    }
  }

  // --- CARD 1: Standard Card (Kelipatan 5% & Air 50%) ---
  Widget _buildStandardCard({
    required String title,
    required String subtitle,
    required String desc,
    required Color accentColor,
  }) {
    final Color cardBg = widget.isDark ? const Color(0xFF041E24) : Colors.white;
    final Color textColor = widget.isDark ? Colors.white : const Color(0xFF0E2329);
    final Color subTextColor = widget.isDark ? Colors.white70 : Colors.black54;

    return Container(
      width: 320,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: cardBg.withOpacity(0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: accentColor.withOpacity(widget.isDark ? 0.35 : 0.2),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(widget.isDark ? 0.3 : 0.1),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.type == CelebrationType.qada5 ? Icons.star_rounded : Icons.opacity_rounded,
              color: accentColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: accentColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: subTextColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // --- CARD 2: Major Card (Kelipatan 20% & Air 100%) ---
  Widget _buildMajorCard({
    required String title,
    required String subtitle,
    required String dalilArabic,
    required String dalilTranslation,
    required String dalilSource,
    required String motivation,
    required Color accentColor,
    required IconData headerIcon,
  }) {
    final Color cardBg = widget.isDark ? const Color(0xFF02161D) : Colors.white;
    final Color textColor = widget.isDark ? Colors.white : const Color(0xFF0E2329);
    final Color subTextColor = widget.isDark ? Colors.white70 : Colors.black54;

    return Container(
      width: 350,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: cardBg.withOpacity(0.95),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: accentColor.withOpacity(widget.isDark ? 0.4 : 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(widget.isDark ? 0.25 : 0.08),
            blurRadius: 36,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Elegant premium badge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor, accentColor.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Icon(headerIcon, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: accentColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 20),
          // Dalil Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
              ),
            ),
            child: Column(
              children: [
                Text(
                  dalilArabic,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.6,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  dalilTranslation,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: subTextColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dalilSource,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            motivation,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: subTextColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          // Continue Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              onPressed: _closeOverlay,
              child: Text(
                'MasyaAllah, Siap!',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- CARD 3: Ultimate Card (100% Qada Lunas) ---
  Widget _buildUltimateCard() {
    final Color cardBg = widget.isDark ? const Color(0xFF02191F) : Colors.white;
    final Color textColor = widget.isDark ? Colors.white : const Color(0xFF0E2329);
    final Color subTextColor = widget.isDark ? Colors.white70 : Colors.black54;
    const Color goldColor = Color(0xFFFFD700);
    const Color emeraldColor = Color(0xFF00E676);

    return Container(
      width: 360,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: cardBg.withOpacity(0.96),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(
          color: goldColor.withOpacity(widget.isDark ? 0.5 : 0.35),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: emeraldColor.withOpacity(0.15),
            blurRadius: 40,
            spreadRadius: -2,
            offset: const Offset(-8, -8),
          ),
          BoxShadow(
            color: goldColor.withOpacity(0.15),
            blurRadius: 40,
            spreadRadius: -2,
            offset: const Offset(8, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Crown / Star badge
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [goldColor, emeraldColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: goldColor.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: const Icon(Icons.workspace_premium_rounded, color: Colors.black, size: 40),
          ),
          const SizedBox(height: 24),
          Text(
            'MASYAALLAH, LUNAS!',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: goldColor,
              letterSpacing: 1.0,
              shadows: [
                Shadow(
                  color: goldColor.withOpacity(0.4),
                  blurRadius: 6,
                )
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '100% Target Qada Puasa Tercapai!',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 20),
          // Dalil Pintu Ar-Rayyan
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: emeraldColor.withOpacity(widget.isDark ? 0.04 : 0.03),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: emeraldColor.withOpacity(0.15),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'إِنَّ فِي الْجَنَّةِ بَابًا يُقَالُ لَهُ الرَّيَّانُ يَدْخُلُ مِنْهُ الصَّائِمُونَ يَوْمَ الْقِيَامَةِ لَا يَدْخُلُ مِنْهُ أَحَدٌ غَيْرُهُمْ',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    height: 1.7,
                    color: emeraldColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '"Sesungguhnya di surga ada sebuah pintu yang bernama Ar-Rayyan. Pada hari kiamat orang-orang yang berpuasa akan masuk melaluinya; tidak ada seorang pun selain mereka yang masuk melaluinya."',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: subTextColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hadits Riwayat Bukhari & Muslim',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: goldColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Alhamdulillah! Anda telah melunasi seluruh kewajiban puasa qada Anda. Semoga amal ibadah ini diterima di sisi Allah SWT dan mengantarkan Anda memasuki pintu Ar-Rayyan kelak.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: subTextColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          // Certificate Claim Button
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: emeraldColor.withOpacity(0.3),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: emeraldColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                onPressed: _closeOverlay,
                child: Text(
                  'Alhamdulillah, Terima Kasih!',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- PARTICLE OBJECTS FOR ENGINE ---
class _PhysicsParticle {
  late double x;
  late double y;
  late double vx;
  late double vy;
  late double size;
  late Color color;
  late double rotation;
  late double rotationSpeed;
  late double opacity;
  late bool isStar;
  late bool isBubble;

  _PhysicsParticle.create({
    required Random random,
    required bool isWater,
    required bool isUltimate,
    required bool isStandard,
  }) {
    isBubble = isWater;
    isStar = !isWater && (isStandard || isUltimate && random.nextDouble() > 0.4);

    // Initial position
    if (isBubble) {
      // water bubbles rise from bottom half
      x = random.nextDouble() * 400; // will be scaled to screen in painter
      y = 600 + random.nextDouble() * 200;
      vx = -0.5 + random.nextDouble() * 1.0;
      vy = -1.5 - random.nextDouble() * 2.0; // rise speed
      size = 4 + random.nextDouble() * 14;
      opacity = 0.2 + random.nextDouble() * 0.5;
      rotation = 0;
      rotationSpeed = 0;
      color = Colors.cyanAccent.withOpacity(opacity);
    } else {
      // Confetti falls from top
      x = random.nextDouble() * 400;
      y = -50 - random.nextDouble() * 150;
      vx = -1.5 + random.nextDouble() * 3.0;
      vy = 2.0 + random.nextDouble() * 3.0; // fall speed
      size = 6 + random.nextDouble() * 10;
      opacity = 0.7 + random.nextDouble() * 0.3;
      rotation = random.nextDouble() * 2 * pi;
      rotationSpeed = -0.1 + random.nextDouble() * 0.2;

      // Color palette based on milestone
      if (isUltimate) {
        // Emerald & Gold
        color = random.nextBool()
            ? const Color(0xFFFFD700) // gold
            : const Color(0xFF00E676); // emerald
      } else {
        // Multi-color confetti
        final colors = [
          const Color(0xFF4CAF50),
          const Color(0xFFFFEB3B),
          const Color(0xFFFF5722),
          const Color(0xFF00BCD4),
          const Color(0xFFE91E63),
          const Color(0xFF9C27B0),
        ];
        color = colors[random.nextInt(colors.length)];
      }
    }
  }

  void update({required Random random, required bool isWater}) {
    x += vx;
    y += vy;
    rotation += rotationSpeed;

    if (isWater) {
      // Bubbles rise and drift sideways using sine wave
      vx += sin(y / 30) * 0.05;
      // If float out of top, reset to bottom
      if (y < -50) {
        y = 700 + random.nextDouble() * 100;
        x = random.nextDouble() * 400;
        vy = -1.5 - random.nextDouble() * 2.0;
      }
    } else {
      // Confetti falls down, drifts sideways, spins
      vx += sin(y / 20) * 0.08;
      // If falls out of bottom, reset to top
      if (y > 900) {
        y = -50 - random.nextDouble() * 100;
        x = random.nextDouble() * 400;
        vy = 2.0 + random.nextDouble() * 3.0;
      }
    }
  }
}

// --- PARTICLE CUSTOM PAINTER ---
class _ParticlePainter extends CustomPainter {
  final List<_PhysicsParticle> particles;
  final CelebrationType type;

  _ParticlePainter({required this.particles, required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      // Map normalized 0-400 coordinate space to actual screen size
      final double screenX = (p.x / 400.0) * size.width;
      final double screenY = (p.y / 800.0) * size.height;

      final paint = Paint()
        ..color = p.color
        ..style = PaintingStyle.fill;

      if (p.isBubble) {
        // Draw double layers for glossy water bubbles
        final bubblePaint = Paint()
          ..color = p.color.withOpacity(0.25)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(screenX, screenY), p.size, bubblePaint);

        // Highlight ring
        final strokePaint = Paint()
          ..color = Colors.white.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawCircle(Offset(screenX, screenY), p.size, strokePaint);

        // Little interior gloss spot
        final spotPaint = Paint()
          ..color = Colors.white.withOpacity(0.6)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(screenX - p.size * 0.35, screenY - p.size * 0.35), p.size * 0.2, spotPaint);
      } else if (p.isStar) {
        // Draw beautiful 5-point star
        canvas.save();
        canvas.translate(screenX, screenY);
        canvas.rotate(p.rotation);
        
        final starPath = _createStarPath(p.size);
        canvas.drawPath(starPath, paint);
        
        // Star glow highlight
        final glowPaint = Paint()
          ..color = p.color.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawPath(starPath, glowPaint);

        canvas.restore();
      } else {
        // Draw falling rectangle confetti
        canvas.save();
        canvas.translate(screenX, screenY);
        canvas.rotate(p.rotation);
        
        final rect = Rect.fromCenter(center: Offset.zero, width: p.size * 1.5, height: p.size * 0.7);
        canvas.drawRect(rect, paint);
        
        canvas.restore();
      }
    }
  }

  Path _createStarPath(double size) {
    final path = Path();
    final double halfSize = size / 2;
    const double angle = indexPi; // 36 degrees in rad
    
    // Draw 5 points star
    for (int i = 0; i < 10; i++) {
      final double r = i.isEven ? size : halfSize;
      final double x = r * cos(i * angle);
      final double y = r * sin(i * angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  static const double indexPi = 36.0 * pi / 180.0;

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return true; // repainted continuously via physics ticker
  }
}

// --- SUNBURST BACKGROUND CUSTOM PAINTER ---
class _SunburstPainter extends CustomPainter {
  final Color color;

  _SunburstPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const int rayCount = 18;
    const double sweepAngle = (2 * pi / rayCount) / 2;

    for (int i = 0; i < rayCount; i++) {
      final startAngle = i * (2 * pi / rayCount);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SunburstPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
