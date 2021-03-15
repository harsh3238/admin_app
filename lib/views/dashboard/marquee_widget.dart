import 'package:flutter/material.dart';

class MarqueeWidget extends StatefulWidget {
  final Widget child;
  final Axis direction;
  final Duration animationDuration, backDuration, pauseDuration;
  PageController pageController;
  int myIndex;
  int noOfNews;

  MarqueeWidget(
      {@required this.child,
      this.direction: Axis.horizontal,
      this.animationDuration: const Duration(milliseconds: 3000),
      this.backDuration: const Duration(milliseconds: 800),
      this.pauseDuration: const Duration(milliseconds: 2000),
      this.pageController,
      this.myIndex,
      this.noOfNews});

  @override
  _MarqueeWidgetState createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<MarqueeWidget> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    scroll();
    return SingleChildScrollView(
      child: widget.child,
      scrollDirection: widget.direction,
      controller: scrollController,
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void scroll() async {
    //TODO : Just an intended bug
    if (Theme.of(context).platform == TargetPlatform.android) {
      await Future.delayed(widget.pauseDuration);
      await scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: widget.animationDuration,
          curve: Curves.linear);
      await Future.delayed(widget.pauseDuration);
      int cPage = widget.pageController.page.floor();
      if (widget.myIndex == cPage) {
        if (cPage == widget.noOfNews - 1) {
          widget.pageController.jumpToPage(0);
        } else {
          widget.pageController
              .jumpToPage(widget.pageController.page.floor() + 1);
        }
      }
    }
  }
}
