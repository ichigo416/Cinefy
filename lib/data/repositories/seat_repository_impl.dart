import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/seat.dart';
import '../../domain/repositories/seat_repository.dart';
import '../datasources/remote/seat_remote_datasource.dart';

class SeatRepositoryImpl implements SeatRepository {
  final SeatRemoteDatasource _remote;

  SeatRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, SeatLayout>> getSeatLayout(String showId) async {
    try {
      final layout = await _remote.fetchSeatLayout(showId);
      return Right(layout);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }
}