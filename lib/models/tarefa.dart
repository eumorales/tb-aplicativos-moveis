class Tarefa {
  final int? id;
  final String titulo;
  final String? descricao;
  final bool concluida;
  final String dataCriacao;

  Tarefa({
    this.id,
    required this.titulo,
    this.descricao,
    this.concluida = false,
    required this.dataCriacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'concluida': concluida ? 1 : 0,
      'dataCriacao': dataCriacao,
    };
  }

  factory Tarefa.fromMap(Map<String, dynamic> map) {
    return Tarefa(
      id: map['id'],
      titulo: map['titulo'],
      descricao: map['descricao'],
      concluida: map['concluida'] == 1,
      dataCriacao: map['dataCriacao'],
    );
  }

  Tarefa copyWith({
    int? id,
    String? titulo,
    String? descricao,
    bool? concluida,
    String? dataCriacao,
  }) {
    return Tarefa(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      concluida: concluida ?? this.concluida,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }
}
