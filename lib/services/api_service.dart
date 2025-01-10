import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:library_management_frontend/models/book.dart';


class ApiService {
  final String baseUrl = 'http://localhost:5000';

  // Fetch all books
  Future<List<Book>> fetchBooks() async {
    final response = await http.get(Uri.parse('$baseUrl/books'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((book) => Book.fromJson(book)).toList();
    } else {
      throw Exception('Failed to load books');
    }
  }

  // Search books
  Future<List<Book>> searchBooks(String criteria, String keyword) async {
    final response = await http.get(Uri.parse('$baseUrl/books/search?criteria=$criteria&keyword=$keyword'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((book) => Book.fromJson(book)).toList();
    } else {
      throw Exception('Failed to search books');
    }
  }

  // Add a new book
  Future<Book> addBook(Book book) async {
    final response = await http.post(
      Uri.parse('$baseUrl/books'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(book.toJson()),
    );

    if (response.statusCode == 201) {
      return Book.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add book');
    }
  }

  // Edit book details
  Future<Book> updateBook(String id, Book book) async {
    final response = await http.put(
      Uri.parse('$baseUrl/books/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(book.toJson()),
    );

    if (response.statusCode == 200) {
      return Book.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update book');
    }
  }

   // Delete Book Method
  Future<bool> deleteBook(String bookId) async {
    final url = Uri.parse('$baseUrl/books/$bookId');
    final response = await http.delete(url);

    // Check if the response status is 204 (No Content)
    if (response.statusCode == 204) {
      return true; // Successfully deleted
    } else {
      return false; // Failed to delete
    }
  }
}
