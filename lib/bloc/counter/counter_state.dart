import 'package:equatable/equatable.dart';
import 'package:fastic_counter/models/daily_goal.dart';

abstract class CounterState extends Equatable {

  const CounterState();

  @override
  List<Object> get props => [];

}

class InitialCounterState extends CounterState {}

class LoadedCounterState extends CounterState {
  final int stepsToday;
  final DailyGoal dailyGoal;

  LoadedCounterState({this.stepsToday, this.dailyGoal});

  LoadedCounterState copyWith({
    int stepsToday,
    DailyGoal dailyGoal,
  }) {
    return LoadedCounterState(
      stepsToday: stepsToday ?? this.stepsToday,
      dailyGoal: dailyGoal ?? this.dailyGoal,
    );
  }

  @override
  List<Object> get props => [stepsToday, dailyGoal];

  @override
  String toString() =>
      'LoadedCounterState { stepsToday: ${stepsToday}, dailyGoal: ${dailyGoal} }';

}

class CounterErrorState extends CounterState {
  final String errorString;

  CounterErrorState(this.errorString);

  @override
  String toString() => 'CounterErrorState { errorString: $errorString }';

  @override
  List<Object> get props => [errorString];
}