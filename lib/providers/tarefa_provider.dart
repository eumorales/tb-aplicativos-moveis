import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tarefa.dart';

enum FiltroTarefa { todas, pendentes, concluidas }

class TarefaProvider extends ChangeNotifier {
  List<Tarefa> _tarefas = [];
  FiltroTarefa _filtroAtual = FiltroTarefa.todas;

  List<Tarefa> get tarefas {
    switch (_filtroAtual) {
      case FiltroTarefa.pendentes:
        return _tarefas.where((t) => !t.concluida).toList();
      case FiltroTarefa.concluidas:
        return _tarefas.where((t) => t.concluida).toList();
      case FiltroTarefa.todas:
      default:
        return _tarefas;
    }
  }

  List<Tarefa> get todasTarefas => _tarefas;

  FiltroTarefa get filtroAtual => _filtroAtual;

  Future<void> carregarTarefas() async {
    final prefs = await SharedPreferences.getInstance();
    final tarefasString = prefs.getString('tarefas_lista');
    if (tarefasString != null) {
      final List<dynamic> jsonList = jsonDecode(tarefasString);
      _tarefas = jsonList.map((json) => Tarefa.fromMap(json)).toList();
    }
    notifyListeners();
  }

  Future<void> _salvarTarefasLocais() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(_tarefas.map((t) => t.toMap()).toList());
    await prefs.setString('tarefas_lista', jsonString);
  }

  void setFiltro(FiltroTarefa filtro) {
    _filtroAtual = filtro;
    notifyListeners();
  }

  Future<void> adicionarTarefa(Tarefa tarefa) async {
    final novaTarefa = tarefa.copyWith(id: DateTime.now().millisecondsSinceEpoch);
    _tarefas.insert(0, novaTarefa);
    await _salvarTarefasLocais();
    notifyListeners();
  }

  Future<void> atualizarTarefa(Tarefa tarefa) async {
    final index = _tarefas.indexWhere((t) => t.id == tarefa.id);
    if (index != -1) {
      _tarefas[index] = tarefa;
      await _salvarTarefasLocais();
      notifyListeners();
    }
  }

  Future<void> alternarStatusTarefa(Tarefa tarefa) async {
    final tarefaAtualizada = tarefa.copyWith(concluida: !tarefa.concluida);
    await atualizarTarefa(tarefaAtualizada);
  }

  Future<void> excluirTarefa(int id) async {
    _tarefas.removeWhere((t) => t.id == id);
    await _salvarTarefasLocais();
    notifyListeners();
  }
}
