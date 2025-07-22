import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/reminder.dart';
import '../models/reminder.dart';
import '../widgets/button.dart';
import '../utils/validators.dart';
import '../design_system/app_colors.dart';
import '../design_system/typography.dart';

class AddReminderScreen extends StatefulWidget {
  final Reminder? existingReminder;
  final ReminderType? initialType;

  const AddReminderScreen({
    super.key,
    this.existingReminder,
    this.initialType,
  });

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  ReminderType _selectedType = ReminderType.custom;
  ReminderFrequency _selectedFrequency = ReminderFrequency.once;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isEnabled = true;
  Set<int> _selectedWeekdays = {};
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.existingReminder != null) {
      final reminder = widget.existingReminder!;
      _titleController.text = reminder.title;
      _descriptionController.text = reminder.description ?? '';
      _selectedType = reminder.type;
      _selectedFrequency = reminder.frequency;
      _selectedDate = reminder.scheduledTime;
      _selectedTime = TimeOfDay.fromDateTime(reminder.scheduledTime);
      _isEnabled = reminder.isEnabled;
      _selectedWeekdays = Set.from(reminder.weekdays);
      _endDate = reminder.endDate;
    } else if (widget.initialType != null) {
      _selectedType = widget.initialType!;
      _setDefaultsForType(_selectedType);
    }
  }

  void _setDefaultsForType(ReminderType type) {
    switch (type) {
      case ReminderType.medication:
        _titleController.text = 'Take Medication';
        _selectedFrequency = ReminderFrequency.daily;
        _selectedTime = const TimeOfDay(hour: 8, minute: 0);
        break;
      case ReminderType.hydration:
        _titleController.text = 'Drink Water';
        _selectedFrequency = ReminderFrequency.daily;
        _selectedTime = const TimeOfDay(hour: 10, minute: 0);
        break;
      case ReminderType.exercise:
        _titleController.text = 'Exercise Time';
        _selectedFrequency = ReminderFrequency.custom;
        _selectedWeekdays = {1, 3, 5}; // Mon, Wed, Fri
        _selectedTime = const TimeOfDay(hour: 18, minute: 0);
        break;
      case ReminderType.meditation:
        _titleController.text = 'Meditation Break';
        _selectedFrequency = ReminderFrequency.daily;
        _selectedTime = const TimeOfDay(hour: 7, minute: 0);
        break;
      case ReminderType.sleep:
        _titleController.text = 'Bedtime Reminder';
        _selectedFrequency = ReminderFrequency.daily;
        _selectedTime = const TimeOfDay(hour: 22, minute: 0);
        break;
      case ReminderType.meal:
        _titleController.text = 'Meal Time';
        _selectedFrequency = ReminderFrequency.daily;
        _selectedTime = const TimeOfDay(hour: 12, minute: 0);
        break;
      case ReminderType.custom:
        break;
    }
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
          widget.existingReminder != null ? 'Edit Reminder' : 'Add Reminder',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.md),
            child: SelfCoachIconButton(
              icon: Icons.save_rounded,
              onPressed: _isLoading ? null : _saveReminder,
              tooltip: 'Save',
              backgroundColor: AppColors.primaryContainer,
              color: AppColors.primary,
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
            padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: AppSpacing.md),
              _buildTypeSection(),
              const SizedBox(height: AppSpacing.md),
              _buildScheduleSection(),
              const SizedBox(height: AppSpacing.md),
              _buildFrequencySection(),
              if (_selectedFrequency == ReminderFrequency.custom) ...[
                const SizedBox(height: AppSpacing.md),
                _buildWeekdaysSection(),
              ],
              const SizedBox(height: AppSpacing.md),
              _buildAdvancedSection(),
              const SizedBox(height: AppSpacing.lg),
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.lg),
                child: SelfCoachButton(
                  text: widget.existingReminder != null ? 'Update Reminder' : 'Create Reminder',
                  icon: widget.existingReminder != null ? Icons.update_rounded : Icons.add_rounded,
                  onPressed: _isLoading ? null : _saveReminder,
                  isLoading: _isLoading,
                  fullWidth: true,
                  size: ButtonSize.large,
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              validator: (value) => Validators.required(value, fieldName: 'Title'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.sm),
            SwitchListTile(
              title: const Text('Enable Reminder'),
              subtitle: const Text('Turn on to receive notifications'),
              value: _isEnabled,
              onChanged: (value) => setState(() => _isEnabled = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reminder Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ReminderType.values.map((type) {
                final isSelected = _selectedType == type;
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getTypeIcon(type),
                        size: 16,
                        color: isSelected ? Colors.white : _getTypeColor(type),
                      ),
                      const SizedBox(width: 4),
                      Text(_getTypeLabel(type)),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedType = type;
                        if (widget.existingReminder == null) {
                          _setDefaultsForType(type);
                        }
                      });
                    }
                  },
                  backgroundColor: _getTypeColor(type).withValues(alpha: 0.1),
                  selectedColor: _getTypeColor(type),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Schedule',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (_selectedFrequency == ReminderFrequency.once) ...[
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date'),
                subtitle: Text(_formatDate(_selectedDate)),
                onTap: _selectDate,
              ),
              const Divider(),
            ],
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Time'),
              subtitle: Text(_selectedTime.format(context)),
              onTap: _selectTime,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequency',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...ReminderFrequency.values.map((frequency) {
              return RadioListTile<ReminderFrequency>(
                title: Text(_getFrequencyLabel(frequency)),
                subtitle: Text(_getFrequencyDescription(frequency)),
                value: frequency,
                groupValue: _selectedFrequency,
                onChanged: (value) {
                  setState(() {
                    _selectedFrequency = value!;
                    if (value == ReminderFrequency.custom) {
                      _selectedWeekdays = {1, 2, 3, 4, 5}; // Weekdays default
                    }
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdaysSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Days',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              children: [
                for (int day = 1; day <= 7; day++)
                  FilterChip(
                    label: Text(_getDayLabel(day)),
                    selected: _selectedWeekdays.contains(day),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedWeekdays.add(day);
                        } else {
                          _selectedWeekdays.remove(day);
                        }
                      });
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advanced Options',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              leading: const Icon(Icons.event_busy),
              title: const Text('End Date (Optional)'),
              subtitle: Text(_endDate != null ? _formatDate(_endDate!) : 'No end date'),
              trailing: _endDate != null 
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _endDate = null),
                    )
                  : null,
              onTap: _selectEndDate,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFrequency == ReminderFrequency.custom && _selectedWeekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one day for custom frequency')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final scheduledDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final reminder = widget.existingReminder?.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      type: _selectedType,
      scheduledTime: scheduledDateTime,
      frequency: _selectedFrequency,
      isEnabled: _isEnabled,
      weekdays: _selectedFrequency == ReminderFrequency.custom 
          ? _selectedWeekdays.toList()
          : [],
      endDate: _endDate,
      updatedAt: DateTime.now(),
    ) ?? Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      type: _selectedType,
      scheduledTime: scheduledDateTime,
      frequency: _selectedFrequency,
      isEnabled: _isEnabled,
      weekdays: _selectedFrequency == ReminderFrequency.custom 
          ? _selectedWeekdays.toList()
          : [],
      endDate: _endDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final reminderState = context.read<ReminderState>();
    // Initialize API service with context
    reminderState.initializeApiService(context);
    
    final success = widget.existingReminder != null
        ? await reminderState.updateReminder(reminder)
        : await reminderState.addReminder(reminder);

    if (mounted) {
      setState(() => _isLoading = false);
      
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingReminder != null 
                ? 'Reminder updated successfully' 
                : 'Reminder created successfully'),
          ),
        );
      }
    }
  }

  Color _getTypeColor(ReminderType type) {
    switch (type) {
      case ReminderType.medication: return AppColors.error;
      case ReminderType.hydration: return AppColors.info;
      case ReminderType.exercise: return AppColors.success;
      case ReminderType.meditation: return AppColors.meditation;
      case ReminderType.sleep: return AppColors.sleep;
      case ReminderType.meal: return AppColors.warning;
      case ReminderType.custom: return AppColors.onSurfaceVariant;
    }
  }

  IconData _getTypeIcon(ReminderType type) {
    switch (type) {
      case ReminderType.medication: return Icons.medication;
      case ReminderType.hydration: return Icons.water_drop;
      case ReminderType.exercise: return Icons.fitness_center;
      case ReminderType.meditation: return Icons.self_improvement;
      case ReminderType.sleep: return Icons.bedtime;
      case ReminderType.meal: return Icons.restaurant;
      case ReminderType.custom: return Icons.notifications;
    }
  }

  String _getTypeLabel(ReminderType type) {
    switch (type) {
      case ReminderType.medication: return 'Medication';
      case ReminderType.hydration: return 'Hydration';
      case ReminderType.exercise: return 'Exercise';
      case ReminderType.meditation: return 'Meditation';
      case ReminderType.sleep: return 'Sleep';
      case ReminderType.meal: return 'Meal';
      case ReminderType.custom: return 'Custom';
    }
  }

  String _getFrequencyLabel(ReminderFrequency frequency) {
    switch (frequency) {
      case ReminderFrequency.once: return 'Once';
      case ReminderFrequency.daily: return 'Daily';
      case ReminderFrequency.weekly: return 'Weekly';
      case ReminderFrequency.custom: return 'Custom Days';
    }
  }

  String _getFrequencyDescription(ReminderFrequency frequency) {
    switch (frequency) {
      case ReminderFrequency.once: return 'Remind me only once';
      case ReminderFrequency.daily: return 'Remind me every day';
      case ReminderFrequency.weekly: return 'Remind me every week';
      case ReminderFrequency.custom: return 'Choose specific days';
    }
  }

  String _getDayLabel(int day) {
    switch (day) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}