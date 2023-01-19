import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:sqlite_user/constant/color_constant.dart';
import 'package:sqlite_user/model/item_model.dart';

enum PressType {
  longPress,
  singleClick,
}

enum PreferredPosition {
  top,
  bottom,
}

class CustomPopupMenuController extends ChangeNotifier {
  bool menuIsShowing = false;

  void showMenu() {
    menuIsShowing = true;
    notifyListeners();
  }

  void hideMenu() {
    menuIsShowing = false;
    notifyListeners();
  }

  void toggleMenu() {
    menuIsShowing = !menuIsShowing;
    notifyListeners();
  }
}

Rect _menuRect = Rect.zero;

class CustomPopupMenu extends StatefulWidget {
  CustomPopupMenu({
    required this.child,
    required this.onTap,
    required this.pressType,
    // this.controller,
    this.arrowColor = const Color(0xFF4C4C4C),
    this.showArrow = true,
    this.barrierColor = Colors.black12,
    this.arrowSize = 10.0,
    this.horizontalMargin = 10.0,
    this.verticalMargin = 10.0,
    this.position,
    this.menuOnChange,
    this.enablePassEvent = true,
  });

  final Widget child;
  final PressType pressType;
  final bool showArrow;
  final Color arrowColor;
  final Color barrierColor;
  final double horizontalMargin;
  final double verticalMargin;
  final double arrowSize;

  // final CustomPopupMenuController? controller;
  final Function({String? item}) onTap;
  final PreferredPosition? position;
  final void Function(bool)? menuOnChange;

  final bool enablePassEvent;

  @override
  _CustomPopupMenuState createState() => _CustomPopupMenuState();
}

class _CustomPopupMenuState extends State<CustomPopupMenu> {
  RenderBox? _childBox;
  RenderBox? _parentBox;
  OverlayEntry? _overlayEntry;
  CustomPopupMenuController? _controller = CustomPopupMenuController();
  bool _canResponse = true;

