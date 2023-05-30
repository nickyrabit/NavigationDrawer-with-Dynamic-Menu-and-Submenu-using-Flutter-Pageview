import 'package:dynamic_navigation_drawer/views/dashboard.dart';
import 'package:dynamic_navigation_drawer/views/main_menu/receivables/fund_source.dart';
import 'package:dynamic_navigation_drawer/views/setups/gfs_codes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'views/main_menu/receivables/receipts.dart';

void main() => runApp(MyHomePage());

// initiating variables for this indexes and paging
var _selectedPageIndex;
List<Widget> _pages;
PageController _pageController;
Map<String, String> headers = {
  'content-type': 'application/json; charset=utf-8',
  'accept': 'application/json'
};

class Controller extends GetxController {
  // making the variable observable to be able to change it when new screen is opened
  var title = "Dashboard".obs;
}

class MyHomePage extends StatefulWidget {
  //defining the title
  final String title;
  MyHomePage({Key key, this.title}) : super(key: key);
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<http.Response> _responseFuture;
  @override
  void initState() {
    super.initState();
    _responseFuture = http.get(Uri.parse('https://jsonkeeper.com/b/LD4N'),headers: headers) ;
    _selectedPageIndex = 0;
    _pages = [
      // it is important to keep these indices number so you will find it easier to reference them whne you want to open them
      // 0
      Dashboard(),
      // 1
      Receipts(),
      // 2
      FundSource(),
      // 3
      GFSCodes()
      ];
    // initiating a page controller
    _pageController = PageController(initialPage: _selectedPageIndex);
  }

  @override
  void dispose() {
    // dispose the page controller
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Controller c = Get.put(Controller());
    return GetMaterialApp(
      title: 'Accounting App',

      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: Obx(() => Text("${c.title.value}"))),
        // this is our main tool PageView
        // we need to stop it from scrolling with NeverScrollableScrollPhysics()
        // we need to list all screens with _pages variable at children
        // we need to attach our page controller here
        body: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: _pages,
        ),
        drawer: createDrawer(context, _responseFuture),
      ),
    );
  }
}

class MyExpansionTile extends StatefulWidget {
  final int did;
  final String name;
  MyExpansionTile(this.did, this.name);
  @override
  State createState() => new MyExpansionTileState();
}

class MyExpansionTileState extends State<MyExpansionTile> {
  PageStorageKey _key;
  Future<http.Response> _responseFuture;
  String title;

  @override
  void initState() {
    super.initState();
     _responseFuture = http.get(Uri.parse('https://jsonkeeper.com/b/LD4N'),headers: headers);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
          child: Text(
            'A drawer is an invisible side screen.',
            style: TextStyle(fontSize: 20.0),
          )),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text("Matinde Davis"),
              accountEmail: Text("matindedavis@gmail.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.orange,
                child: Text(
                  "M.D",
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
            ),
            ExpansionTile(
              leading: Icon(
                Icons.audiotrack,
                color: Colors.green,
                size: 30.0,
              ),
              title: Text(
                'items.playerName',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
              ),
              children: <Widget>[
                ListTile(
                  leading: Visibility(
                    child: Icon(
                      Icons.ac_unit,
                      size: 15,
                    ),
                    visible: false,
                  ),
                  onTap: () => {},
                  title: Text(
                    'items.description',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _currentRoute = "/";
void doRoute(BuildContext context, String name) {
  if (_currentRoute != name)
    Navigator.pushReplacementNamed(context, name);
  else
    Navigator.pop(context);
  _currentRoute = name;
}

Widget createDrawer(
    BuildContext context, Future<http.Response> _responseFuture) {
  final _controller = ScrollController();

  return Drawer(
    child: SingleChildScrollView(
      controller: _controller,
      child: Column(
        // Important: Remove any padding from the ListView.
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text("Matinde Davis"),
            accountEmail: Text("matindedavis@gmail.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.orange,
              child: Text(
                "M.D",
                style: TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          new FutureBuilder(
            future: _responseFuture,
            builder:
                (BuildContext context, AsyncSnapshot<http.Response> response) {

              if (!response.hasData) {
                return const Center(
                  child: const Text('Loading...'),
                );
              } else if (response.data.statusCode != 200) {
                return const Center(
                  child: const Text('Error loading data'),
                );
              } else {
                List<dynamic> json = jsonDecode(response.data.body);
                return new MyExpansionTileList(elementList: json);
              }
            },
          )
        ],
      ),
    ),
  );
}

class MyExpansionTileList extends StatefulWidget {
  BuildContext context;
  final List<dynamic> elementList;

  MyExpansionTileList({Key key, this.elementList}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DrawerState();
}

class _DrawerState extends State<MyExpansionTileList> {
  // You can ask Get to find a Controller that is being used by another page and redirect you to it.
  final Controller c = Get.find();

  List<Widget> _getChildren(final List<dynamic> elementList) {
    List<Widget> children = [];
    elementList.toList().asMap().forEach((index, element) {
      int selected = 0;
      final subMenuChildren = <Widget>[];
      try {
        for (var i = 0; i < element['children'].length; i++) {
          subMenuChildren.add(new ListTile(
            leading: Visibility(
              child: Icon(
                Icons.account_box_rounded,
                size: 15,
              ),
              visible: false,
            ),
            onTap: () => {
              setState(() {
                log("The item clicked is " + element['children'][i]['state']);

                //from the json we got which contains the menu and submenu we will need the "state"
                // json item to get the unique identifier so we know what to open

                switch (element['children'][i]['state']) {
                  case '/fund-type':
                    //setting current index and opening a new screen using page controller with animations
                    _selectedPageIndex = 1;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_pageController.hasClients) {
                        _pageController.animateToPage(1, duration: Duration(milliseconds: 1), curve: Curves.easeInOut);
                      }
                    });
                    c.title.value = "Fund Type";
                    Navigator.pop(context);


                    break;
                  case '/fund-sources':
                    _selectedPageIndex = 2;
                    // _pageController.jumpToPage(2);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_pageController.hasClients) {
                        _pageController.animateToPage(2,
                            duration: Duration(milliseconds: 1),
                            curve: Curves.easeInOut);
                      }
                    });
                    c.title.value = "Fund Source";

                    Navigator.pop(context);

                    break;
                }
              })
            },
            title: Text(
              element['children'][i]['title'],
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ));
        }
        children.add(
          new ExpansionTile(
            key: Key(index.toString()),
            initiallyExpanded: index == selected,
            leading: Icon(
              Icons.audiotrack,
              color: Colors.green,
              size: 30.0,
            ),
            title: Text(
              element['title'],
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
            ),
            children: subMenuChildren,
            onExpansionChanged: ((newState) {
              if (newState) {
                Duration(seconds: 20000);
                selected = index;
                log(' selected ' + index.toString());
              } else {
                selected = -1;
                log(' selected ' + selected.toString());
              }
            }),
          ),
        );
      } catch (err) {
        print('Caught error: $err');
      }
    });
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: _getChildren(widget.elementList),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
