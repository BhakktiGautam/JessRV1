// lib/ui/screens/manual_control_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rover_companion/engines/state_manager.dart';
import 'package:rover_companion/models/rover_state.dart';
import 'package:rover_companion/ui/widgets/dpad_control.dart';
import 'package:rover_companion/ui/widgets/status_hud.dart';

class ManualControlScreen extends StatefulWidget {
  const ManualControlScreen({super.key});

  @override
  State<ManualControlScreen> createState() => _ManualControlScreenState();
}

class _ManualControlScreenState extends State<ManualControlScreen> {
  String _statusMessage = 'Ready';

  void _handleCommand(RoverStateManager sm, MoveDirection dir) {
    sm.sendManualCommand(dir);
    setState(() {
      _statusMessage = switch (dir) {
        MoveDirection.forward  => '▲ Moving Forward',
        MoveDirection.backward => '▼ Moving Backward',
        MoveDirection.left     => '◀ Turning Left',
        MoveDirection.right    => '▶ Turning Right',
        MoveDirection.stop     => '■ Stopped',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final sm = context.watch<RoverStateManager>();
    final isManual = sm.mainState == MainState.manual;

    return Scaffold(
      backgroundColor: const Color(0xFF070B12),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      sm.setAutoMode();
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xFF111825),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF8090B0),
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  StatusHUD(sm: sm),
                  const Spacer(),
                  // Mode toggle
                  _ModeToggleBtn(
                    isManual: isManual,
                    onTap: isManual ? sm.setAutoMode : sm.setManualMode,
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(top: 24, bottom: 8),
              child: Text(
                'MANUAL CONTROL',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  letterSpacing: 3,
                  color: Color(0xFF00CFFF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Container(
                key: ValueKey(_statusMessage),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFF0D1420),
                  border: Border.all(
                    color: isManual
                        ? const Color(0xFF00CFFF).withOpacity(0.3)
                        : const Color(0xFFFFAA00).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  isManual ? _statusMessage : 'Switch to MANUAL to drive',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: isManual
                        ? const Color(0xFF00CFFF)
                        : const Color(0xFFFFAA00),
                  ),
                ),
              ),
            ),

            Expanded(
              child: Center(
                child: DPadControl(
                  enabled: isManual,
                  onCommand: (dir) => _handleCommand(sm, dir),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ModeToggleBtn extends StatelessWidget {
  final bool isManual;
  final VoidCallback onTap;
  const _ModeToggleBtn({required this.isManual, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isManual
              ? const Color(0xFFFFAA00).withOpacity(0.15)
              : const Color(0xFF00CFFF).withOpacity(0.15),
          border: Border.all(
            color: isManual ? const Color(0xFFFFAA00) : const Color(0xFF00CFFF),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isManual ? Icons.gamepad_rounded : Icons.auto_mode_rounded,
              color: isManual ? const Color(0xFFFFAA00) : const Color(0xFF00CFFF),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              isManual ? 'MANUAL' : 'AUTO',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isManual ? const Color(0xFFFFAA00) : const Color(0xFF00CFFF),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}