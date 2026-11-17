import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paginated.dart';
import '../entities/notifications_item.dart';
import '../repositories/notifications_repository.dart';

class ListNotifications {
  ListNotifications(this._repository);
  final NotificationsRepository _repository;
  Future<Either<Failure, Paginated<NotificationsItem>>> call({int page = 1, Map<String, dynamic>? query}) =>
      _repository.list(page: page, query: query);
}

class GetNotifications {
  GetNotifications(this._repository);
  final NotificationsRepository _repository;
  Future<Either<Failure, NotificationsItem>> call(String id) => _repository.getById(id);
}

class MarkNotificationRead {
  MarkNotificationRead(this._repository);
  final NotificationsRepository _repository;
  Future<Either<Failure, bool>> call(String id) => _repository.markRead(id);
}

class MarkAllNotificationsRead {
  MarkAllNotificationsRead(this._repository);
  final NotificationsRepository _repository;
  Future<Either<Failure, bool>> call() => _repository.markAllRead();
}

