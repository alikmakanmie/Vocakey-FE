import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/home_repository.dart';

class GetRecentNote {
  final HomeRepository repository;

  GetRecentNote(this.repository);

  Future<Either<Failure, String?>> call() async {
    return await repository.getRecentNote();
  }
}
