import 'package:flutter/material.dart';
import 'movie_model.dart';
import 'movie_service.dart';

class MovieDetailScreen extends StatefulWidget {
  final MovieModel movie;
  final MovieService service;

  const MovieDetailScreen({
    super.key,
    required this.movie,
    required this.service,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Future<MovieDetail> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = widget.service.fetchMovieDetail(widget.movie.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      body: FutureBuilder<MovieDetail>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF01B4E4)),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent, 
                    size: 48
                  ),
                  const SizedBox(height: 12),
                  Text(
                    snapshot.error.toString(),
                    style: const TextStyle(
                      color: Colors.white54, 
                      fontSize: 13
                    )
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        color: Color(0xFF01B4E4)
                      )
                    ),
                  ),
                ],
              ),
            );
          }
          return _DetailBody(detail: snapshot.data!);
        },
      ),
    );
  }
}

// Body utama

class _DetailBody extends StatelessWidget {
  final MovieDetail detail;
  const _DetailBody({required this.detail});

  // Tinggi backdrop
  static const double _backdropHeight = 230.0;
  // Tinggi poster
  static const double _posterHeight = 160.0;
  static const double _posterWidth = 107.0;
  // Berapa banyak poster menimpa backdrop ke atas
  static const double _posterOverlap = 60.0;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Backdrop + Poster overlay
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Backdrop
              SizedBox(
                height: _backdropHeight + topPadding,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    detail.backdropUrl.isNotEmpty
                        ? Image.network(
                            detail.backdropUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(
                                  color: const Color(0xFF1A2535)
                                ),
                          )
                        : Container(
                          color: const Color(0xFF1A2535)
                        ),
                    // Gradient bawah backdrop → konten menyatu
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00000000), Color(0xFF0A0E14),],
                          stops: [0.45, 1.0],
                        ),
                      ),
                    ),
                    // Tombol back
                    Positioned(
                      top: topPadding + 8,
                      left: 12,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Poster yang menimpa backdrop
              Positioned(
                bottom: -_posterOverlap,
                left: 20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: detail.posterUrl.isNotEmpty
                      ? Image.network(
                          detail.posterUrl,
                          width: _posterWidth,
                          height: _posterHeight,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _posterFallback(),
                        )
                      : _posterFallback(),
                ),
              ),
            ],
          ),

          // ── Area judul (di sebelah kanan poster yang menimpa) ─────
          SizedBox(
            height: _posterOverlap + 10,
            child: Padding(
              padding: const EdgeInsets.only(
                left: _posterWidth + 32,
                right: 16
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    detail.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Info metadata (di bawah poster, setelah poster selesai) ─
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating + tahun + durasi dalam satu baris
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  children: [
                    if (detail.ratingFormatted != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFFD700), 
                            size: 16
                          ),
                          const SizedBox(width: 3),
                          Text(
                            detail.ratingFormatted!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            ' / 10',
                            style: TextStyle(
                              color: Colors.white38, 
                              fontSize: 12
                            )
                          ),
                        ],
                      ),
                    _MetaChip(
                      icon: Icons.calendar_today_outlined,
                      label: detail.releaseYear
                    ),
                    _MetaChip(
                      icon: Icons.schedule_rounded,
                      label: detail.runtimeFormatted
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Genre chips
                if (detail.genres.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: detail.genres
                        .take(4)
                        .map((g) => _GenreChip(name: g.name))
                        .toList(),
                  ),

                const SizedBox(height: 20),
                const _Divider(),
                const SizedBox(height: 16),

                // Synopsis
                const _SectionTitle(
                  icon: Icons.article_outlined, 
                  label: 'Synopsis'
                ),
                const SizedBox(height: 8),
                Text(
                  detail.overview?.isNotEmpty == true
                    ? detail.overview!
                    : 'No synopsis available.',
                  style: const TextStyle(
                    color: Color(0xFFCCCCCC),
                    fontSize: 14,
                    height: 1.65,
                  ),
                ),

                // Cast
                if (detail.cast.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const _Divider(),
                  const SizedBox(height: 16),
                  const _SectionTitle(
                    icon: Icons.people_alt_outlined,
                    label: 'Cast'
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 130,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: detail.cast.length,
                      itemBuilder: (context, i) => _CastCard(member: detail.cast[i]),
                    ),
                  ),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _posterFallback() => Container(
    width: _posterWidth,
    height: _posterHeight,
    color: const Color(0xFF1A2535),
    child: const Icon(
      Icons.movie_outlined,
      color: Colors.white24, 
      size: 36
    ),
  );
}

// Widgets kecil

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon, 
          color: Colors.white38, 
          size: 13
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54, 
            fontSize: 12
          )
        ),
      ],
    );
  }
}

class _GenreChip extends StatelessWidget {
  final String name;
  const _GenreChip({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF01B4E4)
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        name,
        style: const TextStyle(
          color: Color(0xFF01B4E4), 
          fontSize: 11
        )
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionTitle({
    required this.icon, 
    required this.label
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon, 
          color: const Color(0xFF01B4E4), 
          size: 18
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          )
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const Divider(
        color: Color(0xFF1A2535), 
        height: 1
      );
}

class _CastCard extends StatelessWidget {
  final CastMember member;
  const _CastCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: member.profileUrl.isNotEmpty
                ? Image.network(
                    member.profileUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _avatarFallback(),
                  )
                : _avatarFallback(),
          ),
          const SizedBox(height: 6),
          Text(
            member.name,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 10, 
              height: 1.3
            ),
          ),
          if (member.character?.isNotEmpty == true) ...[
            const SizedBox(height: 2),
            Text(
              member.character!,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style:const TextStyle(
                color: Colors.white38, 
                fontSize: 9
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _avatarFallback() => Container(
    width: 64,
    height: 64,
    decoration: const BoxDecoration(
      color: Color(0xFF1A2535),
      shape: BoxShape.circle,
    ),
    child: const Icon(
      Icons.person_outline,
      color: Colors.white24, size: 28
    ),
  );
}