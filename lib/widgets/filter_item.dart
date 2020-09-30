import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_app/providers/product.dart';
import 'package:sales_app/providers/products.dart';
import 'package:sales_app/screens/product_detail_screen.dart';
import 'package:sales_app/widgets/product_item_grid_view.dart';
import 'package:sales_app/widgets/product_item_list_view.dart';


class DataSearch extends SearchDelegate<String> {
  final bool _showList;

  DataSearch(this._showList);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    List<Product> products = productsData.items
        .where((data) => data.title.toLowerCase().contains(query.toLowerCase()))
        .toList();


    return query.isEmpty? SizedBox(width: 0.0,height: 0.0,): ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: products.length,
        itemBuilder: (context, i) => ChangeNotifierProvider.value(
          value: products[i],
          child: Card(
              shape: BeveledRectangleBorder(
                borderRadius:
                BorderRadius.all(Radius.circular(8.0)),
              ),
              child:ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      products[i].title,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 05.0,),
                  ],
                ),
                subtitle: Text('BDT ' + products[i].price.toString() + '/' + products[i].unit,style: TextStyle(fontSize: 15.0,color: Colors.grey),),
                leading: Hero(
                  tag: products[i].id,
                  child: FadeInImage(
                    image: NetworkImage(products[i].imageUrl),
                    height: 70.0,
                    width: 50.0,
                    fit: BoxFit.contain,
                    placeholder: AssetImage('assets/products.png'),
                  ),
                ),
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(ProductDetailScreen.routeName, arguments: products[i].id);
                },
              )),
        ));

//    return query.isEmpty? SizedBox(width: 0.0,height: 0.0,):_showList
//        ? ListView.builder(
//            padding: const EdgeInsets.all(10.0),
//            itemCount: products.length,
//            itemBuilder: (context, i) => ChangeNotifierProvider.value(
//                  value: products[i],
//                  child: ProductItemListView(),
//                ))
//        : GridView.builder(
//            padding: const EdgeInsets.all(10.0),
//            itemCount: products.length,
//            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//              crossAxisCount: 2,
//              childAspectRatio: 3 / 2,
//              crossAxisSpacing: 10,
//              mainAxisSpacing: 10,
//            ),
//            itemBuilder: (context, i) => ChangeNotifierProvider.value(
//                  value: products[i],
//                  child: ProductItemGridView(),
//                ));
  }

  List<TextSpan> highlightOccurrences(String source, String query) {
    if (query == null || query.isEmpty || !source.toLowerCase().contains(query.toLowerCase())) {
      return [ TextSpan(text: source) ];
    }
    final matches = query.toLowerCase().allMatches(source.toLowerCase());

    int lastMatchEnd = 0;

    final List<TextSpan> children = [];
    for (var i = 0; i < matches.length; i++) {
      final match = matches.elementAt(i);

      if (match.start != lastMatchEnd) {
        children.add(TextSpan(
          text: source.substring(lastMatchEnd, match.start),
        ));
      }

      children.add(TextSpan(
        text: source.substring(match.start, match.end),
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ));

      if (i == matches.length - 1 && match.end != source.length) {
        children.add(TextSpan(
          text: source.substring(match.end, source.length),
        ));
      }

      lastMatchEnd = match.end;
    }
    return children;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return query.isEmpty ? SizedBox(width: 0.0,height: 0.0,): FutureBuilder(
      future: Provider.of<Products>(context).searchAndSetProducts(keyword: query),
      builder: (context, snapshot) {
//        if (snapshot.connectionState == ConnectionState.waiting) {
//          return Center(child:CircularProgressIndicator());
//        } else {
        return Consumer<Products>(
          builder: (context, data,child) => ListView.builder(
            itemCount: data.items.length,
            itemBuilder: (context, i) => ListTile(
              onTap: () {
                showResults(context);
              },
              title:
              RichText(
                text: TextSpan(
                  children: highlightOccurrences(data.items[i].title, query),
                  style: TextStyle(color: Colors.grey),
                ),
              ),
//                RichText(
//                  text: TextSpan(
//                      text: data.items[i].title.substring(0, query.length),
//                      style: TextStyle(color: Colors.black),
////                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//                      children: [
//                        TextSpan(
//                          text: data.items[i].title.substring(query.length),
//                          style: TextStyle(color: Colors.black),
//                        )
//                      ]
//                  ),
//                ),
            ),
          ),
        );
//        }
      },
    );
//    final productsData = Provider.of<Products>(context);
//    List<Product> products = query.isEmpty
//        ? []
//        : productsData.items
//        .where((data) =>
//        data.title.toLowerCase().contains(query.toLowerCase()))
//        .toList();
//    return ListView.builder(
//      itemCount: products.length,
//      itemBuilder: (context, i) => ListTile(
//        onTap: (){
//          showResults(context);
//        },
//        title: RichText(
//          text: TextSpan(
//              text: products[i].title.substring(0, query.length),
//              style:
//              TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
////              TextStyle(color: Colors.black),
//              children: [
//                TextSpan(
//                  text: products[i].title.substring(query.length),
//                  style: TextStyle(color: Colors.grey),
//                )
//              ]),
//        ),
//      ),
//    );
////    List<Product> data = products.where((dt) => dt.title.toLowerCase().contains(value.toLowerCase())).toList();
  }
}
