#!/usr/bin/env python3
import os

root = "/Volumes/Projects/freelancerprojects/panagiotis/zaya_events/lib"


def w(rel: str, content: str) -> None:
    path = os.path.join(root, rel)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as handle:
        handle.write(content)
    print(rel)


w(
    "features/uploads/domain/entities/upload_result.dart",
    """class UploadResult {
  const UploadResult({required this.key, required this.url});
  final String key;
  final String url;
}
""",
)

w(
    "features/uploads/domain/repositories/upload_repository.dart",
    """import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/upload_result.dart';

abstract class UploadRepository {
  Future<Either<Failure, UploadResult>> upload({
    required String filePath,
    required String filename,
    String folder,
  });
}
""",
)

w(
    "features/uploads/domain/usecases/upload_file.dart",
    """import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/upload_result.dart';
import '../repositories/upload_repository.dart';

class UploadFile {
  UploadFile(this._repository);
  final UploadRepository _repository;

  Future<Either<Failure, UploadResult>> call({
    required String filePath,
    required String filename,
    String folder = 'uploads',
  }) {
    return _repository.upload(filePath: filePath, filename: filename, folder: folder);
  }
}
""",
)

w(
    "features/uploads/data/repositories/upload_repository_impl.dart",
    """import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/upload_result.dart';
import '../../domain/repositories/upload_repository.dart';

class UploadRepositoryImpl implements UploadRepository {
  UploadRepositoryImpl(this._client);
  final ApiClient _client;

  @override
  Future<Either<Failure, UploadResult>> upload({
    required String filePath,
    required String filename,
    String folder = 'uploads',
  }) async {
    final form = FormData.fromMap({
      'folder': folder,
      'file': await MultipartFile.fromFile(filePath, filename: filename),
    });
    return _client.upload(
      '/uploads',
      data: form,
      parse: (data) {
        final map = Map<String, dynamic>.from(data as Map);
        return UploadResult(
          key: map['key']?.toString() ?? '',
          url: map['url']?.toString() ?? '',
        );
      },
    );
  }
}
""",
)

w(
    "features/uploads/presentation/upload_service.dart",
    """import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';
import '../domain/entities/upload_result.dart';
import '../domain/usecases/upload_file.dart';

/// Single entry-point for mobile uploads. Always POST /api/v1/uploads.
class UploadService {
  UploadService(this._uploadFile);
  final UploadFile _uploadFile;

  Future<Either<Failure, UploadResult>> upload({
    required String filePath,
    required String filename,
    String folder = 'uploads',
  }) {
    return _uploadFile(filePath: filePath, filename: filename, folder: folder);
  }
}
""",
)

w(
    "features/notifications/domain/usecases/register_device.dart",
    """import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';

class RegisterDevice {
  RegisterDevice(this._client);
  final ApiClient _client;

  Future<Either<Failure, Unit>> call(String token) {
    return _client.post(
      '/notifications/devices',
      data: {
        'token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
      },
      parse: (_) => unit,
    );
  }
}
""",
)

print("uploads ok")
