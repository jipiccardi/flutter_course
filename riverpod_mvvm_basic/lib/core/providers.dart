import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/fake_notes_repository.dart';
import '../domain/notes_repository.dart';

final notesRepositoryProvider = Provider<NotesRepository>(
  (ref) => FakeNotesRepository(),
);
