import 'package:flutter/material.dart';
import 'movie_model.dart';
import 'movie_service.dart';
import 'movie_detail_screen.dart';

// Warna tema
const _bg       = Color(0xFF070B14);
const _surface  = Color(0xFF0D1526);
const _accent   = Color(0xFF01B4E4);
const _card     = Color(0xFF1A2535);

class _Section {
  final String title;
  final IconData icon;
  final Color color;
  final Future<List<MovieModel>> future;
  _Section(this.title, this.icon, this.color, this.future);
}

// Halaman utama
class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});
  @override
  State<MovieListScreen> createState() => _State();
}

class _State extends State<MovieListScreen> {
  final _svc    = MovieService();
  final _search = TextEditingController();
  Future<List<MovieModel>>? _searchFuture;
  bool _isSearching = false;

  List<_Section> get _sections => [
    _Section(
      'Trending Today', 
      Icons.local_fire_department_rounded, 
      const Color(0xFFFF6B35), 
      _svc.fetchTrendingToday()
    ),
    _Section(
      'Now Playing',
      Icons.play_circle_fill_rounded,
      _accent,
      _svc.fetchNowPlaying()
    ),
    _Section(
      'Most Popular',
      Icons.trending_up_rounded,
      const Color(0xFF90CEA1),
      _svc.fetchPopularMovies()
    ),
    _Section(
      'Top Rated',
      Icons.military_tech_rounded,
      const Color(0xFFFFD700), 
      _svc.fetchTopRated()
    ),
    _Section(
      'Upcoming',
      Icons.event_rounded,
      const Color(0xFFB39DDB), 
      _svc.fetchUpcoming()
    ),
  ];

  @override
  void dispose() { 
    _search.dispose(); 
    super.dispose(); 
  }

  void _doSearch(String q) {
    if (
      q.trim().isEmpty
    ) return;
    setState(() { 
      _isSearching = true; 
      _searchFuture = _svc.searchMovies(q); 
    });
  }

  void _clearSearch() {
    _search.clear();
    setState(() { 
      _isSearching = false; 
      _searchFuture = null; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient latar: biru dongker di atas memudar ke hitam
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_surface, _bg],
            stops: [0.0, 0.35],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isSearching && _searchFuture != null
                ? _SearchGrid(future: _searchFuture!, svc: _svc)
                : _Home(sections: _sections, svc: _svc)
            ),
          ]
        )
      ),
    );
  }

  Widget _buildHeader() => Container(
    color: Colors.transparent,
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
    child: Column(children: [
      // Logo
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8, 
              vertical: 4
            ),
            decoration: BoxDecoration(
              color: _accent, 
              borderRadius: BorderRadius.circular(4)
            ),
            child: const Text(
              'MOVIE', 
              style: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.w900, 
                fontSize: 14, 
                letterSpacing: 2
              )
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'DB', 
            style: TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.w900, 
              fontSize: 18
            )
          ),
        ]
      ),
      const SizedBox(height: 10),
      // Search bar
      Container(
        height: 40,
        decoration: BoxDecoration(
          color: _card, 
          borderRadius: BorderRadius.circular(20)
        ),
        child: TextField(
          controller: _search,
          style: const TextStyle(
            color: Colors.white, 
            fontSize: 13
          ),
          decoration: InputDecoration(
            hintText: 'Search movies...',
            hintStyle: const TextStyle(
              color: Colors.white38, 
              fontSize: 13
            ),
            prefixIcon: const Icon(
              Icons.search, 
              color: Colors.white38, 
              size: 18
            ),
            suffixIcon: _isSearching
                ? GestureDetector(onTap: _clearSearch,
                    child: const Icon(
                      Icons.close, 
                      color: Colors.white38, 
                      size: 18
                    )
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10
            ),
          ),
          onSubmitted: _doSearch,
          textInputAction: TextInputAction.search,
        ),
      ),
    ]),
  );
}

// Home
class _Home extends StatelessWidget {
  final List<_Section> sections;
  final MovieService svc;
  const _Home({required this.sections, required this.svc});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.only(
      top: 8, 
      bottom: 24
    ),
    children: sections.map((s) => _SectionRow(s, svc)).toList(),
  );
}

class _SectionRow extends StatefulWidget {
  final _Section section;
  final MovieService svc;
  const _SectionRow(this.section, this.svc, {super.key});
  @override
  State<_SectionRow> createState() => _SectionRowState();
}

class _SectionRowState extends State<_SectionRow> {
  late Future<List<MovieModel>> _future;

  @override
  void initState() { super.initState(); _future = widget.section.future; }

