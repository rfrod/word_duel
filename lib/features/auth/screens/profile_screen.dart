import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/revenue_cat_manager.dart';
import '../notifiers/auth_notifier.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    final player = ref.read(currentPlayerProvider);
    _usernameController = TextEditingController(text: player?.username ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final player = authState.player;
    final isPro = RevenueCatManager.instance.isPro;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: player == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Avatar
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                          child: Text(
                            player.username.isNotEmpty
                                ? player.username[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        if (isPro)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Username
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome de usuário',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: authState.isLoading
                        ? null
                        : () => ref
                            .read(authNotifierProvider.notifier)
                            .updateUsername(_usernameController.text.trim()),
                    child: const Text('Salvar'),
                  ),
                  const SizedBox(height: 24),

                  // Idioma
                  const Text(
                    'Idioma do jogo',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _LocaleSelector(
                    currentLocale: player.locale,
                    onLocaleChanged: (locale) => ref
                        .read(authNotifierProvider.notifier)
                        .updateLocale(locale),
                    isPro: isPro,
                  ),
                  const SizedBox(height: 32),

                  // Assinatura
                  const Divider(),
                  const SizedBox(height: 16),
                  if (!isPro) ...[
                    const Text(
                      'Upgrade para Pro',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const _ProFeatureList(),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.black87,
                      ),
                      onPressed: () => RevenueCatManager.instance.purchaseMonthly(),
                      child: const Text('Plano Mensal — R\$ 12,90/mês'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => RevenueCatManager.instance.purchaseYearly(),
                      child: const Text('Plano Anual — R\$ 89,90/ano'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => RevenueCatManager.instance.restorePurchases(),
                      child: const Text('Restaurar compras'),
                    ),
                  ] else
                    const _ProBadge(),

                  const Divider(),
                  const SizedBox(height: 16),

                  // Sair
                  TextButton.icon(
                    onPressed: () async {
                      await ref.read(authNotifierProvider.notifier).signOut();
                      if (context.mounted) context.go('/login');
                    },
                    icon: const Icon(Icons.logout, color: AppColors.error),
                    label: const Text(
                      'Sair',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _LocaleSelector extends StatelessWidget {
  const _LocaleSelector({
    required this.currentLocale,
    required this.onLocaleChanged,
    required this.isPro,
  });

  final String currentLocale;
  final ValueChanged<String> onLocaleChanged;
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    const locales = [
      ('pt', 'Português 🇧🇷'),
      ('en', 'English 🇺🇸'),
      ('es', 'Español 🇪🇸'),
    ];

    return Wrap(
      spacing: 8,
      children: locales.map((l) {
        final locked = !isPro && l.$1 != 'pt';
        return ChoiceChip(
          label: Text(l.$2),
          selected: currentLocale == l.$1,
          onSelected: locked ? null : (_) => onLocaleChanged(l.$1),
          avatar: locked ? const Icon(Icons.lock, size: 14) : null,
          selectedColor: AppColors.primary.withOpacity(0.3),
        );
      }).toList(),
    );
  }
}

class _ProFeatureList extends StatelessWidget {
  const _ProFeatureList();

  @override
  Widget build(BuildContext context) {
    const features = [
      'Sem anúncios',
      'Todos os idiomas',
      'Ranking global',
      'Temas extras',
    ];

    return Column(
      children: features
          .map(
            (f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.success, size: 16),
                  const SizedBox(width: 8),
                  Text(f, style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ProBadge extends StatelessWidget {
  const _ProBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.star, color: AppColors.accent),
          SizedBox(width: 8),
          Text(
            'Você já é Pro!',
            style: TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
