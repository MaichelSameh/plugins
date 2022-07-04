import 'package:flutter/material.dart';

import 'src/builders/index.dart';

class PageTurn extends StatefulWidget {
  const PageTurn({
    Key? key,
    this.backgroundColor = const Color(0xFFFFFFCC),
    required this.children,
    this.duration = const Duration(milliseconds: 450),
    this.initialIndex = 0,
    this.lastPage,
    this.showDragCutoff = false,
    this.cutoff = 0.6,
    this.onPageChange,
    this.tapToNavigate = true,
  }) : super(key: key);

  final Color backgroundColor;
  final List<Widget> children;
  final Duration duration;
  final int initialIndex;
  final Widget? lastPage;
  final bool showDragCutoff;
  final double cutoff;
  final void Function(int)? onPageChange;
  final bool tapToNavigate;

  @override
  PageTurnState createState() => PageTurnState();
}

class PageTurnState extends State<PageTurn> with TickerProviderStateMixin {
  int pageNumber = 0;
  List<Widget> pages = [];

  List<AnimationController> _controllers = [];
  bool? _isForward;

  @override
  void didUpdateWidget(PageTurn oldWidget) {
    if (oldWidget.children != widget.children) {
      _setUp();
    }
    if (oldWidget.duration != widget.duration) {
      _setUp();
    }
    if (oldWidget.backgroundColor != widget.backgroundColor) {
      _setUp();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controllers.forEach((c) => c.dispose());
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _setUp();
  }

  void _setUp() {
    _controllers.clear();
    pages.clear();
    for (var i = 0; i < widget.children.length; i++) {
      final _controller = AnimationController(
        value: 1,
        duration: widget.duration,
        vsync: this,
      );
      _controllers.add(_controller);
      final _child = Container(
        child: PageTurnWidget(
          backgroundColor: widget.backgroundColor,
          amount: _controller,
          child: widget.children[i],
        ),
      );
      pages.add(_child);
    }
    pages = pages.reversed.toList();
    pageNumber = widget.initialIndex;
  }

  bool get _isLastPage => (pages.length - 1) == pageNumber;

  bool get _isFirstPage => pageNumber == 0;

  void _turnPage(DragUpdateDetails details, BoxConstraints constraints) {
    final _ratio = details.delta.dx / constraints.maxWidth;
    if (_isForward == null) {
      if (details.delta.dx > 0) {
        _isForward = false;
      } else {
        _isForward = true;
      }
    }
    if (_isForward == true || pageNumber == 0) {
      _controllers[pageNumber].value += _ratio;
    } else {
      _controllers[pageNumber - 1].value += _ratio;
    }
  }

  Future _onDragFinish() async {
    if (_isForward != null) {
      if (_isForward == true) {
        if (!_isLastPage &&
            _controllers[pageNumber].value <= (widget.cutoff + 0.15)) {
          await nextPage();
        } else {
          await _controllers[pageNumber].forward();
        }
      } else {
        print(
            'Val:${_controllers[pageNumber - 1].value} -> ${widget.cutoff + 0.28}');
        if (!_isFirstPage &&
            _controllers[pageNumber - 1].value >= widget.cutoff) {
          await previousPage();
        } else {
          if (_isFirstPage) {
            await _controllers[pageNumber].forward();
          } else {
            await _controllers[pageNumber - 1].reverse();
          }
        }
      }
    }
    _isForward = null;
  }

  Future nextPage() async {
    print('Next Page..');
    await _controllers[pageNumber].reverse();
    if (mounted)
      setState(() {
        pageNumber++;
      });
    widget.onPageChange?.call(pageNumber);
  }

  Future previousPage() async {
    print('Previous Page..');
    await _controllers[pageNumber - 1].forward();
    if (mounted)
      setState(() {
        pageNumber--;
      });

    widget.onPageChange?.call(pageNumber);
  }

  Future goToPage(int index) async {
    print('Navigate Page ${index + 1}..');
    if (mounted)
      setState(() {
        pageNumber = index;
      });
    for (var i = 0; i < _controllers.length; i++) {
      if (i == index) {
        _controllers[i].forward();
      } else if (i < index) {
        // _controllers[i].value = 0;
        _controllers[i].reverse();
      } else {
        if (_controllers[i].status == AnimationStatus.reverse)
          _controllers[i].value = 1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: LayoutBuilder(
        builder: (context, constraints) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragCancel: () => _isForward = null,
          onHorizontalDragUpdate: (details) => _turnPage(details, constraints),
          onHorizontalDragEnd: (details) => _onDragFinish(),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              if (widget.lastPage != null) ...[
                widget.lastPage!,
              ],
              if (pages.isNotEmpty)
                ...pages
              else ...[
                Center(child: CircularProgressIndicator()),
              ],
              if (widget.tapToNavigate)
                Positioned.fill(
                  child: Flex(
                    direction: Axis.horizontal,
                    children: <Widget>[
                      Flexible(
                        flex: (widget.cutoff * 10).round(),
                        child: Container(
                          color: widget.showDragCutoff
                              ? Colors.blue.withAlpha(100)
                              : null,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _isFirstPage ? null : previousPage,
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 10 - (widget.cutoff * 10).round(),
                        child: Container(
                          color: widget.showDragCutoff
                              ? Colors.red.withAlpha(100)
                              : null,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _isLastPage ? null : nextPage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
