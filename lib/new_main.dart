import 'package:flutter/material.dart';
import './services/api_service.dart';
import './models/book.dart';
void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Library System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BookListScreen(),
    );
  }
}
class BookListScreen extends StatefulWidget {
  @override
  _BookListScreenState createState() => _BookListScreenState();
}
class _BookListScreenState extends State<BookListScreen> {
  late Future<List<Book>> books;
  final ApiService apiService = ApiService();
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    books = apiService.getBooks();
  }
  // Search books based on criteria
  void searchBooks(String criteria, String keyword) {
    setState(() {
      books = apiService.searchBooks(criteria, keyword);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Library Books'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearchDialog(context);
            },
          )
        ],
      ),
      body: FutureBuilder<List<Book>>(
        future: books,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No books found'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final book = snapshot.data![index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(book.title),
                  subtitle: Text('Author: ${book.author}'),
                  trailing: Text('Quantity: ${book.quantity}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookDetailScreen(bookId: book.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddBookScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
  void showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Search Books'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(hintText: 'Enter search keyword'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  searchBooks('title', searchController.text);
                  Navigator.pop(context);
                },
                child: Text('Search by Title'),
              ),
              ElevatedButton(
                onPressed: () {
                  searchBooks('author', searchController.text);
                  Navigator.pop(context);
                },
                child: Text('Search by Author'),
              ),
            ],
          ),
        );
      },
    );
  }
}
class BookDetailScreen extends StatelessWidget {
  final String bookId;
  const BookDetailScreen({required this.bookId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book Details')),
      body: Center(child: Text('Details of Book ID: $bookId')),
    );
  }
}
class AddBookScreen extends StatefulWidget {
  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}
class _AddBookScreenState extends State<AddBookScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController publicationDateController = TextEditingController();
  final ApiService apiService = ApiService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Book')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: authorController,
              decoration: InputDecoration(labelText: 'Author'),
            ),
            TextField(
              controller: publicationDateController,
              decoration: InputDecoration(labelText: 'Publication Date'),
            ),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final newBook = Book(
                  id: '',
                  title: titleController.text,
                  author: authorController.text,
                  publicationDate: publicationDateController.text,
                  quantity: int.parse(quantityController.text),
                );
                apiService.addBook(newBook).then((_) {
                  Navigator.pop(context);
                }).catchError((e) {
                  // Handle error
                  print(e);
                });
              },
              child: Text('Add Book'),
            ),
          ],
        ),
      ),
    );
  }
}
