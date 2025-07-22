import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/health.dart';
import '../models/health_metrics.dart';
import '../utils/validators.dart';
import '../widgets/button.dart';
import '../design_system/app_colors.dart';
import '../design_system/typography.dart';

class NutritionEntryScreen extends StatefulWidget {
  final NutritionMetrics? existingNutrition;

  const NutritionEntryScreen({super.key, this.existingNutrition});

  @override
  State<NutritionEntryScreen> createState() => _NutritionEntryScreenState();
}

class _NutritionEntryScreenState extends State<NutritionEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _foodNameController = TextEditingController();
  final _servingSizeController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatsController = TextEditingController();
  final _waterController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  MealType _selectedMealType = MealType.breakfast;
  String _servingUnit = 'cups';
  bool _isLoading = false;

  final List<String> _servingUnits = [
    'cups', 'grams', 'ounces', 'pieces', 'tablespoons', 'teaspoons', 'slices', 'medium', 'large', 'small'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingNutrition != null) {
      _initializeWithExistingData();
    }
  }

  void _initializeWithExistingData() {
    final nutrition = widget.existingNutrition!;
    _selectedDate = nutrition.date;
    _selectedMealType = nutrition.mealType;
    _foodNameController.text = nutrition.foodName;
    _servingSizeController.text = nutrition.servingSize.toString();
    _servingUnit = nutrition.servingUnit;
    _caloriesController.text = nutrition.calories?.toString() ?? '';
    _proteinController.text = nutrition.protein?.toString() ?? '';
    _carbsController.text = nutrition.carbs?.toString() ?? '';
    _fatsController.text = nutrition.fats?.toString() ?? '';
    _waterController.text = nutrition.waterIntake?.toString() ?? '';
    _notesController.text = nutrition.notes ?? '';
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _servingSizeController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    _waterController.dispose();
    _notesController.dispose();
    super.dispose();
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
          widget.existingNutrition != null ? 'Edit Meal' : 'Log Meal',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (widget.existingNutrition != null)
            Container(
              margin: const EdgeInsets.only(right: AppSpacing.md),
              child: SelfCoachIconButton(
                icon: Icons.delete_rounded,
                onPressed: _deleteNutrition,
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
              _buildDateAndMealSection(),
              const SizedBox(height: AppSpacing.md),
              _buildFoodInfoSection(),
              const SizedBox(height: AppSpacing.md),
              _buildNutritionSection(),
              const SizedBox(height: AppSpacing.md),
              _buildHydrationSection(),
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

  Widget _buildDateAndMealSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Meal Details',
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
              'Meal Type',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: 8,
              children: MealType.values.map((mealType) {
                final isSelected = _selectedMealType == mealType;
                return ChoiceChip(
                  label: Text(_getMealTypeLabel(mealType)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedMealType = mealType;
                      });
                    }
                  },
                  avatar: isSelected ? null : Text(_getMealTypeEmoji(mealType)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Food Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _foodNameController,
              decoration: const InputDecoration(
                labelText: 'Food Name',
                hintText: 'e.g., Grilled Chicken Breast',
                prefixIcon: Icon(Icons.restaurant),
                border: OutlineInputBorder(),
              ),
              validator: (value) => Validators.required(value, fieldName: 'Food name'),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _servingSizeController,
                    decoration: const InputDecoration(
                      labelText: 'Serving Size',
                      hintText: '1',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: Validators.servingSize,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _servingUnit,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                    ),
                    items: _servingUnits.map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _servingUnit = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nutrition Facts (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _caloriesController,
              decoration: const InputDecoration(
                labelText: 'Calories',
                hintText: '250',
                suffixText: 'kcal',
                prefixIcon: Icon(Icons.local_fire_department),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: Validators.calories,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _proteinController,
                    decoration: const InputDecoration(
                      labelText: 'Protein',
                      hintText: '25',
                      suffixText: 'g',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isNotEmpty == true ? Validators.positiveNumber(value, fieldName: 'Protein') : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _carbsController,
                    decoration: const InputDecoration(
                      labelText: 'Carbs',
                      hintText: '10',
                      suffixText: 'g',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isNotEmpty == true ? Validators.positiveNumber(value, fieldName: 'Carbs') : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _fatsController,
                    decoration: const InputDecoration(
                      labelText: 'Fats',
                      hintText: '8',
                      suffixText: 'g',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isNotEmpty == true ? Validators.positiveNumber(value, fieldName: 'Fats') : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHydrationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hydration (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _waterController,
              decoration: const InputDecoration(
                labelText: 'Water Intake',
                hintText: '250',
                suffixText: 'ml',
                prefixIcon: Icon(Icons.water_drop),
                border: OutlineInputBorder(),
                helperText: 'Track water consumed with this meal',
              ),
              keyboardType: TextInputType.number,
              validator: Validators.waterIntake,
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
                hintText: 'How did you feel after eating? Any cultural preferences or special ingredients?',
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
          text: widget.existingNutrition != null ? 'Update Meal' : 'Save Meal',
          icon: Icons.save,
          fullWidth: true,
          isLoading: _isLoading || healthState.isLoading,
          onPressed: _isLoading || healthState.isLoading ? null : _saveNutrition,
        );
      },
    );
  }

  String _getMealTypeLabel(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  String _getMealTypeEmoji(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '☀️';
      case MealType.dinner:
        return '🌙';
      case MealType.snack:
        return '🍎';
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

  Future<void> _saveNutrition() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final nutritionMetrics = NutritionMetrics(
        id: widget.existingNutrition?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        date: _selectedDate,
        mealType: _selectedMealType,
        foodName: _foodNameController.text.trim(),
        servingSize: double.parse(_servingSizeController.text),
        servingUnit: _servingUnit,
        calories: _caloriesController.text.trim().isEmpty ? null : int.parse(_caloriesController.text),
        protein: _proteinController.text.trim().isEmpty ? null : double.parse(_proteinController.text),
        carbs: _carbsController.text.trim().isEmpty ? null : double.parse(_carbsController.text),
        fats: _fatsController.text.trim().isEmpty ? null : double.parse(_fatsController.text),
        waterIntake: _waterController.text.trim().isEmpty ? null : int.parse(_waterController.text),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      final healthState = context.read<HealthState>();
      // Initialize API service with context
      healthState.initializeApiService(context);
      
      bool success;
      
      if (widget.existingNutrition != null) {
        success = await healthState.updateNutritionData(nutritionMetrics);
      } else {
        success = await healthState.addNutritionData(nutritionMetrics);
      }

      if (success && mounted) {
        Navigator.of(context).pop();
        // Don't show snackbar after navigation to avoid widget deactivation error
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(healthState.errorMessage ?? 'Failed to save meal'),
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

  Future<void> _deleteNutrition() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal Entry'),
        content: const Text('Are you sure you want to delete this meal entry?'),
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

    if (confirmed == true && widget.existingNutrition != null && mounted) {
      final healthState = context.read<HealthState>();
      final success = await healthState.deleteNutritionData(widget.existingNutrition!.id);
      
      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal entry deleted')),
        );
      }
    }
  }
}