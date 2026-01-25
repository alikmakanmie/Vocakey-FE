import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import '../../../../core/utils/responsive_helper.dart';

class BirdAnimationWidget extends StatefulWidget {
  final bool isRecording;
  final double audioLevel;
  
  const BirdAnimationWidget({
    Key? key,
    required this.isRecording,
    this.audioLevel = 0.0,
  }) : super(key: key);
  
  @override
  State<BirdAnimationWidget> createState() => _BirdAnimationWidgetState();
}

class _BirdAnimationWidgetState extends State<BirdAnimationWidget> {
  StateMachineController? _controller;
  SMITrigger? _whistle;
  SMIBool? _isWhistling;
  SMINumber? _intensity;
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ResponsiveHelper.width(200),
      height: ResponsiveHelper.height(200),
      child: RiveAnimation.asset(
        'assets/animations/bird_whistle.riv',
        stateMachines: const ['State Machine 1'],
        onInit: _onRiveInit,
      ),
    );
  }
  
  void _onRiveInit(Artboard artboard) {
    _controller = StateMachineController.fromArtboard(
      artboard,
      'State Machine 1',
    );
    
    if (_controller != null) {
      artboard.addController(_controller!);
      _whistle = _controller!.findInput<bool>('whistle') as SMITrigger?;
      _isWhistling = _controller!.findInput<bool>('isWhistling') as SMIBool?;
      _intensity = _controller!.findInput<double>('intensity') as SMINumber?;
    }
  }
  
  @override
  void didUpdateWidget(BirdAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isRecording != oldWidget.isRecording) {
      if (widget.isRecording) {
        _whistle?.fire();
        _isWhistling?.value = true;
      } else {
        _isWhistling?.value = false;
      }
    }
    
    if (widget.audioLevel != oldWidget.audioLevel) {
      _intensity?.value = widget.audioLevel;
    }
  }
  
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
