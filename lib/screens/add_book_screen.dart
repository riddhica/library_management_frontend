import 'package:flutter/material.dart';
import 'package:library_management_frontend/models/book.dart';
import 'package:library_management_frontend/models/user.dart';
import 'package:library_management_frontend/services/api_service.dart';

class AddBookScreen extends StatefulWidget {
  final User user;
  final Book? book;

  AddBookScreen({
    required this.user,
    this.book
  });

  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late String title, author, publicationDate;
  late int quantity;

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      title = widget.book!.title;
      author = widget.book!.author;
      publicationDate = widget.book!.publicationDate;
      quantity = widget.book!.quantity;
    } else {
      title = '';
      author = '';
      publicationDate = '';
      quantity = 0;
    }
  }

  // Submit the form
  void submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        Book bookDetails = Book(
          id: widget.book?.id ?? '',
          title: title,
          author: author,
          publicationDate: publicationDate,
          quantity: quantity,
        );

        if (widget.book == null) {
          await ApiService().addBook(bookDetails);
          _showSuccessMessage('Book added successfully');
        } else {
          await ApiService().updateBook(widget.book!.id, bookDetails);
          _showSuccessMessage('Book updated successfully');
        }
        Navigator.pop(context, true);  // Go back after success
      } catch (error) {
        _showErrorMessage('Failed to save the book');
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book == null ? 'Add Book' : 'Edit Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: title,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) => title = value!,
              ),
              TextFormField(
                initialValue: author,
                decoration: InputDecoration(labelText: 'Author'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an author';
                  }
                  return null;
                },
                onSaved: (value) => author = value!,
              ),
              TextFormField(
                initialValue: publicationDate,
                decoration: InputDecoration(labelText: 'Publication Date (YYYY-MM-DD)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a date';
                  }
                  final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                  if (!regex.hasMatch(value)) {
                    return 'Date must be in YYYY-MM-DD format';
                  }
                  return null;
                },
                onSaved: (value) => publicationDate = value!,
              ),
              TextFormField(
                initialValue: quantity.toString(),
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quantity';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number <= 0) {
                    return 'Quantity must be a positive number';
                  }
                  return null;
                },
                onSaved: (value) => quantity = int.parse(value!),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitForm,
                child: Text(widget.book == null ? 'Add Book' : 'Update Book'),
              ),
            ],
          ),
        ),
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
