import 'package:flutter_bloc/flutter_bloc.dart';

abstract interface class DependentEditorState {
  bool get isSaving;

  bool get canSave;

  bool get isSaved;
}

abstract interface class DependentEditorCubit<S extends DependentEditorState>
    implements StateStreamable<S> {
  Future<void> save();
}
