import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paginated.dart';
import '../entities/notifications_item.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, Paginated<NotificationsItem>>> list({int page = 1, Map<String, dynamic>? query});
  Future<Either<Failure, NotificationsItem>> getById(String id);

}
