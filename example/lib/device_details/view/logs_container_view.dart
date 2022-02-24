import 'package:flutter/material.dart';
import 'package:flutter_ble_lib_example/device_details/device_details_bloc.dart';

class LogsContainerView extends StatelessWidget {
  final Stream<List<DebugLog>> _logs;

  LogsContainerView(this._logs);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(4.0))),
      child: SizedBox.expand(
        child: Column(
          children: <Widget>[
            Flexible(
              child: StreamBuilder<List<DebugLog>>(
                initialData: [],
                stream: _logs,
                builder: (context, snapshot) => _buildLogs(context, snapshot),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogs(BuildContext context, AsyncSnapshot<List<DebugLog>> logs) {
    final data = logs.data;
    return ListView.builder(
      itemCount: data?.length,
      shrinkWrap: true,
      itemBuilder: (buildContext, index) => Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey,
              width: 0.5,
            ),
            bottom: BorderSide(
              color: Colors.grey,
              width: 0.5,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  data?[index].time ?? "",
                  style: TextStyle(fontSize: 9),
                ),
              ),
              Flexible(
                child: Text(
                  data?[index].content ?? "",
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: TextStyle(fontSize: 13)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
