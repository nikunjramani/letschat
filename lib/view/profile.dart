import 'package:flutter/material.dart';
import 'package:letschat/helper/Constants.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          leading:  IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: new Container(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100.0),
                  child: Image.network(
                    Constants.MyImage,
                    width: 200.0,
                    height: 200.0,
                    fit: BoxFit.fill,
                  ),
                ),
                Card(
                  margin: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 24,vertical: 16),
                        child: Row(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                // color: Colors.white,
                                borderRadius: BorderRadius.circular(48),
                              ),
                              child: Icon(Icons.person)
                            ),
                            SizedBox(width: 8,),
                            Text(Constants.MyName,style: TextStyle(
                                fontSize: 17
                            ))
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 24,vertical: 16),
                        child: Row(
                          children: [
                            Container(
                                height: 40,
                                width: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  // color: Colors.white,
                                  borderRadius: BorderRadius.circular(48),
                                ),
                                child: Icon(Icons.call)
                            ),
                            SizedBox(width: 8,),
                            Text(Constants.MyNumber,style: TextStyle(
                                fontSize: 17
                            ))
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 24,vertical: 16),
                        child: Row(
                          children: [
                            Container(
                                height: 40,
                                width: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  // color: Colors.white,
                                  borderRadius: BorderRadius.circular(48),
                                ),
                                child: Icon(Icons.accessibility_rounded)
                            ),
                            SizedBox(width: 8,),
                            Text(Constants.MyDob,style: TextStyle(
                                fontSize: 17
                            ))
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 24,vertical: 16),
                        child: Row(
                          children: [
                            Container(
                                height: 40,
                                width: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  // color: Colors.white,
                                  borderRadius: BorderRadius.circular(48),
                                ),
                                child: Icon(Icons.error_outline)
                            ),
                            SizedBox(width: 8,),
                            Text(Constants.MyAvoutMe,style: TextStyle(
                                fontSize: 17
                            ))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
