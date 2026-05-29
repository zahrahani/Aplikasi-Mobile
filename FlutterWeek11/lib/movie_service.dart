import 'dart:convert';
import 'package:http/http.dart' as http;
import 'movie_model.dart';

class MovieService {
  static const String _apiKey = 'a9c5ceacdc57567c7ced4220a142d591';   // API Key TMDB
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<List<MovieModel>> _fetchList(String endpoint) async {
    final uri = Uri.parse(
        '$_baseUrl$endpoint?api_key=$_apiKey&language=en-US&page=1');
    final res = await http.get(
      uri, 
      headers: _headers
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Request timeout.'), 
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map((j) => MovieModel.fromJson(j)).toList();
    } else if (res.statusCode == 401) {
      throw Exception('Invalid API Key.');
    } else {
      throw Exception('Error ${res.statusCode}');
    }
  }

  Future<List<MovieModel>> fetchPopularMovies() => _fetchList('/movie/popular');

  Future<List<MovieModel>> fetchTrendingToday() async {
    final uri = Uri.parse(
        '$_baseUrl/trending/movie/day?api_key=$_apiKey&language=en-US');
    final res = await http.get(
      uri, 
      headers: _headers
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Request timeout.'),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return (data['results'] as List<dynamic>)
          .map((j) => MovieModel.fromJson(j))
          .toList();
    }
    throw Exception('Error ${res.statusCode}');
  }

  Future<List<MovieModel>> fetchTopRated() => _fetchList('/movie/top_rated');
  Future<List<MovieModel>> fetchUpcoming() => _fetchList('/movie/upcoming');
  Future<List<MovieModel>> fetchNowPlaying() => _fetchList('/movie/now_playing');

  /// Detail film lengkap: info + cast sekaligus (append_to_response)
  Future<MovieDetail> fetchMovieDetail(int movieId) async {
    final uri = Uri.parse('$_baseUrl/movie/$movieId?api_key=$_apiKey&language=en-US&append_to_response=credits');
    final res = await http.get(
      uri, 
      headers: _headers
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Request timeout.'),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final castJson =
          (data['credits']?['cast'] as List<dynamic>?) ?? [];
      final cast = castJson
          .take(15) // ambil 15 cast teratas
          .map((j) => CastMember.fromJson(j))
          .toList();
      return MovieDetail.fromJson(data, cast: cast);
    } else if (res.statusCode == 401) {
      throw Exception('Invalid API Key.');
    } else {
      throw Exception('Error ${res.statusCode}');
    }
  }

  Future<List<MovieModel>> searchMovies(String query) async {
    if (query.trim().isEmpty) return [];
    final uri = Uri.parse('$_baseUrl/search/movie?api_key=$_apiKey&language=en-US&query=${Uri.encodeComponent(query)}&page=1');
    final res = await http.get(
      uri, 
      headers: _headers
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Request timeout.'),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return (data['results'] as List<dynamic>)
          .map((j) => MovieModel.fromJson(j))
          .toList();
    }
    throw Exception('Unable to find the movie.');
  }
}