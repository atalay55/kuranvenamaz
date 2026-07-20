import 'dart:async';
import 'dart:math' show pi, sin, cos, tan, atan2;
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kuranvenamaz/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

import 'location_error_widget.dart';

class QiblahCompass extends StatefulWidget {
  const QiblahCompass({Key? key}) : super(key: key);

  @override
  _QiblahCompassState createState() => _QiblahCompassState();
}

class _QiblahCompassState extends State<QiblahCompass> {
  final _locationStreamController = StreamController<LocationStatus>.broadcast();
  Stream<LocationStatus> get stream => _locationStreamController.stream;

  Future<void> _checkLocationStatus() async {
    final locationStatus = await FlutterQiblah.checkLocationStatus();
    if (locationStatus.enabled && locationStatus.status == LocationPermission.denied) {
      await FlutterQiblah.requestPermissions();
      final s = await FlutterQiblah.checkLocationStatus();
      _locationStreamController.sink.add(s);
    } else {
      _locationStreamController.sink.add(locationStatus);
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLocationStatus();
  }

  @override
  void dispose() {
    _locationStreamController.close();
    FlutterQiblah().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kıble Bulucu"),
        centerTitle: true,
      ),
      body: Container(
        color: AppTheme.bgDark,
        alignment: Alignment.center,
        child: StreamBuilder<LocationStatus>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.goldAccent),
              );
            }
            if (snapshot.data?.enabled == true) {
              final status = snapshot.data!.status;
              if (status == LocationPermission.always || status == LocationPermission.whileInUse) {
                return const PureQiblaFinderView();
              } else {
                String errorMessage = status == LocationPermission.denied
                    ? "Konum izni verilmedi"
                    : "Konum izni kalıcı olarak reddedildi!";
                return LocationErrorWidget(
                  error: errorMessage,
                  callback: _checkLocationStatus,
                );
              }
            } else {
              return LocationErrorWidget(
                error: "Lütfen cihazınızın GPS konum servisini açın",
                callback: _checkLocationStatus,
              );
            }
          },
        ),
      ),
    );
  }
}

class PureQiblaFinderView extends StatefulWidget {
  const PureQiblaFinderView({Key? key}) : super(key: key);

  @override
  State<PureQiblaFinderView> createState() => _PureQiblaFinderViewState();
}

class _PureQiblaFinderViewState extends State<PureQiblaFinderView> {
  double? userLat;
  double? userLng;
  double? qiblaBearingDeg;
  double? distanceKm;
  bool isReversedSensor = false;
  bool _hasVibrated = false;

