import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rover_app/providers/bt_controller.dart';

/// Gumb koji detektira pritisak i otpuštanje
/// Šalje se primjerena poruka ovisno o [value]
/// 
/// Odnosno mijenja se jedna varijabla koja se onda šalje za pomjeranje motora
class ControlButton extends StatefulWidget {
  final IconData icon;
  final int value;

  const ControlButton({super.key, required this.icon, required this.value});

  @override
  State<ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<ControlButton> {
  bool pressedDown = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BtController>(context);
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35.0),
          child: Material(
            color:
                pressedDown ? Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).colorScheme.primaryContainer,
            child: InkWell(
                child: Icon(widget.icon, color: Theme.of(context).colorScheme.onPrimaryContainer)),
          ),
        ),
      ),
      onTapDown: (details) {
        provider.motorControl |= widget.value;
        provider.sendMessage();
        setState(() => pressedDown = true);
      },
      onTapUp: (details) {
        if (pressedDown) {
          provider.motorControl = 0;
          provider.sendMessage();
        }
        setState(() => pressedDown = false);
      },
      onVerticalDragEnd: (details) {
        if (pressedDown) {
          provider.motorControl = 0;
          provider.sendMessage();
        }
        setState(() => pressedDown = false);
      },
    );
  }
}
