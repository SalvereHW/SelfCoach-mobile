import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/wellness.dart';
import '../models/wellness_session.dart';
import '../widgets/button.dart';

class SessionPlayerScreen extends StatefulWidget {
  final WellnessSession session;

  const SessionPlayerScreen({super.key, required this.session});

  @override
  State<SessionPlayerScreen> createState() => _SessionPlayerScreenState();
}

class _SessionPlayerScreenState extends State<SessionPlayerScreen> with TickerProviderStateMixin {
  Timer? _timer;
  Duration _currentTime = Duration.zero;
  bool _isPlaying = false;
  bool _isCompleted = false;
  int _currentInstructionIndex = 0;
  
  late AnimationController _breathingController;
  late AnimationController _pulseController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSession();
    });
  }

  void _initializeAnimations() {
    _breathingController = AnimationController(
      duration: const Duration(seconds: 8), // 4-4 breathing pattern
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _breathingAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.session.type == WellnessSessionType.breathing) {
      _breathingController.repeat(reverse: true);
    }
    
    _pulseController.repeat(reverse: true);
  }

  void _startSession() {
    context.read<WellnessState>().startSession(widget.session.id);
    _isPlaying = true;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPlaying && !_isCompleted) {
        setState(() {
          _currentTime = _currentTime + const Duration(seconds: 1);
          
          // Update instruction index based on time
          final totalInstructions = widget.session.instructions.length;
          if (totalInstructions > 0) {
            final timePerInstruction = widget.session.duration.inSeconds / totalInstructions;
            _currentInstructionIndex = (_currentTime.inSeconds / timePerInstruction).floor()
                .clamp(0, totalInstructions - 1);
          }
          
          // Check if session is completed
          if (_currentTime >= widget.session.duration) {
            _completeSession();
          }
        });
        
        context.read<WellnessState>().updateSessionProgress(_currentTime);
      }
    });
  }

  void _pauseSession() {
    setState(() => _isPlaying = false);
    context.read<WellnessState>().pauseSession();
    _breathingController.stop();
  }

  void _resumeSession() {
    setState(() => _isPlaying = true);
    context.read<WellnessState>().resumeSession();
    if (widget.session.type == WellnessSessionType.breathing && !_isCompleted) {
      _breathingController.repeat(reverse: true);
    }
  }

  void _completeSession() {
    setState(() {
      _isCompleted = true;
      _isPlaying = false;
    });
    _timer?.cancel();
    _breathingController.stop();
    _showCompletionDialog();
  }

  void _endSession() {
    context.read<WellnessState>().endSession();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session.title),
        actions: [
          if (!_isCompleted)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _showExitDialog,
            ),
        ],
      ),
      body: Container(
        decoration: _buildBackgroundDecoration(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProgressSection(),
                const SizedBox(height: 32),
                Expanded(child: _buildMainContent()),
                const SizedBox(height: 32),
                _buildControlsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    Color primaryColor = _getSessionColor();
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withValues(alpha: 0.1),
          primaryColor.withValues(alpha: 0.05),
          Colors.white,
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    final progress = _currentTime.inSeconds / widget.session.duration.inSeconds;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatTime(_currentTime),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _formatTime(widget.session.duration),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(_getSessionColor()),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    if (_isCompleted) {
      return _buildCompletionContent();
    }

    switch (widget.session.type) {
      case WellnessSessionType.breathing:
        return _buildBreathingContent();
      case WellnessSessionType.meditation:
        return _buildMeditationContent();
      default:
        return _buildDefaultContent();
    }
  }

  Widget _buildBreathingContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _breathingAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _breathingAnimation.value,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getSessionColor().withValues(alpha: 0.3),
                  border: Border.all(
                    color: _getSessionColor(),
                    width: 4,
                  ),
                ),
                child: Icon(
                  Icons.air,
                  size: 80,
                  color: _getSessionColor(),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 48),
        Text(
          _getBreathingInstruction(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: _getSessionColor(),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (widget.session.instructions.isNotEmpty && _currentInstructionIndex < widget.session.instructions.length)
          Text(
            widget.session.instructions[_currentInstructionIndex],
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  Widget _buildMeditationContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getSessionColor().withValues(alpha: 0.2),
                ),
                child: Icon(
                  Icons.self_improvement,
                  size: 60,
                  color: _getSessionColor(),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 48),
        Text(
          'Find your center',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: _getSessionColor(),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (widget.session.instructions.isNotEmpty && _currentInstructionIndex < widget.session.instructions.length)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              widget.session.instructions[_currentInstructionIndex],
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildDefaultContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _getSessionIcon(),
          size: 100,
          color: _getSessionColor(),
        ),
        const SizedBox(height: 32),
        Text(
          widget.session.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        if (widget.session.instructions.isNotEmpty && _currentInstructionIndex < widget.session.instructions.length)
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              widget.session.instructions[_currentInstructionIndex],
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildCompletionContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle,
          size: 100,
          color: Colors.green,
        ),
        const SizedBox(height: 24),
        Text(
          'Session Complete!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Great job completing "${widget.session.title}"',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        if (widget.session.benefits.isNotEmpty) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Benefits you just gained:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...widget.session.benefits.map((benefit) => 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.check, color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(benefit)),
                      ],
                    ),
                  )),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildControlsSection() {
    if (_isCompleted) {
      return Column(
        children: [
          SelfCoachButton(
            text: 'Rate this Session',
            icon: Icons.star,
            onPressed: _showRatingDialog,
            fullWidth: true,
          ),
          const SizedBox(height: 12),
          SelfCoachButton.outline(
            text: 'Back to Sessions',
            onPressed: _endSession,
            fullWidth: true,
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SelfCoachButton.outline(
          text: 'End Session',
          icon: Icons.stop,
          onPressed: _showExitDialog,
        ),
        SelfCoachButton(
          text: _isPlaying ? 'Pause' : 'Resume',
          icon: _isPlaying ? Icons.pause : Icons.play_arrow,
          onPressed: _isPlaying ? _pauseSession : _resumeSession,
        ),
      ],
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Session?'),
        content: const Text('Are you sure you want to end this session? Your progress will be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _endSession();
            },
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('🎉 Session Complete!'),
            content: Text('Congratulations on completing "${widget.session.title}"!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continue'),
              ),
            ],
          ),
        );
      }
    });
  }

  void _showRatingDialog() {
    int selectedRating = 5;
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Rate this Session'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How was your experience?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () => setState(() => selectedRating = index + 1),
                    icon: Icon(
                      index < selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: feedbackController,
                decoration: const InputDecoration(
                  labelText: 'Feedback (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Skip'),
            ),
            TextButton(
              onPressed: () {
                context.read<WellnessState>().completeSession(
                  rating: selectedRating,
                  feedback: feedbackController.text.trim().isNotEmpty 
                      ? feedbackController.text.trim() 
                      : null,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  String _getBreathingInstruction() {
    final cycle = (_currentTime.inSeconds % 8);
    if (cycle < 4) {
      return 'Breathe In';
    } else {
      return 'Breathe Out';
    }
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color _getSessionColor() {
    switch (widget.session.type) {
      case WellnessSessionType.meditation: return Colors.purple;
      case WellnessSessionType.breathing: return Colors.blue;
      case WellnessSessionType.workout: return Colors.red;
      case WellnessSessionType.stretching: return Colors.green;
      case WellnessSessionType.mindfulness: return Colors.indigo;
      case WellnessSessionType.relaxation: return Colors.teal;
      case WellnessSessionType.yoga: return Colors.orange;
      case WellnessSessionType.pilates: return Colors.pink;
      case WellnessSessionType.cardio: return Colors.deepOrange;
      case WellnessSessionType.strength: return Colors.brown;
      case WellnessSessionType.mobility: return Colors.cyan;
      case WellnessSessionType.recovery: return Colors.lightGreen;
      case WellnessSessionType.sleep: return Colors.deepPurple;
      case WellnessSessionType.focus: return Colors.amber;
      case WellnessSessionType.creativity: return Colors.lime;
      case WellnessSessionType.gratitude: return Colors.yellow;
    }
  }

  IconData _getSessionIcon() {
    switch (widget.session.type) {
      case WellnessSessionType.meditation: return Icons.self_improvement;
      case WellnessSessionType.breathing: return Icons.air;
      case WellnessSessionType.workout: return Icons.fitness_center;
      case WellnessSessionType.stretching: return Icons.accessibility_new;
      case WellnessSessionType.mindfulness: return Icons.psychology;
      case WellnessSessionType.relaxation: return Icons.spa;
      case WellnessSessionType.yoga: return Icons.sports_gymnastics;
      case WellnessSessionType.pilates: return Icons.sports_handball;
      case WellnessSessionType.cardio: return Icons.directions_run;
      case WellnessSessionType.strength: return Icons.sports_mma;
      case WellnessSessionType.mobility: return Icons.accessibility;
      case WellnessSessionType.recovery: return Icons.healing;
      case WellnessSessionType.sleep: return Icons.bedtime;
      case WellnessSessionType.focus: return Icons.center_focus_strong;
      case WellnessSessionType.creativity: return Icons.palette;
      case WellnessSessionType.gratitude: return Icons.favorite;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}