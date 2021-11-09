import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animations/flutter_design_challenges/spotify_page/const.dart';

class PlayPauseButton extends StatefulWidget {
  const PlayPauseButton({
    Key? key,
    required this.scrollController,
    required this.maxAppBarHeight,
    required this.minAppBarHeight,
    required this.playPauseButtonSize,
    required this.infoBoxHeight,
  }) : super(key: key);

  final ScrollController scrollController;
  final double maxAppBarHeight;
  final double minAppBarHeight;
  final double playPauseButtonSize;
  final double infoBoxHeight;

  @override
  State<PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    widget.scrollController.addListener(() {
      setState(() {});
    });
  }

  double get getPosition {
    double position = widget.maxAppBarHeight;
    double finalPosition =
        widget.minAppBarHeight - widget.playPauseButtonSize / 2;
    if (widget.scrollController.hasClients) {
      double offset = widget.scrollController.offset;
      //When updating position, add/subtract both in isFinalPosition right hand side
      //And from position below inside if statement
      final bool isFinalPosition = offset >
          (position +
              widget.infoBoxHeight -
              finalPosition -
              widget.playPauseButtonSize -
              10);
      if (!isFinalPosition) {
        position = position -
            offset +
            widget.infoBoxHeight -
            widget.playPauseButtonSize -
            10;
      } else {
        position = finalPosition;
      }
    }
    return position;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: getPosition,
      right: 10,
      child: ElevatedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: kPlayPauseButtonColor,
          fixedSize:
              Size(widget.playPauseButtonSize, widget.playPauseButtonSize),
          shape: const CircleBorder(),
        ),
        onPressed: () {},
        child: const Icon(
          Icons.play_arrow,
          color: Colors.black,
        ),
      ),
    );
  }
}