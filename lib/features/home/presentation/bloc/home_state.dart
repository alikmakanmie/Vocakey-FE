import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeError extends HomeState {
  final String message;
  
  const HomeError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// ✅ FIXED: Hapus const karena parent tidak const
class HomeAnalysisLoaded extends HomeState {
  final String note;
  final String vocalRange;
  final double accuracy;
  final String? vocalType;
  
  const HomeAnalysisLoaded({  // ✅ Tetap const tapi parent harus const juga
    required this.note,
    required this.vocalRange,
    required this.accuracy,
    this.vocalType,
  });
  
  @override
  List<Object?> get props => [note, vocalRange, accuracy, vocalType];
}