  _showMenu() {
    Widget arrow = ClipPath(
      child: Container(
        width: widget.arrowSize,
        height: widget.arrowSize,
        color: widget.arrowColor,
      ),
      clipper: _ArrowClipper(),
    );

    _overlayEntry = OverlayEntry(
      builder: (context) {
        Widget menu = Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: _parentBox!.size.width - 2 * widget.horizontalMargin,
              minWidth: 0,
            ),
            child: CustomMultiChildLayout(
              delegate: _MenuLayoutDelegate(
                anchorSize: _childBox!.size,
                anchorOffset: _childBox!.localToGlobal(
                  Offset(-widget.horizontalMargin, 0),
                ),
                verticalMargin: widget.verticalMargin,
                position: widget.position,
              ),
              children: <Widget>[
                if (widget.showArrow)
                  LayoutId(
                    id: _MenuLayoutId.arrow,
                    child: arrow,
                  ),
                if (widget.showArrow)
                  LayoutId(
                    id: _MenuLayoutId.downArrow,
                    child: Transform.rotate(
                      angle: math.pi,
                      child: arrow,
                    ),
                  ),
                LayoutId(
                  id: _MenuLayoutId.content,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Material(
                        color: Colors.transparent,
                        child: /* widget.menuBuilder()*/
                            Container(
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                                color: ColorConstant.grey.withOpacity(.2),
                                blurRadius: 5,
                                spreadRadius: 3,
                                offset: const Offset(0, 3))
                          ]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: IntrinsicWidth(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: menuItems
                                    .map(
                                      (item) => GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: ()  {
                                          widget.onTap(
                                              item: item.text.toString());

                                          _controller!.hideMenu();
                                        },
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              18,
                                          color: item.isSelected
                                              ? ColorConstant.orange
                                              : ColorConstant.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Row(
                                            children: <Widget>[
                                              Icon(
                                                item.icon!,
                                                size: 18,
                                                color: !item.isSelected
                                                    ? ColorConstant.orange
                                                    : ColorConstant.white,
                                              ),
                                              Expanded(
                                                child: Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 10),
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 10),
                                                  child: Text(
                                                    item.text!,
                                                    style: TextStyle(
                                                        color: !item.isSelected
                                                            ? ColorConstant
                                                                .orange
                                                            : ColorConstant
                                                                .white,
                                                        fontSize: 16,
                                                        fontFamily: 'Sora',
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
        return Listener(
          behavior: widget.enablePassEvent
              ? HitTestBehavior.translucent
              : HitTestBehavior.opaque,
          onPointerDown: (PointerDownEvent event) {
            Offset offset = event.localPosition;
            // If tap position in menu
            if (_menuRect.contains(
                Offset(offset.dx - widget.horizontalMargin, offset.dy))) {
              return;
            }
            _controller?.hideMenu();
            // When [enablePassEvent] works and we tap the [child] to [hideMenu],
            // but the passed event would trigger [showMenu] again.
            // So, we use time threshold to solve this bug.
            _canResponse = false;
            Future.delayed(Duration(milliseconds: 300))
                .then((_) => _canResponse = true);
          },
          child: widget.barrierColor == Colors.transparent
              ? menu
              : Container(
                  color: widget.barrierColor,
                  child: menu,
                ),
        );
      },
    );
    if (_overlayEntry != null) {
      Overlay.of(context)!.insert(_overlayEntry!);
    }
  }

  _hideMenu() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  _updateView() {
    bool menuIsShowing = _controller?.menuIsShowing ?? false;
    widget.menuOnChange?.call(menuIsShowing);
    if (menuIsShowing) {
      _showMenu();
    } else {
      _hideMenu();
    }
  }

  List<ItemModel> menuItems = [];

  @override
  void initState() {
    super.initState();

    menuItems.clear();
    menuItems.addAll([
      ItemModel( text: "Logout", icon: Icons.logout),
      ItemModel(text: "Filter by name", icon: Icons.filter_1),
      ItemModel(text: "Filter by age", icon: Icons.filter_2),
    ]);
    _controller ??= CustomPopupMenuController();
    _controller?.addListener(_updateView);
    WidgetsBinding.instance.addPostFrameCallback((call) {
      if (mounted) {
        _childBox = context.findRenderObject() as RenderBox?;
        _parentBox =
            Overlay.of(context)?.context.findRenderObject() as RenderBox?;
      }
    });
  }

  @override
  void dispose() {
    _hideMenu();
    _controller?.removeListener(_updateView);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var child = Material(
      color: Colors.transparent,
      child: InkWell(
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: widget.child,
        onTap: () {
          if (widget.pressType == PressType.singleClick && _canResponse) {
            _controller?.showMenu();
          }
        },
        onLongPress: () {
          if (widget.pressType == PressType.longPress && _canResponse) {
            _controller?.showMenu();
          }
        },
      ),
    );
    if (Platform.isIOS) {
      return child;
    } else {
      return WillPopScope(
        onWillPop: () {
          _hideMenu();
          return Future.value(true);
        },
        child: child,
      );
    }
  }
}

enum _MenuLayoutId {
  arrow,
  downArrow,
  content,
}

enum _MenuPosition {
  bottomLeft,
  bottomCenter,
  bottomRight,
  topLeft,
  topCenter,
  topRight,
}

class _MenuLayoutDelegate extends MultiChildLayoutDelegate {
  _MenuLayoutDelegate({
    required this.anchorSize,
    required this.anchorOffset,
    required this.verticalMargin,
    this.position,
  });

  final Size anchorSize;
  final Offset anchorOffset;
  final double verticalMargin;
  final PreferredPosition? position;

  @override
  void performLayout(Size size) {
    Size contentSize = Size.zero;
    Size arrowSize = Size.zero;
    Offset contentOffset = Offset(0, 0);
    Offset arrowOffset = Offset(0, 0);

    double anchorCenterX = anchorOffset.dx + anchorSize.width / 2;
    double anchorTopY = anchorOffset.dy;
    double anchorBottomY = anchorTopY + anchorSize.height;
    _MenuPosition menuPosition = _MenuPosition.bottomCenter;

    if (hasChild(_MenuLayoutId.content)) {
      contentSize = layoutChild(
        _MenuLayoutId.content,
        BoxConstraints.loose(size),
      );
    }
    if (hasChild(_MenuLayoutId.arrow)) {
      arrowSize = layoutChild(
        _MenuLayoutId.arrow,
        BoxConstraints.loose(size),
      );
    }
    if (hasChild(_MenuLayoutId.downArrow)) {
      layoutChild(
        _MenuLayoutId.downArrow,
        BoxConstraints.loose(size),
      );
    }

    bool isTop = false;
    if (position == null) {
      // auto calculate position
      isTop = anchorBottomY > size.height / 2;
    } else {
      isTop = position == PreferredPosition.top;
    }
    if (anchorCenterX - contentSize.width / 2 < 0) {
      menuPosition = isTop ? _MenuPosition.topLeft : _MenuPosition.bottomLeft;
    } else if (anchorCenterX + contentSize.width / 2 > size.width) {
      menuPosition = isTop ? _MenuPosition.topRight : _MenuPosition.bottomRight;
    } else {
      menuPosition =
          isTop ? _MenuPosition.topCenter : _MenuPosition.bottomCenter;
    }

    switch (menuPosition) {
      case _MenuPosition.bottomCenter:
        arrowOffset = Offset(
          anchorCenterX - arrowSize.width / 2,
          anchorBottomY + verticalMargin,
        );
        contentOffset = Offset(
          anchorCenterX - contentSize.width / 2,
          anchorBottomY + verticalMargin + arrowSize.height,
        );
        break;
      case _MenuPosition.bottomLeft:
        arrowOffset = Offset(anchorCenterX - arrowSize.width / 2,
            anchorBottomY + verticalMargin);
        contentOffset = Offset(
          0,
          anchorBottomY + verticalMargin + arrowSize.height,
        );
        break;
      case _MenuPosition.bottomRight:
        arrowOffset = Offset(anchorCenterX - arrowSize.width / 2,
            anchorBottomY + verticalMargin);
        contentOffset = Offset(
          size.width - contentSize.width,
          anchorBottomY + verticalMargin + arrowSize.height,
        );
        break;
      case _MenuPosition.topCenter:
        arrowOffset = Offset(
          anchorCenterX - arrowSize.width / 2,
          anchorTopY - verticalMargin - arrowSize.height,
        );
        contentOffset = Offset(
          anchorCenterX - contentSize.width / 2,
          anchorTopY - verticalMargin - arrowSize.height - contentSize.height,
        );
        break;
      case _MenuPosition.topLeft:
        arrowOffset = Offset(
          anchorCenterX - arrowSize.width / 2,
          anchorTopY - verticalMargin - arrowSize.height,
        );
        contentOffset = Offset(
          0,
          anchorTopY - verticalMargin - arrowSize.height - contentSize.height,
        );
        break;
      case _MenuPosition.topRight:
        arrowOffset = Offset(
          anchorCenterX - arrowSize.width / 2,
          anchorTopY - verticalMargin - arrowSize.height,
        );
        contentOffset = Offset(
          size.width - contentSize.width,
          anchorTopY - verticalMargin - arrowSize.height - contentSize.height,
        );
        break;
    }
    if (hasChild(_MenuLayoutId.content)) {
      positionChild(_MenuLayoutId.content, contentOffset);
    }

    _menuRect = Rect.fromLTWH(
      contentOffset.dx,
      contentOffset.dy,
      contentSize.width,
      contentSize.height,
    );
    bool isBottom = false;
    if (_MenuPosition.values.indexOf(menuPosition) < 3) {
      // bottom
      isBottom = true;
    }
    if (hasChild(_MenuLayoutId.arrow)) {
      positionChild(
        _MenuLayoutId.arrow,
        isBottom
            ? Offset(arrowOffset.dx, arrowOffset.dy + 0.1)
            : Offset(-100, 0),
      );
    }
    if (hasChild(_MenuLayoutId.downArrow)) {
      positionChild(
        _MenuLayoutId.downArrow,
        !isBottom
            ? Offset(arrowOffset.dx, arrowOffset.dy - 0.1)
            : Offset(-100, 0),
      );
    }
  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) => false;
}

class _ArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, size.height / 2);
    path.lineTo(size.width, size.height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
