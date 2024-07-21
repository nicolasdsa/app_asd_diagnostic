import 'package:flutter/material.dart';

class ListData<T> extends StatefulWidget {
  final ValueNotifier<int>? questionChangeNotifier;
  final Future<List<T>> Function() getItems;
  final Widget Function(T item) buildItem;
  final Widget Function(BuildContext context)? navigateTo;
  final String? buttonText;
  final void Function(T item)? onSelect;

  const ListData({
    Key? key,
    this.questionChangeNotifier,
    required this.getItems,
    required this.buildItem,
    this.navigateTo,
    this.buttonText,
    this.onSelect,
  }) : super(key: key);

  @override
  State<ListData<T>> createState() => _ListDataState<T>();
}

class _ListDataState<T> extends State<ListData<T>> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.questionChangeNotifier != null)
          ValueListenableBuilder(
            valueListenable: widget.questionChangeNotifier!,
            builder: (context, value, child) {
              return _buildList();
            },
          )
        else
          _buildList(),
        if (widget.navigateTo != null && widget.buttonText != null)
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: widget.navigateTo!),
              );
            },
            child: Text(widget.buttonText!),
          ),
      ],
    );
  }

  Widget _buildList() {
    return FutureBuilder<List<T>>(
      future: widget.getItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final items = snapshot.data;
          return Column(
            children: items?.map(widget.buildItem).toList() ?? [],
          );
        }
      },
    );
  }
}
