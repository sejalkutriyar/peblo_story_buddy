import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/story_provider.dart';
import '../widgets/robot_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _scoreBounceController;
  late Animation<double> _scoreBounceAnimation;
  int _lastShakeCount = 0;
  int _lastScore = 120;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _scoreBounceController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _scoreBounceAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _scoreBounceController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _shakeController.dispose();
    _scoreBounceController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward(from: 0).then((_) => _shakeController.reverse());
    HapticFeedback.mediumImpact();
  }

  void _triggerScoreBounce() {
    HapticFeedback.lightImpact();
    _scoreBounceController.forward(from: 0).then((_) {
      _scoreBounceController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StoryProvider>(
      builder: (context, provider, _) {
        if (provider.showSuccess &&
            _confettiController.state != ConfettiControllerState.playing) {
          _confettiController.play();
        }
        if (provider.shakeCount != _lastShakeCount) {
          _lastShakeCount = provider.shakeCount;
          _triggerShake();
        }
        if (provider.score != _lastScore) {
          _lastScore = provider.score;
          _triggerScoreBounce();
        }

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF6FB7EA),
                  Color(0xFF9FCFE0),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _SceneryPainter(),
                    ),
                  ),
                ),
                SafeArea(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Column(
                          children: [
                            _buildHeader(provider),
                            const SizedBox(height: 8),
                            _buildBuddySection(provider),
                            const SizedBox(height: 18),
                            _buildStoryCard(provider),
                            const SizedBox(height: 16),
                            _buildReadButton(provider),
                            const SizedBox(height: 16),
                            if (provider.quizVisible)
                              _buildQuizSection(provider),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: ConfettiWidget(
                          confettiController: _confettiController,
                          blastDirectionality: BlastDirectionality.explosive,
                          numberOfParticles: 30,
                          colors: const [
                            Color(0xFFFF6B35),
                            Color(0xFF9B59B6),
                            Color(0xFF3498DB),
                            Color(0xFF2ECC71),
                            Color(0xFFF1C40F),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(StoryProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Peblo',
            style: GoogleFonts.baloo2(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF5B2C8E),
            ),
          ),
          AnimatedBuilder(
            animation: _scoreBounceAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scoreBounceAnimation.value,
                child: child,
              );
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text('${provider.score}',
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: const Color(0xFF5B2C8E))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuddySection(StoryProvider provider) {
    final isHappy = provider.showSuccess;
    return SizedBox(
      height: 230,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            child: RobotWidget(isWinking: !isHappy, size: 150),
          ),
          Positioned(
            top: 6,
            right: 4,
            child: _buildSpeechBubble(
              isHappy
                  ? "Great job!\nYou're amazing!"
                  : "Hi there!\nLet's read a story together!",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeechBubble(String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 190),
      child: CustomPaint(
        painter: _BubblePainter(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          child: Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF3D2C5C),
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoryCard(StoryProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E5FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text("Today's Story",
                    style: GoogleFonts.nunito(
                        color: const Color(0xFF6C3483),
                        fontWeight: FontWeight.w800,
                        fontSize: 13)),
              ),
              Text(
                  'Story ${provider.currentStoryIndex + 1} of ${provider.stories.length}',
                  style: GoogleFonts.nunito(
                      fontSize: 12, color: Colors.black38)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2C5F4D), Color(0xFF1A3D31)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.auto_stories_rounded,
                        color: Colors.white70, size: 28),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.8),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  provider.storyText,
                  style: GoogleFonts.nunito(
                      fontSize: 14.5,
                      height: 1.55,
                      color: const Color(0xFF3D2C5C),
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadButton(StoryProvider provider) {
    String label = 'Read Me a Story';
    List<Color> gradient = const [Color(0xFFFFD93D), Color(0xFFFFA800)];
    IconData icon = Icons.volume_up_rounded;

    if (provider.audioState == AudioState.loading) {
      label = 'Loading...';
      gradient = const [Color(0xFFFFB870), Color(0xFFFF8C42)];
      icon = Icons.hourglass_empty_rounded;
    } else if (provider.audioState == AudioState.playing) {
      label = 'Playing...';
      gradient = const [Color(0xFF6FCF97), Color(0xFF2ECC71)];
      icon = Icons.graphic_eq_rounded;
    } else if (provider.audioState == AudioState.completed) {
      label = 'Story Complete!';
      gradient = const [Color(0xFF6FCF97), Color(0xFF27AE60)];
      icon = Icons.check_circle_rounded;
    } else if (provider.audioState == AudioState.error) {
      label = 'Oops! Tap to retry';
      gradient = const [Color(0xFFFF8787), Color(0xFFE74C3C)];
      icon = Icons.refresh_rounded;
    }

    return GestureDetector(
      onTap: () {
        if (provider.audioState == AudioState.error) {
          provider.retryAudio();
        } else {
          provider.playStory();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
                color: gradient[1].withOpacity(0.45),
                blurRadius: 16,
                offset: const Offset(0, 8))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: Colors.white),
            const SizedBox(width: 10),
            Text(label,
                style: GoogleFonts.nunito(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizSection(StoryProvider provider) {
    if (provider.showSuccess) {
      return _buildSuccessCard(provider);
    }

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 8))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8E44AD), Color(0xFF6C3483)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.help_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Text("Let's Answer!",
                    style: GoogleFonts.nunito(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF5B2C8E))),
              ],
            ),
            const SizedBox(height: 14),
            Text(provider.quiz.question,
                style: GoogleFonts.nunito(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF3D2C5C))),
            const SizedBox(height: 16),
            ...List.generate(provider.quiz.options.length, (index) {
              final option = provider.quiz.options[index];
              final letters = ['A', 'B', 'C', 'D', 'E'];
              final colors = [
                const Color(0xFFE74C3C),
                const Color(0xFF27AE60),
                const Color(0xFF2E86C1),
                const Color(0xFFF39C12),
                const Color(0xFF8E44AD),
              ];
              final isSelected = provider.selectedAnswer == option;
              final isWrong = isSelected && !provider.isCorrect;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => provider.checkAnswer(option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color:
                          isWrong ? const Color(0xFFFEEAEA) : Colors.white,
                      border: Border.all(
                        color: isWrong
                            ? const Color(0xFFE74C3C)
                            : const Color(0xFFE5E5EA),
                        width: isWrong ? 2 : 1.5,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: colors[index % colors.length],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(letters[index],
                                style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(option,
                            style: GoogleFonts.nunito(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF3D2C5C))),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessCard(StoryProvider provider) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEAFAF1), Color(0xFFE0F7E9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF6FCF97), width: 2),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF6FCF97).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 6),
          Text('Wahoo! You got it!',
              style: GoogleFonts.baloo2(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A7A3C))),
          const SizedBox(height: 4),
          Text("Pip's gear was BLUE! Great memory!",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2E7D32))),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('⭐', style: TextStyle(fontSize: 30)),
              Text('⭐', style: TextStyle(fontSize: 30)),
              Text('⭐', style: TextStyle(fontSize: 30)),
            ],
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () => provider.claimPoints(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: provider.pointsButtonPressed
                      ? [const Color(0xFF1A7A3C), const Color(0xFF155C2C)]
                      : [const Color(0xFF6FCF97), const Color(0xFF27AE60)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF27AE60).withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                provider.pointsButtonPressed
                    ? 'Points collected ✓'
                    : '+10 Peblo Points! 🏆',
                style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => provider.nextStory(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8E44AD), Color(0xFF6C3483)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C3483).withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Next Story',
                      style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 19),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height - 10),
      const Radius.circular(18),
    );

    final path = Path()..addRRect(rrect);

    final tailPath = Path()
      ..moveTo(28, size.height - 10)
      ..lineTo(16, size.height)
      ..lineTo(42, size.height - 10)
      ..close();

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(tailPath, shadowPaint);
    canvas.drawPath(path, paint);
    canvas.drawPath(tailPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SceneryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _drawCloud(canvas, Offset(size.width * 0.12, 70), 60);
    _drawCloud(canvas, Offset(size.width * 0.85, 110), 45);
    _drawCloud(canvas, Offset(size.width * 0.55, 50), 35);

    _drawSparkle(canvas, Offset(size.width * 0.25, 160), 10);
    _drawSparkle(canvas, Offset(size.width * 0.75, 200), 7);

    final hillPaint = Paint()
      ..color = const Color(0xFF9BDDB0).withOpacity(0.85);
    final hillPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height - 90)
      ..quadraticBezierTo(size.width * 0.25, size.height - 150,
          size.width * 0.5, size.height - 100)
      ..quadraticBezierTo(size.width * 0.75, size.height - 50, size.width,
          size.height - 110)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(hillPath, hillPaint);

    final hillPaint2 = Paint()
      ..color = const Color(0xFF7AC18C).withOpacity(0.9);
    final hillPath2 = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height - 50)
      ..quadraticBezierTo(size.width * 0.3, size.height - 90,
          size.width * 0.6, size.height - 55)
      ..quadraticBezierTo(
          size.width * 0.85, size.height - 25, size.width, size.height - 60)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(hillPath2, hillPaint2);

    _drawTree(canvas, Offset(size.width * 0.12, size.height - 55), 28);
    _drawTree(canvas, Offset(size.width * 0.88, size.height - 40), 22);
  }

  void _drawCloud(Canvas canvas, Offset center, double size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.45);
    canvas.drawCircle(center, size * 0.5, paint);
    canvas.drawCircle(
        center + Offset(size * 0.45, size * 0.1), size * 0.38, paint);
    canvas.drawCircle(
        center + Offset(-size * 0.45, size * 0.12), size * 0.34, paint);
  }

  void _drawSparkle(Canvas canvas, Offset center, double size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.8);
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..lineTo(center.dx + size * 0.25, center.dy - size * 0.25)
      ..lineTo(center.dx + size, center.dy)
      ..lineTo(center.dx + size * 0.25, center.dy + size * 0.25)
      ..lineTo(center.dx, center.dy + size)
      ..lineTo(center.dx - size * 0.25, center.dy + size * 0.25)
      ..lineTo(center.dx - size, center.dy)
      ..lineTo(center.dx - size * 0.25, center.dy - size * 0.25)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawTree(Canvas canvas, Offset base, double size) {
    final trunkPaint = Paint()..color = const Color(0xFF7A5230);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(base.dx, base.dy + size * 0.3),
            width: size * 0.18,
            height: size * 0.6),
        const Radius.circular(3),
      ),
      trunkPaint,
    );
    final leafPaint = Paint()..color = const Color(0xFF4FA873);
    canvas.drawCircle(
        Offset(base.dx, base.dy - size * 0.3), size * 0.55, leafPaint);
    canvas.drawCircle(Offset(base.dx - size * 0.3, base.dy - size * 0.05),
        size * 0.4, leafPaint);
    canvas.drawCircle(Offset(base.dx + size * 0.3, base.dy - size * 0.05),
        size * 0.4, leafPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}