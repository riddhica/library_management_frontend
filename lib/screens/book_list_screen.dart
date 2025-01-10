import 'package:flutter/material.dart';
import 'package:library_management_frontend/models/book.dart';
import 'package:library_management_frontend/models/user.dart';
import 'package:library_management_frontend/services/api_service.dart';
import 'package:library_management_frontend/services/auth_service.dart';
import 'package:library_management_frontend/screens/book_detail_screen.dart';
import 'package:library_management_frontend/screens/add_book_screen.dart';
import 'package:library_management_frontend/screens/login_screen.dart'; 

class BookListScreen extends StatefulWidget {

  final User user;
  BookListScreen({required this.user});

  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  bool _isLoading = false;
  List<Book> _books = [];
  List<Book> _filteredBooks = [];

  final AuthService _authService = AuthService(); 
  
    // Handle logout
  void _logout(BuildContext context) async {
    await _authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()), 
    );
  }

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
      _showErrorMessage('Failed to fetch books. Please try again.');
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
      appBar: AppBar(
        title: Text('Library Books'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 40.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () async {
                    await _authService.logout();
                     _showSuccessMessage('Logged out successfully');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                ),
                Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Welcome,  ${widget.user.username}', 
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildSearchBar(),
            _buildBookTable(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? isUpdated = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddBookScreen(user: widget.user)),
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

                    trailing: widget.user.role == 'Librarian'
                      ?
                      Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () async {
                            bool? isUpdated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddBookScreen( user: widget.user, book: book),
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
                    )
                    : null,
                  ),
                );
              },
            ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    ));
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }
}