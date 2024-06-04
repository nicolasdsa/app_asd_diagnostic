import 'package:flutter/material.dart';

class ListData<T> extends StatefulWidget {
  final ValueNotifier questionChangeNotifier;
  final Future<List<T>> Function() getItems;
  final Widget Function(T item) buildItem;
  final Widget Function(BuildContext context)? navigateTo;
  final String? buttonText;
  final void Function(T item)? onSelect;
  final Set<T> selectedItems;

  const ListData({
    Key? key,
    required this.questionChangeNotifier,
    required this.getItems,
    required this.buildItem,
    this.navigateTo,
    this.buttonText,
    this.onSelect,
    required this.selectedItems,
  }) : super(key: key);

  @override
  State<ListData<T>> createState() => _ListDataState<T>();
}

class _ListDataState<T> extends State<ListData<T>> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder(
          valueListenable: widget.questionChangeNotifier,
          builder: (context, value, child) {
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
                    children: items?.map((item) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (widget.selectedItems.contains(item)) {
                                  widget.selectedItems.remove(item);
                                } else {
                                  widget.selectedItems.add(item);
                                }
                              });
                              if (widget.onSelect != null) {
                                widget.onSelect!(item);
                              }
                            },
                            child: Container(
                              color: widget.selectedItems.contains(item)
                                  ? Colors.grey.shade300
                                  : Colors.transparent,
                              child: widget.buildItem(item),
                            ),
                          );
                        }).toList() ??
                        [],
                  );
                }
              },
            );
          },
        ),
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
}
