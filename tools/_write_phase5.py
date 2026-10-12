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
    "core/widgets/async_body.dart",
    """import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../l10n/app_localizations.dart';

class AsyncBody extends StatelessWidget {
  const AsyncBody({
    super.key,
    required this.loading,
    required this.error,
    required this.empty,
    required this.child,
    this.onRetry,
  });

  final bool loading;
  final String? error;
  final bool empty;
  final Widget child;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (loading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: ListView.builder(
          itemCount: 6,
          itemBuilder: (_, _) => const ListTile(
            title: SizedBox(height: 16),
            subtitle: SizedBox(height: 12),
          ),
        ),
      );
    }
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error!),
            if (onRetry != null) TextButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      );
    }
    if (empty) {
      return Center(child: Text(l10n.empty));
    }
    return child;
  }
}
""",
)

w(
    "core/widgets/json_title.dart",
    """import 'package:flutter/material.dart';
import '../utils/localized.dart';

class JsonTitle extends StatelessWidget {
  const JsonTitle(this.value, {super.key, this.style});
  final dynamic value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return Text(localized(value, locale), style: style);
  }
}
""",
)

w(
    "core/shells/customer_shell.dart",
    """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';

class CustomerShell extends StatelessWidget {
  const CustomerShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), label: l10n.home),
          NavigationDestination(icon: const Icon(Icons.event_outlined), label: l10n.myEvents),
          NavigationDestination(icon: const Icon(Icons.chat_bubble_outline), label: l10n.chat),
          NavigationDestination(icon: const Icon(Icons.favorite_outline), label: l10n.favorites),
          NavigationDestination(icon: const Icon(Icons.person_outline), label: l10n.profile),
        ],
      ),
    );
  }
}
""",
)

w(
    "core/shells/vendor_shell.dart",
    """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';

class VendorShell extends StatelessWidget {
  const VendorShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.dashboard_outlined), label: l10n.dashboard),
          NavigationDestination(icon: const Icon(Icons.storefront_outlined), label: l10n.listings),
          NavigationDestination(icon: const Icon(Icons.calendar_month_outlined), label: l10n.calendar),
          NavigationDestination(icon: const Icon(Icons.inbox_outlined), label: l10n.requests),
          NavigationDestination(icon: const Icon(Icons.chat_bubble_outline), label: l10n.chat),
          NavigationDestination(icon: const Icon(Icons.person_outline), label: l10n.profile),
        ],
      ),
    );
  }
}
""",
)

# generic catalog feature generator
CATALOGS = [
    ("venues", "venues", "/venues", True, "venues"),
    ("vendors_browse", "vendors", "/vendors", False, "vendors"),
    ("cars", "cars", "/cars", True, "cars"),
    ("accommodations", "accommodations", "/accommodations", True, "accommodations"),
    ("honeymoon", "honeymoon", "/honeymoon", True, "honeymoon"),
    ("flights", "flights", "/flights", True, "flights"),
    ("hotels", "hotels", "/hotels", True, "hotels"),
    ("events", "events", "/events", False, "myEvents"),
    ("bookings", "bookings", "/bookings", False, "bookings"),
    ("venue_visits", "visits", "/venue-visits", False, "venueVisits"),
    ("favorites", "favorites", "/favorites", False, "favorites"),
    ("notifications", "notifications", "/notifications", False, "notifications"),
]


