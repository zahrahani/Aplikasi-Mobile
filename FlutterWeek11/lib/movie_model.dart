class MovieModel {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final double? voteAverage;
  final int? voteCount;
  final String? releaseDate;
  final List<int>? genreIds;
  final String? originalLanguage;

  MovieModel({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage,
    this.voteCount,
    this.releaseDate,
    this.genreIds,
    this.originalLanguage,
  });

  String get posterUrl => posterPath != null
      ? 'https://image.tmdb.org/t/p/w342$posterPath'
      : '';

  String get backdropUrl => backdropPath != null
      ? 'https://image.tmdb.org/t/p/w780$backdropPath'
      : '';

  String get releaseYear =>
      (releaseDate != null && releaseDate!.length >= 4)
          ? releaseDate!.substring(0, 4)
          : '-';

  // Null kalau belum ada vote, supaya tidak tampil 0.0
  String? get ratingFormatted {
    if (voteAverage == null) return null;
    if (voteAverage! <= 0 || (voteCount ?? 0) < 5) return null;
    return voteAverage!.toStringAsFixed(1);
  }

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Unknown Title',
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      voteCount: json['vote_count'] as int?,
      releaseDate: json['release_date'] as String?,
      genreIds: (json['genre_ids'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      originalLanguage: json['original_language'] as String?,
    );
  }
}

// Model untuk detail film (dari endpoint /movie/{id})

class MovieDetail {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final double? voteAverage;
  final int? voteCount;
  final String? releaseDate;
  final int? runtime;
  final List<Genre> genres;
  final List<CastMember> cast;

  MovieDetail({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage,
    this.voteCount,
    this.releaseDate,
    this.runtime,
    this.genres = const [],
    this.cast = const [],
  });

  String get posterUrl => posterPath != null
      ? 'https://image.tmdb.org/t/p/w342$posterPath'
      : '';

  String get backdropUrl => backdropPath != null
      ? 'https://image.tmdb.org/t/p/w780$backdropPath'
      : '';

  String get releaseYear =>
      (releaseDate != null && releaseDate!.length >= 4)
          ? releaseDate!.substring(0, 4)
          : '-';

  String? get ratingFormatted {
    if (voteAverage == null) return null;
    if (voteAverage! <= 0 || (voteCount ?? 0) < 5) return null;
    return voteAverage!.toStringAsFixed(1);
  }

  String get runtimeFormatted {
    if (runtime == null || runtime! <= 0) return '-';
    final h = runtime! ~/ 60;
    final m = runtime! % 60;
    if (h == 0) return '${m}m';
    return '${h}j ${m}m';
  }

  factory MovieDetail.fromJson(Map<String, dynamic> json,
      {List<CastMember> cast = const []}) {
    final genreList = (json['genres'] as List<dynamic>?)
            ?.map((g) => Genre.fromJson(g))
            .toList() ??
        [];
    return MovieDetail(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Unknown',
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      voteCount: json['vote_count'] as int?,
      releaseDate: json['release_date'] as String?,
      runtime: json['runtime'] as int?,
      genres: genreList,
      cast: cast,
    );
  }
}

class Genre {
  final int id;
  final String name;
  Genre({required this.id, required this.name});
  factory Genre.fromJson(Map<String, dynamic> json) =>
      Genre(id: json['id'] as int, name: json['name'] as String? ?? '');
}

class CastMember {
  final int id;
  final String name;
  final String? character;
  final String? profilePath;

  CastMember({
    required this.id,
    required this.name,
    this.character,
    this.profilePath,
  });

  String get profileUrl => profilePath != null
      ? 'https://image.tmdb.org/t/p/w185$profilePath'
      : '';

  factory CastMember.fromJson(Map<String, dynamic> json) => CastMember(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        character: json['character'] as String?,
        profilePath: json['profile_path'] as String?,
      );
}