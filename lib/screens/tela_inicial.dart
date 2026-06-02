import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/tarefa_provider.dart';
import '../widgets/card_tarefa.dart';
import 'tarefa_formulario.dart';

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TarefaProvider>(context);
    final tarefas = provider.tarefas;
    final todas = provider.todasTarefas;
    final concluidas = todas.where((t) => t.concluida).length;
    final total = todas.length;
    final progresso = total == 0 ? 0.0 : concluidas / total;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header / App Bar rico ──────────────────────────────────────
          SliverToBoxAdapter(
            child: _Header(
              progresso: progresso,
              concluidas: concluidas,
              total: total,
              cs: cs,
              provider: provider,
            ),
          ),

          // ── Chips de filtro ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _FilterChips(provider: provider, cs: cs),
          ),

          // ── Lista ou estado vazio ──────────────────────────────────────
          if (tarefas.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(cs: cs),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tarefa = tarefas[index];
                    return CardTarefa(
                      tarefa: tarefa,
                      onToggle: () => provider.alternarStatusTarefa(tarefa),
                      onEdit: () => Navigator.push(
                        context,
                        _fadeRoute(TarefaFormulario(tarefa: tarefa)),
                      ),
                      onDelete: () => provider.excluirTarefa(tarefa.id!),
                    );
                  },
                  childCount: tarefas.length,
                ),
              ),
            ),
        ],
      ),

      // ── FAB premium ───────────────────────────────────────────────────
      floatingActionButton: _PremiumFAB(cs: cs, context: context, provider: provider),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Header com gradiente e barra de progresso
// ──────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final double progresso;
  final int concluidas;
  final int total;
  final ColorScheme cs;
  final TarefaProvider provider;

  const _Header({
    required this.progresso,
    required this.concluidas,
    required this.total,
    required this.cs,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 24,
        right: 24,
        bottom: 28,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withOpacity(0.18),
            cs.surface.withOpacity(0.0),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Ícone app
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primary, cs.primary.withOpacity(0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'Tasks',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  letterSpacing: -0.8,
                ),
              ),
              const Spacer(),
              // Menu filtro
              _FilterMenu(provider: provider, cs: cs),
            ],
          ),

          const SizedBox(height: 28),

          // Cartão de progresso
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: cs.outline.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      total == 0 ? 'Nenhuma tarefa ainda' : '$concluidas de $total concluídas',
                      style: GoogleFonts.inter(
                        color: cs.onSurface.withOpacity(0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(progresso * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.inter(
                        color: cs.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progresso),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 8,
                        backgroundColor: cs.outline.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          value >= 1.0 ? const Color(0xFF4ADE80) : cs.primary,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Menu de filtro como ícone
// ──────────────────────────────────────────────────────────────────────────────
class _FilterMenu extends StatelessWidget {
  final TarefaProvider provider;
  final ColorScheme cs;
  const _FilterMenu({required this.provider, required this.cs});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<FiltroTarefa>(
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outline.withOpacity(0.5)),
        ),
        child: Icon(Icons.tune_rounded, color: cs.onSurface, size: 20),
      ),
      onSelected: provider.setFiltro,
      itemBuilder: (_) => [
        _buildItem(FiltroTarefa.todas, 'Todas as Tarefas', Icons.list_rounded, cs),
        _buildItem(FiltroTarefa.pendentes, 'Pendentes', Icons.radio_button_unchecked_rounded, cs),
        _buildItem(FiltroTarefa.concluidas, 'Concluídas', Icons.check_circle_rounded, cs),
      ],
    );
  }

  PopupMenuItem<FiltroTarefa> _buildItem(
      FiltroTarefa value, String label, IconData icon, ColorScheme cs) {
    final isSelected = provider.filtroAtual == value;
    return PopupMenuItem<FiltroTarefa>(
      value: value,
      child: Row(
        children: [
          Icon(icon,
              size: 18,
              color: isSelected ? cs.primary : cs.onSurface.withOpacity(0.5)),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? cs.primary : cs.onSurface,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            Icon(Icons.check_rounded, size: 16, color: cs.primary),
          ]
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Chips de filtro rápido (visível abaixo do header)
// ──────────────────────────────────────────────────────────────────────────────
class _FilterChips extends StatelessWidget {
  final TarefaProvider provider;
  final ColorScheme cs;
  const _FilterChips({required this.provider, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Row(
        children: [
          _Chip(
            label: 'Todas',
            selected: provider.filtroAtual == FiltroTarefa.todas,
            onTap: () => provider.setFiltro(FiltroTarefa.todas),
            cs: cs,
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Pendentes',
            selected: provider.filtroAtual == FiltroTarefa.pendentes,
            onTap: () => provider.setFiltro(FiltroTarefa.pendentes),
            cs: cs,
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Concluídas',
            selected: provider.filtroAtual == FiltroTarefa.concluidas,
            onTap: () => provider.setFiltro(FiltroTarefa.concluidas),
            cs: cs,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme cs;
  const _Chip(
      {required this.label,
      required this.selected,
      required this.onTap,
      required this.cs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? cs.primary : cs.outline.withOpacity(0.4),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: cs.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? Colors.white : cs.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Estado vazio premium
// ──────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final ColorScheme cs;
  const _EmptyState({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  cs.primary.withOpacity(0.2),
                  cs.primary.withOpacity(0.0),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              size: 56,
              color: cs.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tudo limpo por aqui!',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque em + para criar sua primeira tarefa.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: cs.onSurface.withOpacity(0.45),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// FAB premium com label
// ──────────────────────────────────────────────────────────────────────────────
class _PremiumFAB extends StatelessWidget {
  final ColorScheme cs;
  final BuildContext context;
  final TarefaProvider provider;

  const _PremiumFAB(
      {required this.cs, required this.context, required this.provider});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        _fadeRoute(const TarefaFormulario()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.primary, Color.lerp(cs.primary, const Color(0xFFB266FF), 0.5)!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withOpacity(0.45),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              'Nova Tarefa',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Transição suave entre telas
// ──────────────────────────────────────────────────────────────────────────────
PageRoute _fadeRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 250),
  );
}
