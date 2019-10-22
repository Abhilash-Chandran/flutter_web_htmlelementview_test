import 'dart:html';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart' hide RangeSlider;
import 'package:flutter_web_htmlelementview_test/plotly.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web HTMLElementView Consumes all the click and scroll',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePageWithPlotly(),
    );
  }
}

class MyHomePageWithPlotly extends StatefulWidget {
  @override
  _MyHomePageWithPlotlyState createState() => _MyHomePageWithPlotlyState();
}

class _MyHomePageWithPlotlyState extends State<MyHomePageWithPlotly> {
  DivElement div2 = DivElement()..id = "plot_div_id";
  DivElement div1 = DivElement()
    ..id = "plot_div_id"
    ..innerHtml =
        "Scroll any where in this Div1 with the popup menu or show dialog open and check the Div2. <br/> Div1 also responds to click on the popUpMenu.";

  int clickCounter = 0;
  @override
  void initState() {
    // adding a mouse wheel listener for div1
    div1.onMouseWheel.listen((data) {
      div2.setInnerHtml(
          'Div1 is still receiving mouse wheel <br> x: ${data.deltaX} <br> y: ${data.deltaY} ');
    });
    div1.onMouseMove.listen((onData) {
      div2.setInnerHtml('Div1 is receiving mouse move event.');
    });
    div1.onClick.listen((onData) {
      clickCounter++;
      div2.setInnerHtml('Div1 is being clicked $clickCounter times.');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ui.platformViewRegistry.registerViewFactory(
      "div1",
      (int viewId) {
        return div1;
      },
    );
    ui.platformViewRegistry.registerViewFactory(
      "div2",
      (int viewId) {
        return div2;
      },
    );
    return Container(
      child: Column(
        children: <Widget>[
          Material(
            color: Colors.lime,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 20.0,
                      width: 1.0,
                      decoration: BoxDecoration(
                          border: Border.all(
                        width: 1.0,
                      )),
                    ),
                  ),
                  PopupMenuButton(
                    tooltip: 'Shows a popupMenu',
                    child: Text('Show popupMenu'),
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          child: Text('Item, one'),
                        ),
                        PopupMenuItem(
                          child: Text('Item, two'),
                        ),
                        PopupMenuItem(
                          child: Text('Item, three'),
                        ),
                        PopupMenuItem(
                          child: Text('Item, four'),
                        ),
                        PopupMenuItem(
                          child: Text('Item, five'),
                        )
                      ];
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                      height: 20.0,
                      width: 2.0,
                      decoration: BoxDecoration(
                          border: Border.all(
                        width: 1.0,
                      )),
                    ),
                  ),
                  FlatButton(
                    child: Text('show dialog'),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: Text(
                                  'Div1 below this is still scrolablle :('),
                            );
                          });
                    },
                  )
                ],
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                width: 1.0,
                color: Colors.lightBlue,
              )),
              child: HtmlElementView(
                viewType: 'div1',
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: HtmlElementView(
              viewType: 'div2',
            ),
          ),
          Expanded(
            flex: 2,
            child: FloatingActionButton(
              child: Icon(Icons.poll),
              tooltip: 'Plot new data using plotly',
              onPressed: () {
                /// Use plotly to plot a new plot in the element [div1]
                Plotly.newPlot(div1, [getData()], getLayout(), getConfig());
              },
            ),
          )
        ],
      ),
    );
  }

  /// Create some data for plotly.
  Data getData() {
    Random random = Random();
    return Data(
      type: 'scatter',
      mode: "lines",
      x: List.generate(1000, (index) => index),
      y: List.generate(1000, (index) => random.nextInt(100)),
    );
  }

  /// Create Plotly Layout.
  Layout getLayout() {
    return Layout(
      margin: Margin(
        l: 50,
        t: 20,
        r: 20,
        b: 30,
      ),
      xaxis: getXAxisLayout(),
      yaxis: getYAxisLayout(),
      showlegend: true,
      dragmode: 'pan',
      hovermode: 'closest',
      grid: null,
      autosize: true,
    );
  }

  /// Create an Xaxis layout.
  /// Unfortunately Rangeslider doesnt work. :(
  AxisLayout getXAxisLayout() {
    return AxisLayout(
      rangeslider: RangeSlider(
        visible: true,
      ),
      showgrid: false,
      showline: true,
      zeroline: false,
    );
  }

  AxisLayout getYAxisLayout() {
    return AxisLayout(
      showgrid: false,
      showline: true,
      fixedrange: true,
      autorange: true,
      zeroline: false,
    );
  }

  /// Some ploltly config
  /// Modebar is not properly diplaying. this is shdaw dom issue with plotly.
  Configuration getConfig() {
    return Configuration(
      responsive: true,
      displayModeBar: false,
      scrollZoom: true,
    );
  }
}
