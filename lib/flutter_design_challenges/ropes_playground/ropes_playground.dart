// An example of simulating a simple rope. For, the construction of rope, catenary algorithm(https://en.wikipedia.org/wiki/Catenary) is used.
// The catenary is a curve that describes the shape of a hanging chain or cable, or the curve described by a freely hanging chain or cable.
// The implementation of catenary algorithm is based on the following js implementation : https://github.com/dulnan/catenary-curve/blob/9cb7e53e2db4bd5c499f5051abde8bfd853d946a/src/main.ts#L254
// Catenary dart algorithm gist : https://gist.github.com/rutvik110/56f4626c95b92b8cf2c95283d4682331

import 'dart:developer';

import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

const EPSILON = 1e-6;

class RopesPlayground extends StatelessWidget {
  const RopesPlayground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 233, 233, 233),
      body: Stack(children: [
        RopeBridge(
          startPoint: Offset(size.width * 0.3, 200),
          endPoint: Offset(size.width * 0.7, 300),
        ),
        SinglePointRope(
          startPoint: Offset(size.width * 0.2, 300),
        ),
      ]),
    );
  }
}

class RopeBridge extends StatelessWidget {
  const RopeBridge({
    Key? key,
    required this.startPoint,
    required this.endPoint,
    this.ropeSegmentLength = 1,
    this.segments = 100,
  }) : super(key: key);

  final Offset startPoint;
  final Offset endPoint;
  final int ropeSegmentLength;
  final int segments;
  @override
  Widget build(BuildContext context) {
    return RopesPhysics(
      isBridge: true,
      startPoint: startPoint,
      endPoint: endPoint,
      ropeSegmentLength: ropeSegmentLength,
      segments: segments,
    );
  }
}

class SinglePointRope extends StatelessWidget {
  const SinglePointRope({
    Key? key,
    required this.startPoint,
    this.ropeSegmentLength = 1,
    this.segments = 100,
  }) : super(key: key);

  final Offset startPoint;
  final int ropeSegmentLength;
  final int segments;
  @override
  Widget build(BuildContext context) {
    return RopesPhysics(
      isBridge: false,
      startPoint: startPoint,
      ropeSegmentLength: ropeSegmentLength,
      segments: segments,
    );
  }
}

class RopesPhysics extends StatefulWidget {
  const RopesPhysics({
    Key? key,
    required this.isBridge,
    required this.startPoint,
    this.endPoint = const Offset(0, 0),
    this.ropeSegmentLength = 1,
    this.segments = 100,
  }) : super(key: key);

  final bool isBridge;
  final Offset startPoint;
  final Offset endPoint;
  final int ropeSegmentLength;
  final int segments;

  @override
  State<RopesPhysics> createState() => _RopesViewState();
}

class _RopesViewState extends State<RopesPhysics> {
  Vector2 wind = Vector2.zero();
  late Offset ropeStartPoint;
  late Offset ropeEndPoint;
  double elapsedDelta = 0;
  Duration elapsedDuration = Duration.zero;
  late bool isBridge;

  late Ticker ticker;

  late double delta;

  late int segments;
  late double ropeSegmentLength;
  late List<Offset> ropeSegments;
  late List<Offset> oldSegments;

  void addPoints() {
    Offset startPoint = ropeStartPoint;
    for (var i = 0; i < segments; i++) {
      ropeSegments[i] = startPoint;
      startPoint = Offset(startPoint.dx + ropeSegmentLength, startPoint.dy);
    }
    oldSegments = ropeSegments;
  }

  void applyForces() {
    Vector2 forceGravity = Vector2(0, 10);

    for (var i = 0; i < segments; i++) {
      Offset firstSegmentPoint = ropeSegments[i];
      Vector2 velocity = firstSegmentPoint.posNow - oldSegments[i].posNow;

      oldSegments[i] = firstSegmentPoint;
      Vector2 latestPosition = firstSegmentPoint.posNow + velocity;

      latestPosition += wind;
      latestPosition += forceGravity;

      firstSegmentPoint = Offset(latestPosition.x, latestPosition.y);
      ropeSegments[i] = firstSegmentPoint;
    }

    for (var i = 0; i < 250; i++) {
      applyConstraints();
    }
  }

