
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:letschat/model/searchusers.dart';
import 'package:letschat/data/firestore/DataBaseMethod.dart';

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
    DataBaseMethods.GetUserByName(query).then((val) {
      userList=val;
    });

    if(userList!=null){
      return Container(
          child: ListView.builder(
            itemCount: userList.documents.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return SearchUserList(
                name: userList.documents[index].get("name"),
                number: userList.documents[index].get("number"),
                image: userList.documents[index].get("image"),
                token: userList.documents[index].get("usertoken"),
              );
            },
          )
      );
    }else{
      return Container();
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This method is called everytime the search term changes.
    // If you want to add search suggestions as the user enters their search term, this is the place to do that.
  }
}