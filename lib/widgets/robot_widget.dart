import 'package:flutter/material.dart';

class RobotWidget extends StatefulWidget {
  final bool isWinking;
  final double size;

  const RobotWidget({super.key, this.isWinking = true, this.size = 160});

  @override
  State<RobotWidget> createState() => _RobotWidgetState();
}

class _RobotWidgetState extends State<RobotWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: child,
        );
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size * 1.1,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            // Antenna
            Positioned(
              top: 0,
              child: Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A5568),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Positioned(
              top: -8,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF5DADE2), Color(0xFF3498DB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            // Head + body group
            Positioned(
              top: 18,
              child: Column(
                children: [
                  // Head
                  Container(
                    width: widget.size * 0.62,
                    height: widget.size * 0.56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFFFFF), Color(0xFFE8EEF5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                          color: const Color(0xFFBFD3E8), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1B2A4A), Color(0xFF223354)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildEye(true),
                            SizedBox(width: widget.size * 0.06),
                            _buildEye(false),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: widget.size * 0.04),

                  // Body
                  Container(
                    width: widget.size * 0.5,
                    height: widget.size * 0.32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFFFFF), Color(0xFFE8EEF5)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      border: Border.all(
                          color: const Color(0xFFBFD3E8), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: widget.size * 0.16,
                        height: widget.size * 0.16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5DADE2), Color(0xFF2E86C1)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5DADE2).withOpacity(0.6),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Side ear/antennae bumps
            Positioned(
              top: 38,
              left: -2,
              child: _buildEarBump(),
            ),
            Positioned(
              top: 38,
              right: -2,
              child: _buildEarBump(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEye(bool isLeft) {
    final showWink = widget.isWinking && !isLeft;
    return showWink
        ? Container(
            width: widget.size * 0.13,
            height: 3,
            decoration: BoxDecoration(
              color: const Color(0xFF5DADE2),
              borderRadius: BorderRadius.circular(2),
            ),
          )
        : Container(
            width: widget.size * 0.13,
            height: widget.size * 0.13,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF85C1E9), Color(0xFF3498DB)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5DADE2).withOpacity(0.7),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: widget.size * 0.05,
                height: widget.size * 0.05,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          );
  }

  Widget _buildEarBump() {
    return Container(
      width: 14,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFFCBD9E8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBFD3E8), width: 1.5),
      ),
    );
  }
}