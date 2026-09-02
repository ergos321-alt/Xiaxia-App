/// Sensor or service evidence. It contains no inferred emotion or intention.
class RealityFact<T> {
  const RealityFact({
    required this.kind,
    required this.value,
    required this.observedAt,
    required this.source,
  });

  final String kind;
  final T value;
  final DateTime observedAt;
  final String source;
}

/// Core-produced interpretation stays separate from the underlying fact.
class XiaxiaInterpretation {
  const XiaxiaInterpretation({
    required this.text,
    required this.createdAt,
    required this.factReferences,
  });

  final String text;
  final DateTime createdAt;
  final List<String> factReferences;
}