  @override
  void initState() {
    super.initState();
    _initPosition();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isReversedSensor = prefs.getBool('qibla_reversed_sensor') ?? false;
    });
  }

  Future<void> _toggleReversedSensor() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isReversedSensor = !isReversedSensor;
    });
    await prefs.setBool('qibla_reversed_sensor', isReversedSensor);
  }

  Future<void> _initPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      double lat = position.latitude;
      double lng = position.longitude;

      // Calculate Qibla Bearing mathematically from GPS
      double bearing = _calculateQiblaBearing(lat, lng);
      
      // Calculate Distance to Kaaba (21.422487, 39.826206) in KM
      double distMeters = Geolocator.distanceBetween(lat, lng, 21.422487, 39.826206);

      if (mounted) {
        setState(() {
          userLat = lat;
          userLng = lng;
          qiblaBearingDeg = bearing;
          distanceKm = distMeters / 1000.0;
        });
      }
    } catch (_) {}
  }

  // Mathematical Spherical Trigonometry Formula for Qibla Angle from True North
  double _calculateQiblaBearing(double lat, double lng) {
    const double kaabaLat = 21.422487 * (pi / 180.0);
    const double kaabaLng = 39.826206 * (pi / 180.0);

    final double uLat = lat * (pi / 180.0);
    final double uLng = lng * (pi / 180.0);

    final double dLng = kaabaLng - uLng;

    final double y = sin(dLng);
    final double x = cos(uLat) * tan(kaabaLat) - sin(uLat) * cos(dLng);

    double qiblaRad = atan2(y, x);
    double qiblaDeg = (qiblaRad * (180.0 / pi) + 360.0) % 360.0;

    return qiblaDeg;
  }

  void _triggerHaptic() async {
    if (_hasVibrated) return;
    _hasVibrated = true;
    try {
      if (await Vibration.hasVibrator() == true) {
        Vibration.vibrate(duration: 90);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.goldAccent));
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              "Pusula sensörü başlatılamadı.\nLütfen cihazınızı hareket ettirin.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        final qiblahDirection = snapshot.data!;
        
        // Use mathematical bearing if GPS calculated, otherwise fall back to package bearing
        final double targetQibla = qiblaBearingDeg ?? qiblahDirection.qiblah;
        final double phoneHeading = qiblahDirection.direction; // 0..360° from North

        // Screen angle calculation: (Qibla - Heading)
        double screenAngleDeg = (targetQibla - phoneHeading);
        if (isReversedSensor) {
          screenAngleDeg = -screenAngleDeg;
        }

        // Normalize to [-180, 180] for checking alignment with top of phone
        double normalizedDiff = (screenAngleDeg + 180) % 360 - 180;
        
        final double dialRotation = -phoneHeading * (pi / 180.0);
        final double arrowRotation = screenAngleDeg * (pi / 180.0);

        // Aligned if arrow points to phone top within +-7 degrees
        final bool isAligned = normalizedDiff.abs() < 7.0;

        if (isAligned) {
          _triggerHaptic();
        } else {
          _hasVibrated = false;
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                // Header Status Banner
                _buildHeaderCard(targetQibla, isAligned),
                const Spacer(),

                // Center Qibla Compass Stack
                _buildCompassStack(dialRotation, arrowRotation, isAligned),
                const Spacer(),

                // Fix Sensor Mode Toggle Button if User's Phone is Inverted
                TextButton.icon(
                  onPressed: _toggleReversedSensor,
                  icon: Icon(
                    isReversedSensor ? Icons.check_box_rounded : Icons.swap_vert_rounded,
                    color: isReversedSensor ? Colors.orangeAccent : AppTheme.goldAccent,
                    size: 18,
                  ),
                  label: Text(
                    isReversedSensor ? "Ters Sensör Modu Aktif (Değiştir)" : "İbre Yönünü Tersle / Değiştir",
                    style: TextStyle(
                      color: isReversedSensor ? Colors.orangeAccent : AppTheme.goldAccent,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Bottom Stats Row
                _buildBottomStatsRow(targetQibla, phoneHeading),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(double targetQibla, bool isAligned) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAligned ? AppTheme.primaryEmerald : AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAligned ? AppTheme.goldAccent : AppTheme.goldAccent.withOpacity(0.3),
          width: isAligned ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isAligned ? AppTheme.primaryEmerald.withOpacity(0.5) : Colors.black26,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isAligned ? Icons.check_circle_rounded : Icons.explore_rounded,
                color: AppTheme.goldAccent,
                size: 26,
              ),
              const SizedBox(width: 10),
              Text(
                isAligned ? "KIBLE YÖNÜNDESİNİZ ✓" : "KÂBE AÇISI: ${targetQibla.toStringAsFixed(0)}°",
                style: TextStyle(
                  color: isAligned ? Colors.white : AppTheme.goldAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          if (distanceKm != null) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.near_me_rounded, color: AppTheme.goldLight, size: 14),
                const SizedBox(width: 4),
                Text(
                  "Kâbe'ye Uzaklık: ${distanceKm!.toStringAsFixed(0)} km",
                  style: const TextStyle(
                    color: AppTheme.goldLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompassStack(double dialRotation, double arrowRotation, bool isAligned) {
    return Center(
      child: SizedBox(
        width: 300,
        height: 300,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glowing Aura when aligned with Kaaba
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isAligned ? AppTheme.primaryEmerald.withOpacity(0.18) : Colors.transparent,
                border: Border.all(
                  color: isAligned ? AppTheme.goldAccent : AppTheme.goldAccent.withOpacity(0.2),
                  width: isAligned ? 3 : 1,
                ),
                boxShadow: isAligned
                    ? [
                        BoxShadow(
                          color: AppTheme.goldAccent.withOpacity(0.35),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ]
                    : null,
              ),
            ),

            // 1. Rotating Compass Dial (North / East / South / West)
            Transform.rotate(
              angle: dialRotation,
              child: CustomPaint(
                size: const Size(280, 280),
                painter: QiblaCompassDialPainter(),
              ),
            ),

            // 2. Qibla Arrow Pointer (Points straight UP to phone top when facing Kaaba)
            Transform.rotate(
              angle: arrowRotation,
              alignment: Alignment.center,
              child: CustomPaint(
                size: const Size(280, 280),
                painter: QiblaArrowPainter(isAligned: isAligned),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomStatsRow(double targetQibla, double phoneHeading) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: AppTheme.cardDecoration(color: AppTheme.surfaceDark),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("Kıble Açısı", "${targetQibla.toStringAsFixed(0)}°"),
          Container(width: 1, height: 30, color: Colors.white12),
          _buildStatItem("Cihaz Yönü", "${phoneHeading.toStringAsFixed(0)}°"),
          Container(width: 1, height: 30, color: Colors.white12),
          _buildStatItem("Mesafe", distanceKm != null ? "${distanceKm!.toStringAsFixed(0)} km" : "-"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: AppTheme.textPrimaryDark, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// Custom Painter for Compass Dial
class QiblaCompassDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Fill Dial Background
    final bgPaint = Paint()
      ..color = AppTheme.cardDark
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 6, bgPaint);

    // Border Outer Ring
    final borderPaint = Paint()
      ..color = AppTheme.goldAccent.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius - 6, borderPaint);

    // Inner Accent Ring
    final innerRingPaint = Paint()
      ..color = AppTheme.goldAccent.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius - 36, innerRingPaint);

    // Cardinal Labels (K, D, G, B)
    const textStyleN = TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold);
    const textStyleOther = TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600);

    _drawText(canvas, center, "K", 0, radius - 24, textStyleN);
    _drawText(canvas, center, "D", 90, radius - 24, textStyleOther);
    _drawText(canvas, center, "G", 180, radius - 24, textStyleOther);
    _drawText(canvas, center, "B", 270, radius - 24, textStyleOther);

    // Graduation Tick Marks
    final tickPaint = Paint()
      ..color = AppTheme.goldAccent.withOpacity(0.4)
      ..strokeWidth = 1.2;

    for (int i = 0; i < 360; i += 10) {
      final angleRad = (i - 90) * (pi / 180);
      final isMajor = i % 30 == 0;
      final tickLength = isMajor ? 10.0 : 5.0;

      final start = Offset(
        center.dx + (radius - 6) * cos(angleRad),
        center.dy + (radius - 6) * sin(angleRad),
      );
      final end = Offset(
        center.dx + (radius - 6 - tickLength) * cos(angleRad),
        center.dy + (radius - 6 - tickLength) * sin(angleRad),
      );
      canvas.drawLine(start, end, tickPaint);
    }
  }

  void _drawText(Canvas canvas, Offset center, String text, double angleDeg, double dist, TextStyle style) {
    final angleRad = (angleDeg - 90) * (pi / 180);
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final x = center.dx + dist * cos(angleRad) - (textPainter.width / 2);
    final y = center.dy + dist * sin(angleRad) - (textPainter.height / 2);

    textPainter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for Qibla Pointer Arrow with Kaaba Emblem
class QiblaArrowPainter extends CustomPainter {
  final bool isAligned;
  QiblaArrowPainter({required this.isAligned});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final arrowColor = isAligned ? Colors.greenAccent : AppTheme.goldAccent;

    // Arrow Body Paint
    final arrowPaint = Paint()
      ..color = arrowColor
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    // Main Kaaba Arrow Path pointing STRAIGHT UP towards Phone Top
    final path = Path();
    path.moveTo(center.dx, center.dy - 118); // Arrow Tip pointing UP
    path.lineTo(center.dx - 16, center.dy - 25);
    path.lineTo(center.dx, center.dy - 40);
    path.lineTo(center.dx + 16, center.dy - 25);
    path.close();

    // Shadow & Arrow Body
    canvas.drawPath(path.shift(const Offset(2, 3)), shadowPaint);
    canvas.drawPath(path, arrowPaint);

    // Kaaba Cube Emblem on Arrow Tip
    final kaabaBoxPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    final kaabaBorderPaint = Paint()
      ..color = isAligned ? Colors.greenAccent : AppTheme.goldAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final Rect kaabaRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy - 70),
      width: 18,
      height: 18,
    );
    canvas.drawRect(kaabaRect, kaabaBoxPaint);
    canvas.drawRect(kaabaRect, kaabaBorderPaint);

    // Gold Band on Kaaba Cube
    final goldBandPaint = Paint()
      ..color = AppTheme.goldAccent
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(kaabaRect.left, kaabaRect.top + 4, kaabaRect.width, 3),
      goldBandPaint,
    );

    // Center Pivot
    final pivotPaint = Paint()
      ..color = arrowColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 9, pivotPaint);

    final innerPivotPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, innerPivotPaint);
  }

  @override
  bool shouldRepaint(covariant QiblaArrowPainter oldDelegate) => oldDelegate.isAligned != isAligned;
}
