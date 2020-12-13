import 'dart:async';

import 'package:intl/intl.dart';
import 'package:fastic_counter/bloc/counter/counter_state.dart';
import 'package:fastic_counter/models/daily_goal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'counter_event.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(InitialCounterState());

  @override
  Stream<CounterState> mapEventToState(CounterEvent event) async* {

    final currentState = state;
    if (event is LoadCounterData) {
      if (currentState is InitialCounterState) {
        final int stepsToday = await _getCurrentSteps(0);
        final DailyGoal dailyGoal = await _getDailyGoal();
        yield LoadedCounterState(
            stepsToday: stepsToday,
            dailyGoal: dailyGoal,
        );
      } else {
        yield CounterErrorState("Da lief etwas schief!");
      }
    } else if(event is IncrementCounterEvent) {
      if (currentState is LoadedCounterState) {
        final int stepsToday = await _getCurrentSteps(event.amount);
        final DailyGoal dailyGoal = await _getDailyGoal();

        yield currentState.copyWith(
          stepsToday: stepsToday,
          dailyGoal: dailyGoal,
        );
      } else {
        yield CounterErrorState("Da lief etwas schief!");
      }
    } else if (event is SetDailyGoalEvent) {
      if (currentState is LoadedCounterState) {
        final DailyGoal dailyGoal = await _setDailyGoal(event.dailyGoal);

        yield currentState.copyWith(
          dailyGoal: dailyGoal,
        );
      } else {
        yield CounterErrorState("Da lief etwas schief!");
      }
    } else {
      yield CounterErrorState("Da lief etwas schief!");
    }
  }

  // Return the amount of steps the user walked today
  // Receive the number of steps and add them to the given amount which is stored on the phone
  // If a goal is set and the current amount of steps is bigger than the goal -> The the 'goalReached' variable, which is stored on the phone to 'true'
  Future<int> _getCurrentSteps(int steps) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);

    int counter = (prefs.getInt('counter' + formattedDate) ?? 0) + steps;
    int goalSteps = prefs.getInt('goal' + formattedDate);

    if (goalSteps != null) {
      if (counter >= goalSteps) {
        prefs.setBool('goalReached' + formattedDate, true);
      } else {
        prefs.setBool('goalReached' + formattedDate, false);
      }
    }
    await prefs.setInt('counter' + formattedDate, counter);

    return counter;
  }

  // Return the Daily Goal, if it is set
  Future<DailyGoal> _getDailyGoal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);

    int goalSteps = prefs.getInt('goal' + formattedDate);

    if (goalSteps == null) {
      return null;
    } else {
      return DailyGoal(formattedDate, goalSteps);
    }
  }

  // Set the daily goal and store it on the phone
  // Set the goalReached variable to 'false' and store it on the phone
  Future<DailyGoal> _setDailyGoal(DailyGoal dailyGoal) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt('goal' + dailyGoal.timestamp, dailyGoal.stepsGoal);
    await prefs.setBool('goalReached' + dailyGoal.timestamp, false);
    return dailyGoal;
  }

}