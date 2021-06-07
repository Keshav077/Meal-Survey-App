import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class MenuButton extends StatefulWidget {
  final Map<String, bool> selected;
  final String menuItem;
  final Size mqs;
  const MenuButton(
      {Key? key,
      required this.selected,
      required this.menuItem,
      required this.mqs})
      : super(key: key);

  @override
  _MenuButtonState createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          widget.selected[widget.menuItem] =
              widget.selected[widget.menuItem] != true;
        });
        print(widget.selected[widget.menuItem]);
      },
      child: Ink(
        decoration: BoxDecoration(
          color: widget.selected[widget.menuItem] == true
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColorLight,
          borderRadius: BorderRadius.circular(30),
          boxShadow: kElevationToShadow[1],
        ),
        child: Container(
          alignment: Alignment.center,
          child: AutoSizeText(
            widget.menuItem,
            style: TextStyle(
              color: widget.selected[widget.menuItem] == true
                  ? Colors.white
                  : Colors.black,
              fontSize: 20,
            ),
          ),
        ),
        width: double.infinity,
        height: widget.mqs.height * 0.06,
      ),
    );
  }
}
