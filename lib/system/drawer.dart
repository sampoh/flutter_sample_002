import 'package:flutter/material.dart';
import './common.dart';
import '../list_a.dart';
import '../list_b.dart';
import '../list_c.dart';
import '../list_d.dart';
// import '../list_z.dart';

//ドロワ ( メニュー )
class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(
              height: 70,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text('Menu'),
              )),
          ListTile(
            title: const Text('Menu item 001'),
            // selected: _selectedIndex == 1,
            onTap: () {
              // Update the state of the app
              // _onItemTapped(1);
              // Then close the drawer
              // Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return const DataTableDemo(); //"list_a.dart"
                  },
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Menu item 002'),
            // selected: _selectedIndex == 2,
            onTap: () {
              // Update the state of the app
              // _onItemTapped(2);
              // Then close the drawer
              // Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    // return const MyDataTable();
                    return const PaginatedDataTableView(); //"list_b.dart"
                  },
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Menu item 003'),
            // selected: _selectedIndex == 2,
            onTap: () {
              // Update the state of the app
              // _onItemTapped(2);
              // Then close the drawer
              // Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    // return const MyDataTable();
                    return const PaginatedDataTableProblem(); //"list_c.dart"
                  },
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Menu item 004'),
            // selected: _selectedIndex == 0,
            onTap: () {
              // Update the state of the app
              // _onItemTapped(0);
              // Then close the drawer
              // Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return const MyTableView(); //"list_d.dart"
                  },
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Logout'),
            // selected: _selectedIndex == 2,
            onTap: () async {
              // Update the state of the app
              // _onItemTapped(2);
              // Then close the drawer
              // Navigator.pop(context);
              var session = Session();
              await session.logout();
              // ignore: use_build_context_synchronously
              RestartWidget.restartApp(context);
            },
          ),
        ],
      ),
    );
  }
}
