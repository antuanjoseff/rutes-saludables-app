import 'package:flutter/material.dart';

class NextPageAnimation extends StatefulWidget {
  const NextPageAnimation({
    super.key,
    required this.nextPage,
  });

  final Widget nextPage;

  @override
  State<NextPageAnimation> createState() => _NextPageAnimationState();
}

class _NextPageAnimationState extends State<NextPageAnimation>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _animation = Tween(begin: 0.4, end: 1.0).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of TextEditingController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => widget.nextPage),
          );
        },
        child: const CircleAvatar(
            backgroundColor: Color(0xff3242a0),
            radius: 30,
            child:
                Icon(Icons.expand_more_sharp, color: Colors.white, size: 40)),
      ),
    );
  }
}
