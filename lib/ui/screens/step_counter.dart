import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import 'package:fastic_counter/bloc/counter/counter_bloc.dart';
import 'package:fastic_counter/bloc/counter/counter_event.dart';
import 'package:fastic_counter/bloc/counter/counter_state.dart';
import 'package:fastic_counter/models/daily_goal.dart';

class StepCounter extends StatefulWidget {
  @override
  _StepCounterState createState() => _StepCounterState();
}

class _StepCounterState extends State<StepCounter> {

  CounterBloc _counterBloc;
  int _stepPerTap = 10; // Mock data for the steps -> with every tap 10 steps are added
  double _caloriePerStep = 0.035;
  TextEditingController _dailyGoalController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _counterBloc = BlocProvider.of<CounterBloc>(context);
    _counterBloc.add(LoadCounterData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "Stepcounter",
          style: Theme.of(context).textTheme.headline2,
        ),
      ),
      body: BlocBuilder<CounterBloc, CounterState>(builder: (_, counterState) {
        if (counterState is LoadedCounterState) {
          return _loadedCounterState(counterState);
        } else if (counterState is CounterErrorState) {
          return _errorCounterState(counterState);
        } else {
          return _loadingState();
        }
      }),
    );
  }

  Widget _loadedCounterState(LoadedCounterState counterState) {
    // Calculate the percentage of the reached goal
    // _percent is for the Percent value in the middle of the Indicator (Which can be more then 100%)
    // _percentIndicatorValue is the percent value for the circle and linear indicators, which can't ne higher the 1.0
    double _percent = 0.0;
    double _percentIndicatorValue = 0.0;
    if (counterState.dailyGoal != null) {
      _percent = (100 /
          (counterState.dailyGoal.stepsGoal / counterState.stepsToday));
    }

    _percentIndicatorValue = _percent / 100;

    if (_percentIndicatorValue > 1.0) {
      _percentIndicatorValue = 1.0;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _percentIndicator(_percent, _percentIndicatorValue),
        _stepsAndCalories(counterState),
        _dailyGoalButton(),
        _dailyGoalIndicator(_percentIndicatorValue),
      ],
    );
  }

  Widget _errorCounterState(CounterErrorState counterState) {
    return Center(
      child: Text(
        counterState.errorString,
        style: Theme.of(context).textTheme.headline2,
      ),
    );
  }

  Widget _loadingState() {
    return Container(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _percentIndicator(double _percent, double _percentIndicator) {
    return GestureDetector(
      child: Stack(
        children: [
          Center(
            child: Container(
              padding: EdgeInsets.all(20),
              child: CircularPercentIndicator(
                radius: 180.0,
                lineWidth: 10.0,
                animation: false,
                percent: _percentIndicator,
                center: new Text(
                  "${_percent.round()}%",
                  style: Theme.of(context).textTheme.headline1,
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: Color.fromRGBO(247, 165, 108, 1),
                backgroundColor: Color.fromRGBO(237, 241, 243, 1),
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        context.read<CounterBloc>().add(
              IncrementCounterEvent(amount: _stepPerTap),
            );
      },
    );
  }

  Widget _stepsAndCalories(LoadedCounterState counter) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _stepsText(counter.stepsToday, counter.dailyGoal),
        _caloriesText(counter.stepsToday),
      ],
    );
  }

  Widget _stepsText(int stepsToday, DailyGoal dailyGoal) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Image.asset("assets/images/steps.png"),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 2.0),
            child: Text(
              "$stepsToday / ${dailyGoal == null ? "0" : dailyGoal.stepsGoal}",
              style: Theme.of(context).textTheme.headline3,
            ),
          ),
          Text(
            "Schritte",
            style: Theme.of(context).textTheme.headline4,
          ),
        ],
      ),
    );
  }

  Widget _caloriesText(int stepsToday) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Image.asset("assets/images/flame.png"),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 2.0),
            child: Text(
              "${(stepsToday * _caloriePerStep).round()}",
              style: Theme.of(context).textTheme.headline3,
            ),
          ),
          Text(
            "Kalorien",
            style: Theme.of(context).textTheme.headline4,
          ),
        ],
      ),
    );
  }

  Widget _dailyGoalButton() {
    return FlatButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      color: Color.fromRGBO(237, 241, 243, 1),
      child: Container(
        width: 120,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  Icons.edit,
                  color: Color.fromRGBO(89, 98, 116, 1),
                ),
              ),
              Text(
                "Daily Goal",
                style: Theme.of(context).textTheme.button,
              ),
            ],
          ),
        ),
      ),
      onPressed: () async {
        String answer = await _showDailyGoalDialog();
        _dailyGoalController.clear();
        if (answer != null) {
          DailyGoal _dailyGoal = DailyGoal(
              DateFormat('yyyy-MM-dd').format(DateTime.now()),
              int.parse(answer));
          context.read<CounterBloc>().add(
                SetDailyGoalEvent(_dailyGoal),
              );
        }
      },
    );
  }

  Future<String> _showDailyGoalDialog() async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Setz Dein Daily Goal'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Wieviele Schritte sind für heute Dein Ziel?'),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _dailyGoalController,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Abbrechen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ziel setzen'),
              onPressed: () {
                Navigator.pop(context, _dailyGoalController.text);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _dailyGoalIndicator(double _percentIndicatorValue) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.flag,
              size: 16.0,
              color: Color.fromRGBO(31, 52, 85, 1),
            ),
          ),
          LinearPercentIndicator(
            width: MediaQuery.of(context).size.width * 0.9,
            animation: false,
            lineHeight: 10.0,
            animationDuration: 1500,
            percent: _percentIndicatorValue,
            linearStrokeCap: LinearStrokeCap.roundAll,
            progressColor: Color.fromRGBO(247, 165, 108, 1),
            backgroundColor: Color.fromRGBO(237, 241, 243, 1),
          ),
        ],
      ),
    );
  }
}
