import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/injection.dart';
import '../../core/theme/app_theme.dart';
import 'cart_cubit.dart';

class CartIconButton extends StatelessWidget {
  const CartIconButton({super.key, this.light = true});

  final bool light;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<CartCubit>()..ensureLoaded(),
      child: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          final color = light ? Colors.white : AppTheme.navy;
          return IconButton(
            tooltip: 'Cart',
            onPressed: () => context.push('/customer/cart'),
            icon: Badge(
              isLabelVisible: state.count > 0,
              backgroundColor: AppTheme.yellow,
              textColor: const Color(0xFF1A1A1A),
              label: Text('${state.count}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10)),
              child: Icon(Icons.shopping_bag_outlined, color: color),
            ),
          );
        },
      ),
    );
  }
}
