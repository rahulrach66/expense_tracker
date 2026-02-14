import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/enums/filter_type.dart';

final filterProvider = StateProvider<FilterType>((ref) {
  return FilterType.all;
});
