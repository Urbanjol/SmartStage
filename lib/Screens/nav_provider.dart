import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// Tracks the current active tab index globally
//stateProvider imports ???
final navigationIndexProvider = StateProvider<int>((ref)=> 0);