def catalog_feature(folder: str, name: str, path: str, bookable: bool, title_key: str) -> None:
    entity = name[0].upper() + name[1:]
    w(
        f"features/{folder}/domain/entities/{name}_item.dart",
        f"""class {entity}Item {{
  const {entity}Item(this.raw);
  final Map<String, dynamic> raw;
  String get id => raw['id']?.toString() ?? '';
}}
""",
    )
    extra_methods_abs = ""
    extra_methods_impl = ""
    extra_usecases = ""
    # fix inquire path properly per feature
    inquire_path = {
        "venues": "/venues/{id}/inquire",
        "cars": "/cars/{id}/book",
        "accommodations": "/accommodations/{id}/book",
        "honeymoon": "/honeymoon/{id}/inquire",
        "flights": "/flights/{id}/book",
        "hotels": "/hotels/{id}/book",
    }.get(name)
    if inquire_path:
        extra_methods_abs = """
  Future<Either<Failure, Map<String, dynamic>>> inquire(String id, Map<String, dynamic> body);
"""
        extra_methods_impl = f"""
  @override
  Future<Either<Failure, Map<String, dynamic>>> inquire(String id, Map<String, dynamic> body) {{
    return _client.post('{inquire_path}'.replaceAll('{{id}}', id), data: body, parse: (data) => Map<String, dynamic>.from(data as Map));
  }}
"""
        extra_usecases = f"""
class Inquire{entity} {{
  Inquire{entity}(this._repository);
  final {entity}Repository _repository;
  Future<Either<Failure, Map<String, dynamic>>> call(String id, Map<String, dynamic> body) =>
      _repository.inquire(id, body);
}}
"""

    w(
        f"features/{folder}/domain/repositories/{name}_repository.dart",
        f"""import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paginated.dart';
import '../entities/{name}_item.dart';

abstract class {entity}Repository {{
  Future<Either<Failure, Paginated<{entity}Item>>> list({{int page = 1, Map<String, dynamic>? query}});
  Future<Either<Failure, {entity}Item>> getById(String id);
{extra_methods_abs}
}}
""",
    )

    w(
        f"features/{folder}/data/datasources/{name}_remote_ds.dart",
        f"""import '../../../../core/network/api_client.dart';
import '../../../../core/pagination/paginated.dart';

class {entity}RemoteDataSource {{
  {entity}RemoteDataSource(this._client);
  final ApiClient _client;
}}
""",
    )
    w(
        f"features/{folder}/data/repositories/{name}_repository_impl.dart",
        f"""import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/pagination/paginated.dart';
import '../../domain/entities/{name}_item.dart';
import '../../domain/repositories/{name}_repository.dart';

class {entity}RepositoryImpl implements {entity}Repository {{
  {entity}RepositoryImpl(this._client);
  final ApiClient _client;

  Paginated<{entity}Item> _page(dynamic data) {{
    final map = Map<String, dynamic>.from(data as Map);
    final items = (map['items'] as List? ?? [])
        .map((e) => {entity}Item(Map<String, dynamic>.from(e as Map)))
        .toList();
    return Paginated(
      items: items,
      total: (map['total'] as num?)?.toInt() ?? items.length,
      page: (map['page'] as num?)?.toInt() ?? 1,
      pageSize: (map['pageSize'] as num?)?.toInt() ?? 20,
    );
  }}

  @override
  Future<Either<Failure, Paginated<{entity}Item>>> list({{int page = 1, Map<String, dynamic>? query}}) {{
    return _client.get('{path}', query: {{'page': page, ...?query}}, parse: _page);
  }}

  @override
  Future<Either<Failure, {entity}Item>> getById(String id) {{
    return _client.get('{path}/$id', parse: (data) => {entity}Item(Map<String, dynamic>.from(data as Map)));
  }}
{extra_methods_impl}
}}
""",
    )
    w(
        f"features/{folder}/domain/usecases/{name}_usecases.dart",
        f"""import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paginated.dart';
import '../entities/{name}_item.dart';
import '../repositories/{name}_repository.dart';

class List{entity} {{
  List{entity}(this._repository);
  final {entity}Repository _repository;
  Future<Either<Failure, Paginated<{entity}Item>>> call({{int page = 1, Map<String, dynamic>? query}}) =>
      _repository.list(page: page, query: query);
}}

class Get{entity} {{
  Get{entity}(this._repository);
  final {entity}Repository _repository;
  Future<Either<Failure, {entity}Item>> call(String id) => _repository.getById(id);
}}
{extra_usecases}
""",
    )
    w(
        f"features/{folder}/presentation/cubit/{name}_state.dart",
        f"""import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/{name}_item.dart';

part '{name}_state.freezed.dart';

@freezed
class {entity}State with _${entity}State {{
  const factory {entity}State({{
    @Default(false) bool loading,
    String? error,
    @Default(<{entity}Item>[]) List<{entity}Item> items,
    {entity}Item? detail,
  }}) = _{entity}State;
}}
""",
    )
    w(
        f"features/{folder}/presentation/cubit/{name}_cubit.dart",
        f"""import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/{name}_usecases.dart';
import '{name}_state.dart';

class {entity}Cubit extends Cubit<{entity}State> {{
  {entity}Cubit(this._list, this._get) : super(const {entity}State());

  final List{entity} _list;
  final Get{entity} _get;

  Future<void> load({{Map<String, dynamic>? query}}) async {{
    emit(state.copyWith(loading: true, error: null));
    final result = await _list(query: query);
    result.fold(
      (f) => emit(state.copyWith(loading: false, error: f.message)),
      (page) => emit(state.copyWith(loading: false, items: page.items)),
    );
  }}

  Future<void> loadOne(String id) async {{
    emit(state.copyWith(loading: true, error: null));
    final result = await _get(id);
    result.fold(
      (f) => emit(state.copyWith(loading: false, error: f.message)),
      (item) => emit(state.copyWith(loading: false, detail: item)),
    );
  }}
}}
""",
    )
    extra_action = ""
    if inquire_path:
        extra_action = """
            FilledButton(
              onPressed: () => context.push('${'/%s' % folder}/$id/book'),
              child: Text(l10n.bookNow),
            ),"""
    w(
        f"features/{folder}/presentation/pages/{name}_list_page.dart",
        f"""import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/json_title.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/{name}_cubit.dart';
import '../cubit/{name}_state.dart';

class {entity}ListPage extends StatelessWidget {{
  const {entity}ListPage({{super.key, this.embedded = false}});
  final bool embedded;

  @override
  Widget build(BuildContext context) {{
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<{entity}Cubit>()..load(),
      child: Scaffold(
        appBar: embedded ? null : AppBar(title: Text(l10n.{title_key})),
        body: BlocBuilder<{entity}Cubit, {entity}State>(
          builder: (context, state) {{
            return AsyncBody(
              loading: state.loading,
              error: state.error,
              empty: state.items.isEmpty,
              onRetry: () => context.read<{entity}Cubit>().load(),
              child: ListView.separated(
                itemCount: state.items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {{
                  final item = state.items[index];
                  final title = item.raw['title'] ?? item.raw['name'] ?? item.raw['businessName'] ?? item.id;
                  return ListTile(
                    title: JsonTitle(title),
                    subtitle: Text(item.raw['city']?.toString() ?? item.raw['status']?.toString() ?? ''),
                    onTap: () => context.push('/{folder}/${{item.id}}'),
                  );
                }},
              ),
            );
          }},
        ),
      ),
    );
  }}
}}
""",
    )
    w(
        f"features/{folder}/presentation/pages/{name}_detail_page.dart",
        f"""import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/json_title.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/{name}_cubit.dart';
import '../cubit/{name}_state.dart';

class {entity}DetailPage extends StatelessWidget {{
  const {entity}DetailPage({{super.key, required this.id}});
  final String id;

  @override
  Widget build(BuildContext context) {{
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<{entity}Cubit>()..loadOne(id),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.{title_key})),
        body: BlocBuilder<{entity}Cubit, {entity}State>(
          builder: (context, state) {{
            final item = state.detail;
            return AsyncBody(
              loading: state.loading,
              error: state.error,
              empty: item == null,
              onRetry: () => context.read<{entity}Cubit>().loadOne(id),
              child: item == null
                  ? const SizedBox.shrink()
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        JsonTitle(item.raw['title'] ?? item.raw['name'] ?? item.raw['businessName'], style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 12),
                        Text(item.raw['city']?.toString() ?? ''),
                        const SizedBox(height: 12),
                        JsonTitle(item.raw['description']),
                      ],
                    ),
            );
          }},
        ),
      ),
    );
  }}
}}
""",
    )


for folder, name, path, bookable, title in CATALOGS:
    catalog_feature(folder, name, path, bookable, title)

print("catalogs done")
