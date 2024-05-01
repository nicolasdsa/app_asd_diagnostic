import 'package:app_asd_diagnostic/db/form_dao.dart';
import 'package:app_asd_diagnostic/screens/components/form_user.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final ValueNotifier<int> formChangeNotifier;

  const HomeScreen({Key? key, required this.formChangeNotifier})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formDao = FormDao();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.formChangeNotifier,
      builder: (context, value, child) {
        return FutureBuilder<List<FormUser>>(
          future: _formDao.getAllForms(),
          builder: (context, snapshot) {
            List<FormUser>? items = snapshot.data;
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      Text('Carregando'),
                    ],
                  ),
                );

              case ConnectionState.waiting:
                return const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      Text('Carregando'),
                    ],
                  ),
                );
              case ConnectionState.active:
                return const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      Text('Carregando'),
                    ],
                  ),
                );
              case ConnectionState.done:
                if (snapshot.hasData && items != null) {
                  if (items.isNotEmpty) {
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (BuildContext context, int index) {
                        final FormUser form = items[index];
                        return form;
                      },
                    );
                  }
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 128,
                        ),
                        Text(
                          'Não há nenhuma formulario',
                          style: TextStyle(fontSize: 32),
                        ),
                      ],
                    ),
                  );
                }
                return const Text('Erro ao carregar formulario');
            }
          },
        );
      },
    );
  }
}
