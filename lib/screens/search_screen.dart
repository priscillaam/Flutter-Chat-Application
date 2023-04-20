import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SearchScreen extends StatefulWidget {
  UserModel user;
  // ignore: use_key_in_widget_constructors
  SearchScreen(this.user);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map> searchResult = [];
  bool isLoading = false;

  void onSearch() async {
    setState(() {
      searchResult = [];
      isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: searchController.text)
        .get()
        .then((value) {
      // ignore: prefer_is_empty
      if (value.docs.length < 1) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('No User Found')));
        setState(() {
          isLoading = false;
        });
        return;
      }
      // ignore: avoid_function_literals_in_foreach_calls
      value.docs.forEach((user) {
        if (user.data()['email'] != widget.user.email) {
          searchResult.add(user.data());
        }
      });
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Search your Friend'),
        ),
        body: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                          hintText: 'type username...',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      onSearch();
                    },
                    icon: const Icon(Icons.search))
              ],
            ),
            // ignore: prefer_is_empty
            if (searchResult.length > 0)
              Expanded(
                  child: ListView.builder(
                      itemCount: searchResult.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            child: Image.network(searchResult[index]['image']),
                          ),
                          title: Text(searchResult[index]['name']),
                          subtitle: Text(searchResult[index]['email']),
                          trailing: IconButton(
                              onPressed: () {
                                setState(() {
                                  searchController.text = '';
                                });
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                            currentUser: widget.user,
                                            friendId: searchResult[index]
                                                ['uid'],
                                            friendName: searchResult[index]
                                                ['name'],
                                            friendImage: searchResult[index]
                                                ['image'])));
                              },
                              icon: const Icon(Icons.message)),
                        );
                      }))
            else if (isLoading == true)
              const Center(
                child: CircularProgressIndicator(),
              )
          ],
        ));
  }
}
