import 'package:equatable/equatable.dart';
import 'package:fastic_counter/models/daily_goal.dart';

abstract class CounterEvent extends Equatable {

  const CounterEvent();

  @override
  List<Object> get props => [];
}

class LoadCounterData extends CounterEvent {}

class IncrementCounterEvent extends CounterEvent {
  final int amount;

  IncrementCounterEvent({this.amount});
}

class SetDailyGoalEvent extends CounterEvent {
  final DailyGoal dailyGoal;

  SetDailyGoalEvent(this.dailyGoal);
}



