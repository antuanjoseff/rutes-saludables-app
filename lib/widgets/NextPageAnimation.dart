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
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    animation = Tween(begin: 0.4, end: 1.0).animate(controller);

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
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
