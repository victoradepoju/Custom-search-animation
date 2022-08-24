import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({Key? key}) : super(key: key);

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _containerWidth;
  late Animation<Color?> _containerColor;
  late Animation<Color?> _iconColor;
  late Animation<double> _trailingIconRotation;
  late TextEditingController _textEditingController;

  bool _showTopContainer = false;
  bool _showTrailingIcon = false;
  bool _expand = false;
  bool _showSearchResult = false;
  bool _showTextInputResult = false;

  @override
  void initState() {
    super.initState();
    // the parent controller.
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textEditingController = TextEditingController();

    // to make the right container slide to the left.
    _offsetAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-1.6, 0)).animate(
            CurvedAnimation(
                parent: _animationController, curve: const Interval(0, 0.4)));

    // the expansion of the left container as soon as the right container is
    // in its position.
    _containerWidth = Tween<double>(begin: 80, end: 500).animate(
        CurvedAnimation(
            parent: _animationController, curve: const Interval(0.4, 1.0)));

    // the expanding container animates between these colors.
    _containerColor = ColorTween(begin: Colors.black, end: Colors.white)
        .animate(CurvedAnimation(
            parent: _animationController, curve: const Interval(0.4, 1.0)));

    // the icon collor also changes.
    _iconColor = ColorTween(begin: Colors.white, end: Colors.black).animate(
        CurvedAnimation(
            parent: _animationController, curve: const Interval(0.4, 1.0)));

    // the icon then rotates after some delay (0.8).
    _trailingIconRotation = Tween<double>(begin: 0.0, end: 0.5).animate(
        CurvedAnimation(
            parent: _animationController, curve: const Interval(0.8, 1.0)));

    // tracks the values of the parent controller for logic implementation.
    _animationController.addListener(() {
      // the top (left) container is made visible.
      if (_animationController.value >= 0.4) {
        setState(() {
          _showTopContainer = true;
        });
      }

      // the icon inside the top container becomes visible.
      if (_animationController.value >= 0.6) {
        setState(() {
          _showTrailingIcon = true;
        });
      } else {
        setState(() {
          _showTrailingIcon = false; // invisible or hide.
        });
      }
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _expand = true;
        });
      } else {
        setState(() {
          _expand = false;
          _showTopContainer = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    // _animationController.removeListener;
    // _animationController.removeStatusListener;
    // _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Visibility(
          visible: !_showTopContainer,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) => GestureDetector(
              onTap: () {
                _animationController.forward();
              },
              child: SlideTransition(
                position: _offsetAnimation,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 12,
                        ),
                      ]),
                  child: const Icon(
                    FontAwesomeIcons.magnifyingGlass,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: _showTopContainer,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) => Align(
              alignment: _expand ? Alignment.center : Alignment.centerLeft,
              child: _showTextInputResult
                  ? AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                          ),
                        ],
                        color: Colors.white,
                      ),
                      width: 500,
                      height: _showSearchResult ? 300 : 80,
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                alignment: Alignment.center,
                                child: Icon(
                                  FontAwesomeIcons.magnifyingGlass,
                                  color: _iconColor.value,
                                  size: 30,
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _textEditingController,
                                  autofocus: true,
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Search...',
                                    hintStyle: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black.withOpacity(0.4),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      setState(() {
                                        _showSearchResult = true;
                                      });
                                    } else {
                                      setState(() {
                                        _showSearchResult = false;
                                      });
                                    }
                                  },
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (_textEditingController.text.isNotEmpty) {
                                    setState(() {
                                      _textEditingController.clear();
                                      _showSearchResult = false;
                                    });
                                  } else {
                                    setState(() {
                                      _showTextInputResult = false;
                                    });
                                  }
                                },
                                child: Container(
                                  width: 80.0,
                                  height: 80.0,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    FontAwesomeIcons.trashCan,
                                    color: Colors.black,
                                    size: 30,
                                  ),
                                ),
                              )
                            ],
                          ),
                          Expanded(
                            child: Visibility(
                              visible: _showSearchResult,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Divider(
                                      indent: 16.0,
                                      endIndent: 16.0,
                                      height: 3.0,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                    const ListTile(
                                      leading: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(FontAwesomeIcons.envelope),
                                      ),
                                      title: Text('Victor Adepoju'),
                                      subtitle: Text(
                                          'Email: victoradepoju30@gmail.com'),
                                    ),
                                    const ListTile(
                                      leading: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(FontAwesomeIcons.twitter),
                                      ),
                                      title: Text('Victor Adepoju'),
                                      subtitle: Text('Twitter: @ Vikktor99'),
                                    ),
                                    const ListTile(
                                      leading: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(FontAwesomeIcons.instagram),
                                      ),
                                      title: Text('Victor Adepoju'),
                                      subtitle:
                                          Text('Instagram: @ victor adepoju'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      // duration: const Duration(milliseconds: 800),
                      width: _containerWidth.value,
                      height: 80,
                      decoration: BoxDecoration(
                          color: _containerColor.value,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 12,
                            ),
                          ]),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 80,
                            width: 80,
                            alignment: Alignment.center,
                            child: Icon(
                              FontAwesomeIcons.magnifyingGlass,
                              color: _iconColor.value,
                              size: 30,
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showTextInputResult = true;
                                });
                              },
                              child: Text(
                                'Search...',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black.withOpacity(0.4),
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: _showTrailingIcon,
                            child: RotationTransition(
                              turns: _trailingIconRotation,
                              child: GestureDetector(
                                onTap: () {
                                  _animationController.reverse();
                                  // setState(() {
                                  //   _showSearchResult = false;
                                  // });
                                },
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    FontAwesomeIcons.xmark,
                                    color: Colors.black,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

// Expanded(
//                           child: TextField(
//                             style: const TextStyle(
//                               fontSize: 20,
//                             ),
//                             decoration: InputDecoration(
//                               border: InputBorder.none,
//                               hintText: 'Search...',
//                               hintStyle: TextStyle(
//                                 fontSize: 20,
//                                 color: Colors.black.withOpacity(0.4),
//                               ),
//                             ),
//                             onChanged: (value) {
//                               if (value.isNotEmpty) {
//                                 setState(() {
//                                   _showSearchResult = true;
//                                 });
//                               }
//                             },
//                           ),
//                         ),

