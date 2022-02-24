class Pair<T, S> {
  Pair(this.first, this.second);

  final T first;
  final S second;

  @override
  String toString() => 'Pair[$first, $second]';
}
