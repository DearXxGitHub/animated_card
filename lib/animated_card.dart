library animated_card;

import 'package:flutter/material.dart';

import 'animated_card_mixin.dart';
import 'animated_card_direction.dart';

export 'animated_card_direction.dart';
export 'animated_card_mixin.dart';

class AnimatedCard extends StatefulWidget {
  final void Function() onRemove;
  final Widget child;

  final AnimatedCardDirection direction;
  final Duration duration;
  final Duration initDelay;
  bool _removed = false;
  AnimatedCard({
    Key key,
    @required this.child,
    this.direction = AnimatedCardDirection.right,
    this.onRemove,
    this.duration,
    this.initDelay,
  })  : assert(child != null),
        super(key: key ?? ((onRemove == null) ? null : UniqueKey()));

  @override
  _AnimatedCardState createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with TickerProviderStateMixin, AnimatedCardMixin {
  Duration get initDelay => widget.initDelay ?? Duration(milliseconds: 200);
  Duration get duration => widget.duration ?? Duration(milliseconds: 600);
  AnimatedCardDirection get direction => widget.direction;

  @override
  void initState() {
    removed = widget._removed;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildRemoveAnimation(
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          if (widget.onRemove != null)
            optionsController.value +=
                details.primaryDelta / MediaQuery.of(context).size.width * 3;
        },
        onHorizontalDragEnd: (details) {
          if (optionsController.value > 0.5)
            optionsController.forward();
          else
            optionsController.reverse();
        },
        child: AnimatedBuilder(
          animation: initAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: initAnimation.value,
              child: child,
            );
          },
          child: AnimatedBuilder(
            animation: optionsController,
            builder: (context, childWidget) {
              return Stack(
                alignment: Alignment.centerLeft,
                children: <Widget>[
                  _buildRemoveButton(),
                  Transform.translate(
                    offset: Offset(optionsCardAnimation.value, 0),
                    child: childWidget,
                  ),
                ],
              );
            },
            child: _buildCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildRemoveButton() {
    return AnimatedBuilder(
      animation: removeController,
      builder: (context, childWidget) {
        var removeButtonX =
            -MediaQuery.of(context).size.width * 0.2 * removeAnimation.value;
        return Transform.translate(
          offset: Offset(optionsRemoveButtonAnimation.value + removeButtonX, 0),
          child: childWidget,
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 3,
        child: Column(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                if (widget.onRemove != null) {
                  await removeController.forward();
                  widget._removed = true;
                  widget.onRemove();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard() {
    return AnimatedBuilder(
      animation: removeController,
      child: widget.child,
      builder: (context, childWidget) {
        var position =
            MediaQuery.of(context).size.width * 2 / 3 * removeAnimation.value;
        return Transform.translate(
          offset: Offset(position, 0),
          child: childWidget,
        );
      },
    );
  }

  Widget _buildRemoveAnimation({Widget child}) {
    return AnimatedBuilder(
      animation: removeHeightAnimation,
      child: child,
      builder: (context, childWidget) {
        return Align(
          heightFactor: removeHeightAnimation.value,
          child: childWidget,
        );
      },
    );
  }
}