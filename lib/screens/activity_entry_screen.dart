import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/health.dart';
import '../models/health_metrics.dart';
import '../utils/validators.dart';
import '../widgets/button.dart';
import '../design_system/app_colors.dart';
import '../design_system/typography.dart';

class ActivityEntryScreen extends StatefulWidget {
  final ActivityMetrics? existingActivity;

  const ActivityEntryScreen({super.key, this.existingActivity});

  @override
  State<ActivityEntryScreen> createState() => _ActivityEntryScreenState();
}

class _ActivityEntryScreenState extends State<ActivityEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _activityNameController = TextEditingController();
  final _durationController = TextEditingController();
  final _caloriesBurnedController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _stepsController = TextEditingController();
  final _distanceController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  ActivityType _selectedActivityType = ActivityType.walking;
  ActivityIntensity _selectedIntensity = ActivityIntensity.moderate;
  String _distanceUnit = 'km';
  bool _isLoading = false;

  final List<String> _distanceUnits = ['km', 'miles', 'meters', 'yards'];

  @override
  void initState() {
    super.initState();
    if (widget.existingActivity != null) {
      _initializeWithExistingData();
    }
  }

  void _initializeWithExistingData() {
    final activity = widget.existingActivity!;
    _selectedDate = activity.date;
    _selectedActivityType = activity.activityType;
    _selectedIntensity = activity.intensity;
    _activityNameController.text = activity.activityName;
    _durationController.text = activity.duration?.inMinutes.toString() ?? '';
    _caloriesBurnedController.text = activity.caloriesBurned?.toString() ?? '';
    _heartRateController.text = activity.averageHeartRate?.toString() ?? '';
    _stepsController.text = activity.steps?.toString() ?? '';
    _distanceController.text = activity.distance?.toString() ?? '';
    _distanceUnit = activity.distanceUnit ?? 'km';
    _notesController.text = activity.notes ?? '';
  }

  @override
  void dispose() {
    _activityNameController.dispose();
    _durationController.dispose();
    _caloriesBurnedController.dispose();
    _heartRateController.dispose();
    _stepsController.dispose();
    _distanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          widget.existingActivity != null ? 'Edit Activity' : 'Log Activity',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (widget.existingActivity != null)
            Container(
              margin: const EdgeInsets.only(right: AppSpacing.md),
              child: SelfCoachIconButton(
                icon: Icons.delete_rounded,
                onPressed: _deleteActivity,
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
              _buildDateAndTypeSection(),
              const SizedBox(height: AppSpacing.md),
              _buildActivityDetailsSection(),
              const SizedBox(height: AppSpacing.md),
              _buildMetricsSection(),
              const SizedBox(height: AppSpacing.md),
              _buildPerformanceSection(),
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

  Widget _buildDateAndTypeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text('Date'),
              subtitle: Text(DateTimeValidators.formatDate(_selectedDate)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _selectDate,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Activity Type',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: 8,
              children: ActivityType.values.map((activityType) {
                final isSelected = _selectedActivityType == activityType;
                return ChoiceChip(
                  label: Text(_getActivityTypeLabel(activityType)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedActivityType = activityType;
                      });
                    }
                  },
                  avatar: isSelected ? null : Text(_getActivityTypeEmoji(activityType)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _activityNameController,
              decoration: const InputDecoration(
                labelText: 'Activity Name',
                hintText: 'e.g., Morning Run, Yoga Session',
                prefixIcon: Icon(Icons.directions_run),
                border: OutlineInputBorder(),
              ),
              validator: (value) => Validators.required(value, fieldName: 'Activity name'),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Duration',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TextFormField(
                        controller: _durationController,
                        decoration: const InputDecoration(
                          hintText: '30',
                          suffixText: 'minutes',
                          prefixIcon: Icon(Icons.access_time),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: Validators.activityDuration,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Intensity',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      DropdownButtonFormField<ActivityIntensity>(
                        value: _selectedIntensity,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: ActivityIntensity.values.map((intensity) {
                          return DropdownMenuItem(
                            value: intensity,
                            child: Text(_getIntensityLabel(intensity)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedIntensity = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Metrics (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _caloriesBurnedController,
                    decoration: const InputDecoration(
                      labelText: 'Calories Burned',
                      hintText: '250',
                      suffixText: 'kcal',
                      prefixIcon: Icon(Icons.local_fire_department),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: Validators.calories,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _heartRateController,
                    decoration: const InputDecoration(
                      labelText: 'Avg Heart Rate',
                      hintText: '140',
                      suffixText: 'bpm',
                      prefixIcon: Icon(Icons.favorite),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: Validators.heartRate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stepsController,
                    decoration: const InputDecoration(
                      labelText: 'Steps',
                      hintText: '5000',
                      prefixIcon: Icon(Icons.directions_walk),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isNotEmpty == true ? Validators.positiveNumber(value, fieldName: 'Steps') : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _distanceController,
                          decoration: const InputDecoration(
                            labelText: 'Distance',
                            hintText: '5.2',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) => value?.isNotEmpty == true ? Validators.positiveNumber(value, fieldName: 'Distance') : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          value: _distanceUnit,
                          decoration: const InputDecoration(
                            labelText: 'Unit',
                            border: OutlineInputBorder(),
                          ),
                          items: _distanceUnits.map((unit) {
                            return DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _distanceUnit = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Indicator',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getIntensityColor(_selectedIntensity).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getIntensityColor(_selectedIntensity).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getIntensityIcon(_selectedIntensity),
                    color: _getIntensityColor(_selectedIntensity),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_getIntensityLabel(_selectedIntensity)} Intensity',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _getIntensityColor(_selectedIntensity),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
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
                hintText: 'How did you feel? Any challenges or achievements?',
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
          text: widget.existingActivity != null ? 'Update Activity' : 'Save Activity',
          icon: Icons.save,
          fullWidth: true,
          isLoading: _isLoading || healthState.isLoading,
          onPressed: _isLoading || healthState.isLoading ? null : _saveActivity,
        );
      },
    );
  }

  String _getActivityTypeLabel(ActivityType type) {
    switch (type) {
      case ActivityType.walking:
        return 'Walking';
      case ActivityType.running:
        return 'Running';
      case ActivityType.cycling:
        return 'Cycling';
      case ActivityType.swimming:
        return 'Swimming';
      case ActivityType.weightLifting:
        return 'Weight Lifting';
      case ActivityType.workout:
        return 'Workout';
      case ActivityType.yoga:
        return 'Yoga';
      case ActivityType.pilates:
        return 'Pilates';
      case ActivityType.sports:
        return 'Sports';
      case ActivityType.other:
        return 'Other';
    }
  }

  String _getActivityTypeEmoji(ActivityType type) {
    switch (type) {
      case ActivityType.walking:
        return '🚶';
      case ActivityType.running:
        return '🏃';
      case ActivityType.cycling:
        return '🚴';
      case ActivityType.swimming:
        return '🏊';
      case ActivityType.weightLifting:
        return '🏋️';
      case ActivityType.workout:
        return '💪';
      case ActivityType.yoga:
        return '🧘';
      case ActivityType.pilates:
        return '🤸';
      case ActivityType.sports:
        return '⚽';
      case ActivityType.other:
        return '🏃';
    }
  }

  String _getIntensityLabel(ActivityIntensity intensity) {
    switch (intensity) {
      case ActivityIntensity.light:
        return 'Light';
      case ActivityIntensity.moderate:
        return 'Moderate';
      case ActivityIntensity.vigorous:
        return 'Vigorous';
    }
  }

  Color _getIntensityColor(ActivityIntensity intensity) {
    switch (intensity) {
      case ActivityIntensity.light:
        return AppColors.success;
      case ActivityIntensity.moderate:
        return AppColors.warning;
      case ActivityIntensity.vigorous:
        return AppColors.error;
    }
  }

  IconData _getIntensityIcon(ActivityIntensity intensity) {
    switch (intensity) {
      case ActivityIntensity.light:
        return Icons.battery_2_bar;
      case ActivityIntensity.moderate:
        return Icons.battery_4_bar;
      case ActivityIntensity.vigorous:
        return Icons.battery_full;
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final activityMetrics = ActivityMetrics(
        id: widget.existingActivity?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        date: _selectedDate,
        activityType: _selectedActivityType,
        activityName: _activityNameController.text.trim(),
        duration: _durationController.text.trim().isEmpty ? null : Duration(minutes: int.parse(_durationController.text)),
        intensity: _selectedIntensity,
        caloriesBurned: _caloriesBurnedController.text.trim().isEmpty ? null : int.parse(_caloriesBurnedController.text),
        averageHeartRate: _heartRateController.text.trim().isEmpty ? null : int.parse(_heartRateController.text),
        steps: _stepsController.text.trim().isEmpty ? null : int.parse(_stepsController.text),
        distance: _distanceController.text.trim().isEmpty ? null : double.parse(_distanceController.text),
        distanceUnit: _distanceController.text.trim().isEmpty ? null : _distanceUnit,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      final healthState = context.read<HealthState>();
      // Initialize API service with context
      healthState.initializeApiService(context);
      
      bool success;
      
      if (widget.existingActivity != null) {
        success = await healthState.updateActivityData(activityMetrics);
      } else {
        success = await healthState.addActivityData(activityMetrics);
      }

      if (success && mounted) {
        Navigator.of(context).pop();
        // Don't show snackbar after navigation to avoid widget deactivation error
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(healthState.errorMessage ?? 'Failed to save activity'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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

  Future<void> _deleteActivity() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity Entry'),
        content: const Text('Are you sure you want to delete this activity entry?'),
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

    if (confirmed == true && widget.existingActivity != null && mounted) {
      final healthState = context.read<HealthState>();
      final success = await healthState.deleteActivityData(widget.existingActivity!.id);
      
      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity entry deleted')),
        );
      }
    }
  }
}