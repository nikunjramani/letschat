import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:letschat/ui/searchuser/search_user.dart';
import 'package:letschat/utils/firestore_provider.dart';

class CustomSearchDelegate extends SearchDelegate {
  QuerySnapshot userList;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    print(query);
    DataBaseMethods.getUserByName(query).then((val) {
      userList = val;
    });

    if (userList != null) {
      return Container(
          child: ListView.builder(
        itemCount: userList.docs.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return SearchUser(
            name: userList.docs[index].get("name"),
            number: userList.docs[index].get("number"),
            image: userList.docs[index].get("image"),
            token: userList.docs[index].get("usertoken"),
          );
        },
      ));
    } else {
      return Container();
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This method is called everytime the search term changes.
    // If you want to add search suggestions as the user enters their search term, this is the place to do that.
  }
}
