import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadHomeDataEvent extends HomeEvent {}

class NavigateToPitchEvent extends HomeEvent {}

class SaveRecentNoteEvent extends HomeEvent {
  final String note;

  SaveRecentNoteEvent(this.note);

  @override
  List<Object?> get props => [note];
}

class LoadLastAnalysisEvent extends HomeEvent {}
