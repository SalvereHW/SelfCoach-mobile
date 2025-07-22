import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/health.dart';
import '../models/health_metrics.dart';
import '../utils/validators.dart';
import '../widgets/button.dart';
import '../design_system/app_colors.dart';
import '../design_system/typography.dart';

class SleepEntryScreen extends StatefulWidget {
  final SleepMetrics? existingSleep;

  const SleepEntryScreen({super.key, this.existingSleep});

  @override
  State<SleepEntryScreen> createState() => _SleepEntryScreenState();
}

class _SleepEntryScreenState extends State<SleepEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bedTimeController = TextEditingController();
  final _wakeTimeController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  SleepQuality _selectedQuality = SleepQuality.good;
  TimeOfDay? _bedTime;
  TimeOfDay? _wakeTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingSleep != null) {
      _initializeWithExistingData();
    }
  }

  void _initializeWithExistingData() {
    final sleep = widget.existingSleep!;
    _selectedDate = sleep.date;
    _selectedQuality = sleep.quality;
    _notesController.text = sleep.notes ?? '';
    
    if (sleep.bedTime != null) {
      _bedTime = TimeOfDay.fromDateTime(sleep.bedTime!);
      _bedTimeController.text = _bedTime!.format(context);
    }
    
    if (sleep.wakeTime != null) {
      _wakeTime = TimeOfDay.fromDateTime(sleep.wakeTime!);
      _wakeTimeController.text = _wakeTime!.format(context);
    }
  }

  @override
  void dispose() {
    _bedTimeController.dispose();
    _wakeTimeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Duration? get _sleepDuration {
    if (_bedTime == null || _wakeTime == null) return null;
    
    final bedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _bedTime!.hour,
      _bedTime!.minute,
    );
    
    var wakeDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _wakeTime!.hour,
      _wakeTime!.minute,
    );
    
    // If wake time is before bed time, assume it's the next day
    if (wakeDateTime.isBefore(bedDateTime)) {
      wakeDateTime = wakeDateTime.add(const Duration(days: 1));
    }
    
    return wakeDateTime.difference(bedDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          widget.existingSleep != null ? 'Edit Sleep' : 'Log Sleep',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (widget.existingSleep != null)
            Container(
              margin: const EdgeInsets.only(right: AppSpacing.md),
              child: SelfCoachIconButton(
                icon: Icons.delete_rounded,
                onPressed: _deleteSleep,
                tooltip: 'Delete',
                backgroundColor: AppColors.errorContainer,
                color: AppColors.error,
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backgroundGradient,
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateSection(),
              const SizedBox(height: AppSpacing.md),
              _buildTimeSection(),
              const SizedBox(height: AppSpacing.md),
              _buildQualitySection(),
              const SizedBox(height: AppSpacing.md),
              _buildNotesSection(),
              const SizedBox(height: AppSpacing.lg),
              _buildSubmitButton(),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sleep Date',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(DateTimeValidators.formatDate(_selectedDate)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _selectDate,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sleep Times',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _bedTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Bed Time',
                      prefixIcon: Icon(Icons.bedtime),
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () => _selectTime(true),
                    validator: (value) => value?.isEmpty == true ? 'Bed time is required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _wakeTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Wake Time',
                      prefixIcon: Icon(Icons.wb_sunny),
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () => _selectTime(false),
                    validator: (value) => value?.isEmpty == true ? 'Wake time is required' : null,
                  ),
                ),
              ],
            ),
            if (_sleepDuration != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Duration: ${NumberFormatters.formatDuration(_sleepDuration!)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQualitySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sleep Quality',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              children: SleepQuality.values.map((quality) {
                final isSelected = _selectedQuality == quality;
                return ChoiceChip(
                  label: Text(_getQualityLabel(quality)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedQuality = quality;
                      });
                    }
                  },
                  avatar: isSelected ? null : Text(_getQualityEmoji(quality)),
                  selectedColor: _getQualityColor(quality).withValues(alpha: 0.3),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'How was your sleep? Any factors that affected it?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: Validators.notes,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Consumer<HealthState>(
      builder: (context, healthState, child) {
        return SelfCoachButton(
          text: widget.existingSleep != null ? 'Update Sleep' : 'Save Sleep',
          icon: Icons.save,
          fullWidth: true,
          isLoading: _isLoading || healthState.isLoading,
          onPressed: _isLoading || healthState.isLoading ? null : _saveSleep,
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(bool isBedTime) async {
    final initialTime = isBedTime ? _bedTime : _wakeTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
    );
    
    if (picked != null) {
      setState(() {
        if (isBedTime) {
          _bedTime = picked;
          _bedTimeController.text = picked.format(context);
        } else {
          _wakeTime = picked;
          _wakeTimeController.text = picked.format(context);
        }
      });
    }
  }

  String _getQualityLabel(SleepQuality quality) {
    switch (quality) {
      case SleepQuality.poor:
        return 'Poor';
      case SleepQuality.fair:
        return 'Fair';
      case SleepQuality.good:
        return 'Good';
      case SleepQuality.excellent:
        return 'Excellent';
    }
  }

  String _getQualityEmoji(SleepQuality quality) {
    switch (quality) {
      case SleepQuality.poor:
        return '😴';
      case SleepQuality.fair:
        return '😐';
      case SleepQuality.good:
        return '😊';
      case SleepQuality.excellent:
        return '🌟';
    }
  }

  Color _getQualityColor(SleepQuality quality) {
    switch (quality) {
      case SleepQuality.poor:
        return AppColors.error;
      case SleepQuality.fair:
        return AppColors.warning;
      case SleepQuality.good:
        return AppColors.info;
      case SleepQuality.excellent:
        return AppColors.success;
    }
  }

  Future<void> _saveSleep() async {
    if (!_formKey.currentState!.validate()) return;
    if (_bedTime == null || _wakeTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both bed time and wake time')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final sleepMetrics = SleepMetrics(
        id: widget.existingSleep?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        date: _selectedDate,
        bedTime: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _bedTime!.hour,
          _bedTime!.minute,
        ),
        wakeTime: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _wakeTime!.hour,
          _wakeTime!.minute,
        ),
        duration: _sleepDuration,
        quality: _selectedQuality,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      final healthState = context.read<HealthState>();
      // Initialize API service with context
      healthState.initializeApiService(context);
      
      bool success;
      
      if (widget.existingSleep != null) {
        success = await healthState.updateSleepData(sleepMetrics);
      } else {
        success = await healthState.addSleepData(sleepMetrics);
      }

      if (success && mounted) {
        Navigator.of(context).pop();
        // Don't show snackbar after navigation to avoid widget deactivation error
      } else if (mounted) {
        // Show error but don't navigate away - let user try again
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(healthState.errorMessage ?? 'Failed to save sleep data'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteSleep() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sleep Entry'),
        content: const Text('Are you sure you want to delete this sleep entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.existingSleep != null && mounted) {
      final healthState = context.read<HealthState>();
      final success = await healthState.deleteSleepData(widget.existingSleep!.id);
      
      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sleep entry deleted')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete sleep entry')),
        );
      }
    }
  }
}