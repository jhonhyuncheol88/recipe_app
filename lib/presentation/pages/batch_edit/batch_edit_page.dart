import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/batch_update_ingredients_usecase.dart';
import '../../../data/repositories/ingredient_repository_impl.dart';
import '../../../data/database_helper.dart';
import '../../bloc/batch_edit/batch_edit_bloc.dart';
import '../../bloc/batch_edit/batch_edit_event.dart';
import '../../bloc/batch_edit/batch_edit_state.dart';
import 'widgets/ingredient_edit_item.dart';

class BatchEditPage extends StatelessWidget {
  const BatchEditPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BatchEditBloc(
        repository: IngredientRepositoryImpl(DatabaseHelper()),
        batchUpdateUseCase: BatchUpdateIngredientsUseCase(
          IngredientRepositoryImpl(DatabaseHelper()),
        ),
      )..add(LoadIngredientsEvent()),
      child: const BatchEditView(),
    );
  }
}

class BatchEditView extends StatelessWidget {
  const BatchEditView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('재료 일괄 수정'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          BlocBuilder<BatchEditBloc, BatchEditState>(
            builder: (context, state) {
              return TextButton(
                onPressed:
                    state.hasChanges && state.status != BatchEditStatus.saving
                        ? () => context
                            .read<BatchEditBloc>()
                            .add(SaveBatchChangesEvent())
                        : null,
                child: Text(
                  '저장',
                  style: TextStyle(
                    color: state.hasChanges
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<BatchEditBloc, BatchEditState>(
        listener: (context, state) {
          if (state.status == BatchEditStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('저장되었습니다.')),
            );
            Navigator.pop(context);
          } else if (state.status == BatchEditStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('오류 발생: ${state.errorMessage}')),
            );
          }
        },
        builder: (context, state) {
          if (state.status == BatchEditStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.ingredients.isEmpty) {
            final colorScheme = Theme.of(context).colorScheme;
            return Center(
              child: Text(
                '수정할 재료가 없습니다.',
                style: TextStyle(color: colorScheme.onSurface),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: state.ingredients.length,
            itemBuilder: (context, index) {
              final ingredient = state.ingredients[index];
              return IngredientEditItem(
                ingredient: ingredient,
                editedIngredient: state.editedIngredients[ingredient.id],
                isMarkedForDeletion: state.idsToDelete.contains(ingredient.id),
                onChanged: (name, price, amount, unitId, expiryDate, tagIds) {
                  context.read<BatchEditBloc>().add(
                        UpdateIngredientFieldEvent(
                          ingredientId: ingredient.id,
                          name: name,
                          purchasePrice: price,
                          purchaseAmount: amount,
                          purchaseUnitId: unitId,
                          expiryDate: expiryDate,
                          tagIds: tagIds,
                        ),
                      );
                },
                onToggleDelete: () {
                  context
                      .read<BatchEditBloc>()
                      .add(ToggleDeleteIngredientEvent(ingredient.id));
                },
              );
            },
          );
        },
      ),
    );
  }
}