  @override
  void didUpdateWidget(_SectionRow old) {
    super.didUpdateWidget(old);
    if (old.section.future != widget.section.future)
      setState(() => _future = widget.section.future);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
        child: Row(
          children: [
            Icon(
              widget.section.icon, 
              color: widget.section.color, 
              size: 18
            ),
            const SizedBox(width: 7),
            Text(
              widget.section.title,
              style: const TextStyle(
              color: Colors.white, 
              fontSize: 15, 
              fontWeight: FontWeight.w700
              )
            ),
          ]
        ),
      ),
      FutureBuilder<List<MovieModel>>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) return _shimmer();
          if (snap.hasError) return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Failed: ${snap.error}',
              style: const TextStyle(
                color: Colors.redAccent, 
                fontSize: 11
              )
            ),
          );
          return SizedBox(
            height: 210,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: snap.data!.length,
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _PosterCard(
                  snap.data![i], 
                  widget.svc
                ),
              ),
            ),
          );
        },
      ),
    ],
  );

  Widget _shimmer() => SizedBox(
    height: 210,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: 7,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          width: 110,
          decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ),
  );
}

// Search Grid
class _SearchGrid extends StatelessWidget {
  final Future<List<MovieModel>> future;
  final MovieService svc;
  const _SearchGrid({required this.future, required this.svc});

  @override
  Widget build(BuildContext context) => FutureBuilder<List<MovieModel>>(
    future: future,
    builder: (ctx, snap) {
      if (snap.connectionState == ConnectionState.waiting)
        return const Center(
          child: CircularProgressIndicator(
            color: _accent
          )
        );
      if (snap.hasError)
        return Center(
          child: Text(
            '${snap.error}',
            style: const TextStyle(
              color: Colors.white54
            )
          )
        );
      if (snap.data!.isEmpty)
        return const Center(
          child: Text(
            'No results found.',
            style: TextStyle(
              color: Colors.white38
            )
          )
        );
      // Pakai LayoutBuilder supaya aspect ratio selalu pas di semua lebar layar
      return LayoutBuilder(builder: (ctx, constraints) {
        const spacing = 6.0;
        const padding = 8.0;
        // Hitung lebar cell sesuai layar (minimal 3 kolom)
        final cols  = (constraints.maxWidth / 120).floor().clamp(3, 10);
        final cellW = (constraints.maxWidth - padding * 2 - spacing * (cols - 1)) / cols;
        // Tinggi = poster (cellW * 1.4) + teks (~60px)
        final cellH = cellW * 1.4 + 60;
        return GridView.builder(
          padding: const EdgeInsets.all(padding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: cellW / cellH,
          ),
          itemCount: snap.data!.length,
          itemBuilder: (ctx, i) => _PosterCard(
            snap.data![i], 
            svc, 
            cellWidth: cellW
          ),
        );
      });
    },
  );
}

// Poster Card
class _PosterCard extends StatelessWidget {
  final MovieModel movie;
  final MovieService svc;
  final double? cellWidth; // null = fixed 110 (untuk horizontal list)
  const _PosterCard(this.movie, this.svc, {this.cellWidth});

  @override
  Widget build(BuildContext context) {
    final w = cellWidth ?? 110.0;
    final posterH = w * 1.4;

    return GestureDetector(
      onTap: () => Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (_) => MovieDetailScreen(movie: movie, service: svc),
        )),
        child: SizedBox(
          width: cellWidth == null ? w : null, // di grid, lebar dikontrol GridView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(children: [
                  movie.posterUrl.isNotEmpty
                      ? Image.network(
                        movie.posterUrl,
                        width: w, 
                        height: posterH, 
                        fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(w, posterH),
                          loadingBuilder: (_, child, p) => p == null ? child : _placeholder(w, posterH, loading: true))
                      : _placeholder(w, posterH),
                  // Rating badge
                  if (movie.ratingFormatted != null)
                    Positioned(
                      bottom: 0, 
                      left: 0, 
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter, 
                            end: Alignment.topCenter,
                            colors: [Color(0xEE000000), Colors.transparent],
                          ),
                        ),
                        child: Row(children: [
                          const Icon(
                            Icons.star_rounded, 
                            color: Color(0xFFFFD700), 
                            size: 11
                          ),
                          const SizedBox(width: 2),
                          Text(
                            movie.ratingFormatted!,
                            style: const TextStyle(
                              color: Colors.white, 
                              fontSize: 10, 
                              fontWeight: FontWeight.bold
                            )
                          ),
                        ]),
                      ),
                    ),
                ]),
              ),
              const SizedBox(height: 5),
            Text(
              movie.title, 
              maxLines: 2, 
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 11, 
                height: 1.3, 
                fontWeight: FontWeight.w500
              )
            ),
            const SizedBox(height: 2),
            Text(
              movie.releaseYear,
              style: const TextStyle(
                color: _accent, 
                fontSize: 10
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(double w, double h, {bool loading = false}) => Container(
    width: w, 
    height: h, 
    color: _card,
    child: Center(
      child: loading
      ? const SizedBox(
        width: 16, 
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 1.5, 
          color: _accent
        )
      )
      : const Icon(
        Icons.image_not_supported_outlined, 
        color: Colors.white24, 
        size: 30
      )
    ),
  );
}