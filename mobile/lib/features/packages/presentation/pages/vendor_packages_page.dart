import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/json_title.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../listings/presentation/cubit/listings_cubit.dart';

class VendorPackagesPage extends StatelessWidget {
  const VendorPackagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<ListingsCubit>()..load(),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.packages)),
        body: BlocBuilder<ListingsCubit, ListingsState>(
          builder: (context, state) {
            final packages = state.items.expand((listing) {
              final pkgs = (listing['packages'] as List?) ?? const [];
              return pkgs.map((p) => Map<String, dynamic>.from(p as Map)..['listingTitle'] = listing['title']);
            }).toList();
            if (packages.isEmpty) {
              return Center(child: Text(l10n.empty));
            }
            return ListView(
              children: packages
                  .map(
                    (p) => ListTile(
                      title: JsonTitle(p['name']),
                      subtitle: JsonTitle(p['listingTitle']),
                      trailing: Text('${p['priceAmount'] ?? ''} ${p['currency'] ?? ''}'),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}
