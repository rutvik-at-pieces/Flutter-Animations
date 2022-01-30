import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animations/flutter_render_objects/custom_proxy.dart';

class StarWardsIntro extends StatefulWidget {
  const StarWardsIntro({Key? key}) : super(key: key);

  @override
  State<StarWardsIntro> createState() => _StarWardsIntroState();
}

class _StarWardsIntroState extends State<StarWardsIntro>
    with SingleTickerProviderStateMixin {
  final String crawlText =
      '''Turmoil has engulfed the Galactic Republic. The taxation of trade routes to outlying star systems is in dispute.

Hoping to resolve the matter with a blockade of deadly battleships, the greedy Trade Federation has stopped all shipping to the small planet of Naboo.

While the Congress of the Republic endlessly debates this alarming chain of events,the Supreme Chancellor has secretly dispatched two Jedi Knights, the guardians of peace and justice in the galaxy, to settle the conflict....''';

  late final AnimationController _animationController;

  late final Animation<Offset> crawlTextposition;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    crawlTextposition = Tween(begin: Offset(0, 250), end: Offset(0, -0))
        .animate(_animationController);

    _animationController.forward();
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose(); // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Image.asset(
              'assets/images/galaxy.jpeg',
              fit: BoxFit.cover,
              width: double.maxFinite,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                ),
                AnimatedBuilder(
                    animation: _animationController,
                    child: Text(
                      crawlText,
                      overflow: TextOverflow.visible,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontFamily: "Crawl",
                      ),
                    ),
                    builder: (context, child) {
                      return Transform(
                        origin: Offset(
                          MediaQuery.of(context).size.width / 2,
                          0,
                        ),
                        transform: Matrix4.identity()
                          ..setRotationX(pi / 2.5)
                          ..setEntry(
                            3,
                            1,
                            -0.003,
                          ),
                        child: Transform.translate(
                          offset: crawlTextposition.value,
                          child: child,
                        ),
                      );
                    }),
              ],
            ),
          ],
        ));
  }
}