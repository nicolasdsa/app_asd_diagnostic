import 'package:flutter/material.dart';

class ListData<T> extends StatelessWidget {
  final ValueNotifier questionChangeNotifier;
  final Future<List<T>> Function() getItems;
  final Widget Function(T item) buildItem;
  final Widget Function(BuildContext context) navigateTo;
  final String buttonText;

  const ListData({
    super.key,
    required this.questionChangeNotifier,
    required this.getItems,
    required this.buildItem,
    required this.navigateTo,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder(
          valueListenable: questionChangeNotifier,
          builder: (context, value, child) {
            return FutureBuilder<List<T>>(
              future: getItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final items = snapshot.data;
                  return Column(
                    children: items?.map(buildItem).toList() ?? [],
                  );
                }
              },
            );
          },
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: navigateTo),
            );
          },
          child: Text(buttonText),
        ),
      ],
    );
  }
}
