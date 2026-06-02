import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/tarefa.dart';
import '../providers/tarefa_provider.dart';

class TarefaFormulario extends StatefulWidget {
  final Tarefa? tarefa;

  const TarefaFormulario({super.key, this.tarefa});

  @override
  State<TarefaFormulario> createState() => _TarefaFormularioState();
}

class _TarefaFormularioState extends State<TarefaFormulario>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloController;
  late TextEditingController _descricaoController;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _tituloController =
        TextEditingController(text: widget.tarefa?.titulo ?? '');
    _descricaoController =
        TextEditingController(text: widget.tarefa?.descricao ?? '');

    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<TarefaProvider>(context, listen: false);

      if (widget.tarefa == null) {
        final novaTarefa = Tarefa(
          titulo: _tituloController.text.trim(),
          descricao: _descricaoController.text.trim(),
          dataCriacao:
              DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        );
        provider.adicionarTarefa(novaTarefa);
      } else {
        final tarefaAtualizada = widget.tarefa!.copyWith(
          titulo: _tituloController.text.trim(),
          descricao: _descricaoController.text.trim(),
        );
        provider.atualizarTarefa(tarefaAtualizada);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.tarefa != null;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: _BackButton(cs: cs),
        title: Text(
          isEditing ? 'Editar Tarefa' : 'Nova Tarefa',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Seção título ───────────────────────────────────────
                  _SectionLabel(label: 'Título', cs: cs),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _tituloController,
                    autofocus: !isEditing,
                    textCapitalization: TextCapitalization.sentences,
                    style: GoogleFonts.inter(
                        color: cs.onSurface, fontWeight: FontWeight.w500),
                    decoration: const InputDecoration(
                      hintText: 'Exemplo task',
                      hintStyle: TextStyle(color: Color(0xFF5A5A7A)),
                      prefixIcon:
                          Icon(Icons.title_rounded, color: Color(0xFF5A5A7A)),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'O título é obrigatório';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // ── Seção descrição ────────────────────────────────────
                  _SectionLabel(label: 'Descrição', cs: cs),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descricaoController,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    style: GoogleFonts.inter(
                        color: cs.onSurface.withOpacity(0.9)),
                    decoration: const InputDecoration(
                      hintText: 'Adicione detalhes sobre a tarefa... (opcional)',
                      hintStyle: TextStyle(color: Color(0xFF5A5A7A)),
                      alignLabelWithHint: true,
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 72),
                        child: Icon(Icons.notes_rounded,
                            color: Color(0xFF5A5A7A)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Botões ─────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _SaveButton(onPressed: _salvar, cs: cs),
                      ),
                    ],
                  ),

                  // ── Botão deletar (apenas ao editar) ──────────────────
                  if (isEditing) ...[
                    const SizedBox(height: 16),
                    _DeleteButton(tarefa: widget.tarefa!, cs: cs),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Componentes auxiliares do formulário
// ──────────────────────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  final ColorScheme cs;
  const _BackButton({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outline.withOpacity(0.4)),
          ),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              size: 16, color: cs.onSurface),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final ColorScheme cs;
  const _SectionLabel({required this.label, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        color: cs.onSurface.withOpacity(0.55),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  final ColorScheme cs;
  const _SaveButton({required this.onPressed, required this.cs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.primary,
              Color.lerp(cs.primary, const Color(0xFFB266FF), 0.5)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Salvar',
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

class _DeleteButton extends StatelessWidget {
  final Tarefa tarefa;
  final ColorScheme cs;
  const _DeleteButton({required this.tarefa, required this.cs});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E2D),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Excluir tarefa?',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
            content: Text(
              'Esta ação não pode ser desfeita.',
              style: GoogleFonts.inter(
                  color: cs.onSurface.withOpacity(0.6)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Excluir',
                    style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        );
        if (confirm == true && context.mounted) {
          Provider.of<TarefaProvider>(context, listen: false)
              .excluirTarefa(tarefa.id!);
          Navigator.pop(context);
        }
      },
      icon: const Icon(Icons.delete_outline_rounded,
          size: 18, color: Colors.redAccent),
      label: Text(
        'Excluir tarefa',
        style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 14),
      ),
    );
  }
}
