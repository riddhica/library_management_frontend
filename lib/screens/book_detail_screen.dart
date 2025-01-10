import 'package:flutter/material.dart';
import 'package:library_management_frontend/models/book.dart';
import 'package:library_management_frontend/models/user.dart';
import 'package:library_management_frontend/services/api_service.dart';
import 'package:library_management_frontend/screens/add_book_screen.dart'; 

class BookDetailScreen extends StatelessWidget {
  final User user;
  final Book book;

  BookDetailScreen({ required this.user,required this.book});

  final ApiService apiService = ApiService();

  void deleteBook(BuildContext context) {
    apiService.deleteBook(book.id).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Book deleted successfully')));
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete book')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Title: ${book.title}', style: TextStyle(fontSize: 20)),
            Text('Author: ${book.author}', style: TextStyle(fontSize: 18)),
            Text('Published on: ${book.publicationDate}', style: TextStyle(fontSize: 18)),
            Text('Quantity: ${book.quantity}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddBookScreen(user: this.user, book: book),
                  ),
                );
              },
              child: Text('Edit Book'),
              style: ElevatedButton.styleFrom(
                primary: Colors.orange,
                padding: EdgeInsets.symmetric(vertical: 15.0),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => deleteBook(context),
              child: Text('Delete Book'),
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 15.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
