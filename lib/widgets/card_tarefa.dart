import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tarefa.dart';

class CardTarefa extends StatefulWidget {
  final Tarefa tarefa;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CardTarefa({
    super.key,
    required this.tarefa,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<CardTarefa> createState() => _CardTarefaState();
}

class _CardTarefaState extends State<CardTarefa>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkCtrl;
  late Animation<double> _checkScale;
  bool _pressing = false;

  @override
  void initState() {
    super.initState();
    _checkCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _checkScale = Tween<double>(begin: 1, end: 0.85)
        .animate(CurvedAnimation(parent: _checkCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    super.dispose();
  }

  void _handleToggle() {
    HapticFeedback.lightImpact();
    _checkCtrl.forward().then((_) => _checkCtrl.reverse());
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final concluida = widget.tarefa.concluida;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressing = true),
        onTapUp: (_) => setState(() => _pressing = false),
        onTapCancel: () => setState(() => _pressing = false),
        onTap: widget.onEdit,
        child: AnimatedScale(
          scale: _pressing ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: concluida
                  ? cs.surface.withOpacity(0.7)
                  : cs.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: concluida
                    ? const Color(0xFF4ADE80).withOpacity(0.25)
                    : cs.outline.withOpacity(0.35),
              ),
              boxShadow: concluida
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Toggle check ──────────────────────────────────────
                  GestureDetector(
                    onTap: _handleToggle,
                    behavior: HitTestBehavior.opaque,
                    child: ScaleTransition(
                      scale: _checkScale,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: concluida
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF4ADE80),
                                    Color(0xFF22D3EE),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          border: concluida
                              ? null
                              : Border.all(
                                  color: cs.outline,
                                  width: 2,
                                ),
                          boxShadow: concluida
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF4ADE80).withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        child: concluida
                            ? const Icon(Icons.check_rounded,
                                size: 15, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // ── Conteúdo ──────────────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: concluida
                                ? cs.onSurface.withOpacity(0.35)
                                : cs.onSurface,
                            decoration: concluida
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: cs.onSurface.withOpacity(0.35),
                          ),
                          child: Text(widget.tarefa.titulo),
                        ),
                        if (widget.tarefa.descricao != null &&
                            widget.tarefa.descricao!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              widget.tarefa.descricao!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: concluida
                                    ? cs.onSurface.withOpacity(0.2)
                                    : cs.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // ── Botão deletar ─────────────────────────────────────
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      widget.onDelete();
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          size: 18, color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
