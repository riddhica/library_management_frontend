import 'package:flutter/material.dart';
import 'package:library_management_frontend/models/book.dart';
import 'package:library_management_frontend/services/api_service.dart';
import 'package:library_management_frontend/screens/book_detail_screen.dart';
import 'package:library_management_frontend/screens/add_book_screen.dart';

class BookListScreen extends StatefulWidget {
  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  bool _isLoading = false;
  List<Book> _books = [];
  List<Book> _filteredBooks = [];
  
  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final books = await ApiService().fetchBooks(); 
      setState(() {
        _books = books;
        _filteredBooks = books;  // Initially show all books
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      // Handle error properly (e.g., show an error message)
    }
  }
    void _filterBooks(String query) {
        setState(() {
        _filteredBooks = _books
            .where((book) =>
                book.title.toLowerCase().contains(query.toLowerCase()) ||
                book.author.toLowerCase().contains(query.toLowerCase()))
            .toList();
        });
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Library Books')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            _buildBookTable(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? isUpdated = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddBookScreen()),
          );
          if (isUpdated == true) {
            _fetchBooks();  // Refresh data after adding a book
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Search books...',
          suffixIcon: Icon(Icons.search),
        ),
        onChanged: _filterBooks, // Filter books based on search query
      ),
    );
  }
Widget _buildBookTable() {
    return Expanded(
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _filteredBooks.length,
              itemBuilder: (context, index) {
                final book = _filteredBooks[index];
                return Card(
                  child: ListTile(
                    title: Text(book.title),
                    subtitle: Text(book.author),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () async {
                            bool? isUpdated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddBookScreen(book: book),
                              ),
                            );
                            if (isUpdated == true) {
                              _fetchBooks();  // Refresh data after editing the book
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            bool success = await ApiService().deleteBook(book.id);
                            if (success) {
                              _showSuccessMessage('Book deleted successfully');
                              _fetchBooks();  // Refresh data
                            } else {
                              _showErrorMessage('Error removing book');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }
}