  /// Constraint resolution algorithm for a rope simulation, ensuring that the segments of the rope maintain a fixed
  /// length between them.
  void applyConstraints() {
    // Fix start and end points.
    ropeSegments[0] = ropeStartPoint;
    if (isBridge) {
      ropeSegments[segments - 1] = ropeEndPoint;
    }

    // Constrain adjacent segments.
    for (var i = 0; i < segments - 1; i++) {
      Vector2 firstSegmentPoint = ropeSegments[i].posNow;
      Vector2 secondSegmentPoint = ropeSegments[i + 1].posNow;
      final dist = (firstSegmentPoint).distanceTo(secondSegmentPoint);
      double error = (dist - ropeSegmentLength).abs();

      // Calculate direction to adjust the segments in.
      Vector2 changeDir = Vector2.zero();
      if (dist > ropeSegmentLength) {
        // Move segment point closer.
        changeDir = (firstSegmentPoint - secondSegmentPoint).normalized();
      } else if (dist < ropeSegmentLength) {
        changeDir = (secondSegmentPoint - firstSegmentPoint).normalized();
      }

      // Distance by which segment points should be moved.
      Vector2 changedAmount = changeDir * error;

      if (i != 0) {
        firstSegmentPoint -=
            changedAmount * 0.5; // multiply by error for proper single point hanging and by 0.5 for bridge;
        ropeSegments[i] = Offset(firstSegmentPoint.x, firstSegmentPoint.y);
        secondSegmentPoint += (changedAmount * 0.5);
        ropeSegments[i + 1] = Offset(secondSegmentPoint.x, secondSegmentPoint.y);
      } else {
        secondSegmentPoint += changedAmount;
        ropeSegments[i + 1] = Offset(secondSegmentPoint.x, secondSegmentPoint.y);
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isBridge = widget.isBridge;
    ropeStartPoint = widget.startPoint;
    ropeEndPoint = widget.endPoint;
    ropeSegmentLength = widget.ropeSegmentLength.toDouble();
    segments = widget.segments;
    ropeSegments = List.generate(
      segments,
      (index) => Offset(
        0,
        index.toDouble(),
      ),
    );
    oldSegments = List.generate(segments, (index) => Offset.zero);
    addPoints();
    delta = 0;
    ticker = Ticker((value) {
      elapsedDelta = (value - elapsedDuration).inMilliseconds.toDouble();
      log(elapsedDelta.toString());
      elapsedDuration = value;
      setState(() {
        delta += 1 / 60;
        applyForces();
      });
    })
      ..start();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const topPadding = 100.0;
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          // DragPoint 1
          Positioned(
            top: ropeStartPoint.dy - 48 / 1.2,
            left: ropeStartPoint.dx - 48 / 2,
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: Draggable(
                onDragUpdate: ((details) {
                  ropeStartPoint = details.globalPosition;
                  //  wind = details.delta.toVector2();
                }),
                feedback: const SizedBox.shrink(),
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: const BoxDecoration(
                    color: Colors.indigo,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigoAccent,
                        blurRadius: 30,
                        spreadRadius: 5,
                        offset: Offset(0, 0),
                      )
                    ],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          if (isBridge)
            Positioned(
              top: ropeEndPoint.dy - 48 / 1.2,
              left: ropeEndPoint.dx - 48 / 2,
              child: MouseRegion(
                cursor: SystemMouseCursors.grab,
                child: Draggable(
                    onDragUpdate: ((details) {
                      ropeEndPoint = details.globalPosition;
                    }),
                    feedback: const SizedBox.shrink(),
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: const BoxDecoration(
                        color: Colors.indigo,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigoAccent,
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: Offset(0, 0),
                          )
                        ],
                        shape: BoxShape.circle,
                      ),
                    )),
              ),
            ),

          IgnorePointer(
            ignoring: true,
            child: Stack(
              children: [
                CustomPaint(
                  painter: RopesPainter(
                    ropeSegments,
                  ),
                  size: Size.infinite,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class RopesPainter extends CustomPainter {
  RopesPainter(
    this.segments,
  );

  List<Offset> segments;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 10.0
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(
      segments.first.dx,
      segments.first.dy,
    );

    for (var point in segments) {
      path.lineTo(
        point.dx,
        point.dy,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

extension GetVelocity on Offset {
  Vector2 get posNow {
    return Vector2(dx, dy);
  }
}
