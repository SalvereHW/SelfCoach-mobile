import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/auth.dart' as app_auth;
import '../models/user.dart';
import '../design_system/app_colors.dart';
import '../design_system/typography.dart';
import '../widgets/button.dart';

extension SetEquality<T> on Set<T> {
  bool equals(Set<T> other) {
    if (length != other.length) return false;
    return every(other.contains);
  }
}

class HealthPlansScreen extends StatefulWidget {
  const HealthPlansScreen({super.key});

  @override
  State<HealthPlansScreen> createState() => _HealthPlansScreenState();
}

class _HealthPlansScreenState extends State<HealthPlansScreen> {
  Set<HealthCondition> _selectedConditions = {};
  Set<CulturalDiet> _selectedDiets = {};
  bool _isLoading = false;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _loadExistingPreferences();
  }

  void _loadExistingPreferences() {
    final authState = context.read<app_auth.AppAuthState>();
    final userProfile = authState.userProfile;
    
    if (userProfile != null) {
      setState(() {
        _selectedConditions = Set.from(userProfile.healthConditions);
        _selectedDiets = Set.from(userProfile.culturalDietPreferences);
        
        // If user has existing preferences, show their plan directly
        if (_selectedConditions.isNotEmpty || _selectedDiets.isNotEmpty) {
          _currentStep = 2; // Go directly to "My Plan"
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(_getAppBarTitle(), style: AppTypography.headlineSmall),
        leading: _currentStep > 0 ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goToPreviousStep,
        ) : null,
        actions: _buildAppBarActions(),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.backgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildCurrentStep(),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  String _getAppBarTitle() {
    switch (_currentStep) {
      case 0:
        return 'Health Conditions';
      case 1:
        return 'Dietary Preferences';
      case 2:
        return 'My Health Plan';
      default:
        return 'Health Plans';
    }
  }

  List<Widget> _buildAppBarActions() {
    if (_currentStep == 2) {
      return [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            onPressed: () => setState(() => _currentStep = 0),
            icon: const Icon(Icons.edit),
            tooltip: 'Edit health plan',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.all(8),
            ),
          ),
        ),
        if (_hasChanges())
          SelfCoachButton(
            text: 'Save',
            onPressed: _isLoading ? null : _savePreferences,
            isLoading: _isLoading,
          ),
      ];
    }
    return [];
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildHealthConditionsStep();
      case 1:
        return _buildCulturalDietStep();
      case 2:
        return _buildPersonalizedPlanStep();
      default:
        return _buildHealthConditionsStep();
    }
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppColors.cardShadow,
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep == 2) ...[
              // Show step indicators when viewing plan
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStepIndicator(0, 'Conditions'),
                    const SizedBox(width: 8),
                    _buildStepIndicator(1, 'Diet'),
                    const SizedBox(width: 8),
                    _buildStepIndicator(2, 'Plan'),
                  ],
                ),
              ),
            ] else ...[
              // Show navigation buttons for setup steps
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _goToPreviousStep,
                    child: const Text('Back'),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _canProceed() ? _goToNextStep : null,
                  child: Text(_currentStep == 1 ? 'View My Plan' : 'Next'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isCompleted = step < _currentStep || (step <= 1 && _currentStep == 2);
    final isCurrent = step == _currentStep;
    
    return GestureDetector(
      onTap: () => setState(() => _currentStep = step),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted || isCurrent 
                  ? Theme.of(context).colorScheme.primary 
                  : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : Icons.circle,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isCompleted || isCurrent 
                  ? Theme.of(context).colorScheme.primary 
                  : Colors.grey[600],
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    // Always allow proceeding - user can select "none" options
    return true;
  }

  void _goToNextStep() {
    if (_currentStep < 2 && _canProceed()) {
      setState(() {
        _currentStep++;
      });
    }
  }

  bool _hasChanges() {
    final authState = context.read<app_auth.AppAuthState>();
    final userProfile = authState.userProfile;
    
    if (userProfile == null) return true;
    
    final currentConditions = Set<HealthCondition>.from(userProfile.healthConditions);
    final currentDiets = Set<CulturalDiet>.from(userProfile.culturalDietPreferences);
    
    return !_selectedConditions.equals(currentConditions) || 
           !_selectedDiets.equals(currentDiets);
  }

  Widget _buildHealthConditionsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.health_and_safety,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Health Conditions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Select any health conditions you have. This helps us provide personalized recommendations tailored to your needs.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Select all that apply:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...HealthCondition.values.where((condition) => condition != HealthCondition.none).map((condition) => _buildConditionCard(condition)),
          const SizedBox(height: 16),
          _buildNoneOptionCard(),
        ],
      ),
    );
  }

  Widget _buildNoneOptionCard() {
    final isSelected = _selectedConditions.contains(HealthCondition.none) || _selectedConditions.isEmpty;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: () {
          setState(() {
            if (_selectedConditions.contains(HealthCondition.none) || _selectedConditions.isEmpty) {
              _selectedConditions.clear();
            } else {
              _selectedConditions.clear();
              _selectedConditions.add(HealthCondition.none);
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary 
                    : Colors.grey[400],
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.check_circle,
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary 
                    : Colors.grey[400],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'I don\'t have any specific health conditions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected 
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Focus on general wellness and preventive care',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected 
                            ? Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8)
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCulturalDietStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                  Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Dietary Preferences',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Select dietary preferences that align with your cultural background, health goals, or personal choices.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Select all that apply:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...CulturalDiet.values.where((diet) => diet != CulturalDiet.none).map((diet) => _buildDietCard(diet)),
          const SizedBox(height: 16),
          _buildNoDietOptionCard(),
        ],
      ),
    );
  }

  Widget _buildNoDietOptionCard() {
    final isSelected = _selectedDiets.contains(CulturalDiet.none) || _selectedDiets.isEmpty;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Theme.of(context).colorScheme.secondaryContainer : null,
      child: InkWell(
        onTap: () {
          setState(() {
            if (_selectedDiets.contains(CulturalDiet.none) || _selectedDiets.isEmpty) {
              _selectedDiets.clear();
            } else {
              _selectedDiets.clear();
              _selectedDiets.add(CulturalDiet.none);
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected 
                    ? Theme.of(context).colorScheme.secondary 
                    : Colors.grey[400],
              ),
              const SizedBox(width: 16),
              Text(
                '🍽️',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No specific dietary preferences',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected 
                            ? Theme.of(context).colorScheme.onSecondaryContainer
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'I eat a balanced, general diet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected 
                            ? Theme.of(context).colorScheme.onSecondaryContainer.withValues(alpha: 0.8)
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalizedPlanStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Personalized Health Plan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          if (_selectedConditions.isEmpty && _selectedDiets.isEmpty)
            _buildEmptyPlan()
          else ...[
            if (_selectedConditions.isNotEmpty) ...[
              _buildConditionRecommendations(),
              const SizedBox(height: 24),
            ],
            if (_selectedDiets.isNotEmpty) ...[
              _buildDietRecommendations(),
              const SizedBox(height: 24),
            ],
            _buildGeneralTips(),
          ],
        ],
      ),
    );
  }

  Widget _buildConditionCard(HealthCondition condition) {
    final isSelected = _selectedConditions.contains(condition);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedConditions.remove(condition);
            } else {
              // Remove 'none' if selecting a specific condition
              _selectedConditions.remove(HealthCondition.none);
              _selectedConditions.add(condition);
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary 
                    : Colors.grey[400],
              ),
              const SizedBox(width: 16),
              Icon(
                _getConditionIcon(condition),
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary 
                    : Colors.grey[600],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getConditionLabel(condition),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected 
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getConditionDescription(condition),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected 
                            ? Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8)
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDietCard(CulturalDiet diet) {
    final isSelected = _selectedDiets.contains(diet);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Theme.of(context).colorScheme.secondaryContainer : null,
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedDiets.remove(diet);
            } else {
              // Remove 'none' if selecting a specific diet
              _selectedDiets.remove(CulturalDiet.none);
              _selectedDiets.add(diet);
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected 
                    ? Theme.of(context).colorScheme.secondary 
                    : Colors.grey[400],
              ),
              const SizedBox(width: 16),
              Text(
                _getDietEmoji(diet),
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDietLabel(diet),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected 
                            ? Theme.of(context).colorScheme.onSecondaryContainer
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getDietDescription(diet),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected 
                            ? Theme.of(context).colorScheme.onSecondaryContainer.withValues(alpha: 0.8)
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPlan() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No plan generated yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Select your health conditions and dietary preferences to generate a personalized plan.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConditionRecommendations() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.health_and_safety, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Health Condition Management',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._selectedConditions.map((condition) => _buildConditionRecommendation(condition)),
          ],
        ),
      ),
    );
  }

  Widget _buildDietRecommendations() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant_menu, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Cultural Diet Guidance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._selectedDiets.map((diet) => _buildDietRecommendation(diet)),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralTips() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tips_and_updates, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'General Wellness Tips',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTipItem('💧', 'Stay hydrated', 'Aim for 8-10 glasses of water daily'),
            _buildTipItem('😴', 'Prioritize sleep', 'Target 7-9 hours of quality sleep'),
            _buildTipItem('🏃', 'Regular exercise', '150 minutes of moderate activity weekly'),
            _buildTipItem('🧘', 'Manage stress', 'Practice mindfulness or meditation daily'),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionRecommendation(HealthCondition condition) {
    final recommendations = _getConditionRecommendations(condition);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getConditionLabel(condition),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...recommendations.map((rec) => _buildRecommendationItem(rec)),
        ],
      ),
    );
  }

  Widget _buildDietRecommendation(CulturalDiet diet) {
    final recommendations = _getDietRecommendations(diet);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getDietLabel(diet),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...recommendations.map((rec) => _buildRecommendationItem(rec)),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String recommendation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(recommendation)),
        ],
      ),
    );
  }

  Widget _buildTipItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _savePreferences() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authState = context.read<app_auth.AppAuthState>();
      final currentProfile = authState.userProfile;
      
      if (currentProfile != null) {
        // Add "none" if no specific conditions/diets are selected
        final conditionsToSave = _selectedConditions.isEmpty 
            ? [HealthCondition.none] 
            : _selectedConditions.toList();
        final dietsToSave = _selectedDiets.isEmpty 
            ? [CulturalDiet.none] 
            : _selectedDiets.toList();
            
        final updatedProfile = currentProfile.copyWith(
          healthConditions: conditionsToSave,
          culturalDietPreferences: dietsToSave,
          updatedAt: DateTime.now(),
        );
        
        final success = await authState.updateUserProfile(updatedProfile);
        
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Health preferences saved successfully')),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authState.errorMessage ?? 'Failed to save preferences'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
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

  String _getConditionLabel(HealthCondition condition) {
    switch (condition) {
      case HealthCondition.adhd:
        return 'ADHD';
      case HealthCondition.anxiety:
        return 'Anxiety';
      case HealthCondition.depression:
        return 'Depression';
      case HealthCondition.diabetes:
        return 'Diabetes';
      case HealthCondition.hypertension:
        return 'Hypertension';
      case HealthCondition.sleepDisorders:
        return 'Sleep Disorders';
      case HealthCondition.none:
        return 'None';
      case HealthCondition.heartDisease:
        return 'Heart Disease';
      case HealthCondition.obesity:
        return 'Obesity';
    }
  }

  String _getConditionDescription(HealthCondition condition) {
    switch (condition) {
      case HealthCondition.adhd:
        return 'Attention Deficit Hyperactivity Disorder - focus and attention management';
      case HealthCondition.anxiety:
        return 'Anxiety disorders - stress and worry management';
      case HealthCondition.depression:
        return 'Depression - mood and mental health support';
      case HealthCondition.diabetes:
        return 'Blood sugar management and glucose monitoring';
      case HealthCondition.hypertension:
        return 'High blood pressure - cardiovascular health monitoring';
      case HealthCondition.sleepDisorders:
        return 'Sleep quality issues - insomnia, sleep apnea, etc.';
      case HealthCondition.none:
        return 'No specific health conditions';
      case HealthCondition.heartDisease:
        return 'Cardiovascular conditions - heart health monitoring';
      case HealthCondition.obesity:
        return 'Weight management and healthy lifestyle support';
    }
  }

  IconData _getConditionIcon(HealthCondition condition) {
    switch (condition) {
      case HealthCondition.adhd:
        return Icons.psychology;
      case HealthCondition.anxiety:
        return Icons.sentiment_very_dissatisfied;
      case HealthCondition.depression:
        return Icons.mood_bad;
      case HealthCondition.diabetes:
        return Icons.bloodtype;
      case HealthCondition.hypertension:
        return Icons.favorite;
      case HealthCondition.sleepDisorders:
        return Icons.bedtime;
      case HealthCondition.none:
        return Icons.check_circle;
      case HealthCondition.heartDisease:
        return Icons.monitor_heart;
      case HealthCondition.obesity:
        return Icons.fitness_center;
    }
  }

  String _getDietLabel(CulturalDiet diet) {
    switch (diet) {
      case CulturalDiet.mediterranean:
        return 'Mediterranean';
      case CulturalDiet.asian:
        return 'Asian';
      case CulturalDiet.african:
        return 'African';
      case CulturalDiet.latinAmerican:
        return 'Latin American';
      case CulturalDiet.middleEastern:
        return 'Middle Eastern';
      case CulturalDiet.vegetarian:
        return 'Vegetarian';
      case CulturalDiet.vegan:
        return 'Vegan';
      case CulturalDiet.keto:
        return 'Ketogenic';
      case CulturalDiet.paleo:
        return 'Paleo';
      case CulturalDiet.halal:
        return 'Halal';
      case CulturalDiet.kosher:
        return 'Kosher';
      case CulturalDiet.none:
        return 'None';
    }
  }

  String _getDietDescription(CulturalDiet diet) {
    switch (diet) {
      case CulturalDiet.mediterranean:
        return 'Rich in olive oil, fish, vegetables, and whole grains';
      case CulturalDiet.asian:
        return 'Rice, vegetables, lean proteins, and traditional seasonings';
      case CulturalDiet.african:
        return 'Traditional African ingredients and cooking methods';
      case CulturalDiet.latinAmerican:
        return 'Beans, rice, corn, tropical fruits, and traditional spices';
      case CulturalDiet.middleEastern:
        return 'Grains, legumes, vegetables, and traditional Middle Eastern flavors';
      case CulturalDiet.vegetarian:
        return 'Plant-based diet excluding meat and fish';
      case CulturalDiet.vegan:
        return 'Fully plant-based diet excluding all animal products';
      case CulturalDiet.keto:
        return 'High-fat, low-carbohydrate diet for weight management';
      case CulturalDiet.paleo:
        return 'Whole foods diet based on hunter-gatherer nutrition';
      case CulturalDiet.halal:
        return 'Islamic dietary guidelines and food preparation';
      case CulturalDiet.kosher:
        return 'Jewish dietary laws and food preparation standards';
      case CulturalDiet.none:
        return 'No specific dietary preferences';
    }
  }

  String _getDietEmoji(CulturalDiet diet) {
    switch (diet) {
      case CulturalDiet.mediterranean:
        return '🫒';
      case CulturalDiet.asian:
        return '🍜';
      case CulturalDiet.african:
        return '🌍';
      case CulturalDiet.latinAmerican:
        return '🌮';
      case CulturalDiet.middleEastern:
        return '🧆';
      case CulturalDiet.vegetarian:
        return '🥗';
      case CulturalDiet.vegan:
        return '🌱';
      case CulturalDiet.keto:
        return '🥑';
      case CulturalDiet.paleo:
        return '🥩';
      case CulturalDiet.halal:
        return '☪️';
      case CulturalDiet.kosher:
        return '✡️';
      case CulturalDiet.none:
        return '🍽️';
    }
  }

  List<String> _getConditionRecommendations(HealthCondition condition) {
    switch (condition) {
      case HealthCondition.adhd:
        return [
          'Maintain regular sleep schedule for better focus',
          'Break tasks into smaller, manageable chunks',
          'Use timers and reminders for medication and activities',
          'Track mood and attention patterns daily'
        ];
      case HealthCondition.anxiety:
        return [
          'Practice deep breathing exercises daily',
          'Monitor caffeine intake and stress triggers',
          'Maintain regular exercise routine',
          'Track anxiety levels and symptoms'
        ];
      case HealthCondition.depression:
        return [
          'Monitor mood changes and sleep patterns',
          'Maintain social connections and activities',
          'Focus on consistent daily routines',
          'Track physical activity and sunlight exposure'
        ];
      case HealthCondition.diabetes:
        return [
          'Monitor blood glucose levels regularly',
          'Track carbohydrate intake and portion sizes',
          'Maintain consistent meal timing',
          'Log physical activity and its effects on glucose'
        ];
      case HealthCondition.hypertension:
        return [
          'Monitor blood pressure regularly',
          'Limit sodium intake and processed foods',
          'Maintain healthy weight through diet and exercise',
          'Track stress levels and relaxation activities'
        ];
      case HealthCondition.sleepDisorders:
        return [
          'Maintain consistent sleep schedule',
          'Create optimal sleep environment (dark, cool, quiet)',
          'Limit screen time before bedtime',
          'Track sleep quality and duration daily'
        ];
      case HealthCondition.heartDisease:
        return [
          'Monitor heart rate during exercise',
          'Maintain heart-healthy diet low in saturated fats',
          'Track daily physical activity',
          'Monitor weight and blood pressure'
        ];
      case HealthCondition.obesity:
        return [
          'Track daily caloric intake and expenditure',
          'Focus on whole foods and portion control',
          'Gradually increase physical activity',
          'Monitor weight changes weekly'
        ];
      case HealthCondition.none:
        return [
          'Maintain current healthy lifestyle',
          'Continue regular health check-ups',
          'Focus on preventive care',
          'Stay active and eat balanced meals'
        ];
    }
  }

  List<String> _getDietRecommendations(CulturalDiet diet) {
    switch (diet) {
      case CulturalDiet.mediterranean:
        return [
          'Include olive oil as primary fat source',
          'Eat fish 2-3 times per week',
          'Focus on seasonal vegetables and fruits',
          'Choose whole grains over refined'
        ];
      case CulturalDiet.asian:
        return [
          'Use rice as a staple carbohydrate',
          'Include fermented foods for gut health',
          'Emphasize steaming and stir-frying',
          'Balance vegetables with lean proteins'
        ];
      case CulturalDiet.african:
        return [
          'Include nutrient-dense root vegetables',
          'Use traditional spices for flavor and health',
          'Focus on legumes for protein',
          'Include leafy greens in daily meals'
        ];
      case CulturalDiet.latinAmerican:
        return [
          'Combine beans and rice for complete proteins',
          'Include tropical fruits rich in vitamins',
          'Use fresh herbs and spices',
          'Balance corn-based dishes with vegetables'
        ];
      case CulturalDiet.middleEastern:
        return [
          'Include tahini and nuts for healthy fats',
          'Use herbs like parsley and mint',
          'Focus on legumes and whole grains',
          'Include yogurt for probiotics'
        ];
      case CulturalDiet.vegetarian:
        return [
          'Ensure adequate protein from legumes and nuts',
          'Include B12 supplements or fortified foods',
          'Focus on iron-rich plants with vitamin C',
          'Vary protein sources throughout the day'
        ];
      case CulturalDiet.vegan:
        return [
          'Plan for B12, iron, and omega-3 supplements',
          'Include variety of plant proteins daily',
          'Focus on whole foods over processed',
          'Ensure adequate calcium from plant sources'
        ];
      case CulturalDiet.keto:
        return [
          'Monitor ketone levels regularly',
          'Focus on healthy fats like avocados and nuts',
          'Track carbohydrate intake carefully',
          'Stay hydrated and monitor electrolytes'
        ];
      case CulturalDiet.paleo:
        return [
          'Focus on whole, unprocessed foods',
          'Include variety of vegetables and fruits',
          'Choose grass-fed and wild-caught proteins',
          'Avoid grains, legumes, and processed foods'
        ];
      case CulturalDiet.halal:
        return [
          'Ensure all meat is halal-certified',
          'Avoid alcohol in cooking and consumption',
          'Include dates and other traditional foods',
          'Focus on balanced nutrition within guidelines'
        ];
      case CulturalDiet.kosher:
        return [
          'Separate meat and dairy completely',
          'Choose kosher-certified products',
          'Follow traditional preparation methods',
          'Include traditional Jewish foods in moderation'
        ];
      case CulturalDiet.none:
        return [
          'Focus on balanced nutrition',
          'Include variety of foods from all groups',
          'Practice mindful eating',
          'Stay hydrated throughout the day'
        ];
    }
  }
}