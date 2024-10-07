import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AnimeSearch extends StatefulWidget {
  const AnimeSearch({super.key});

  @override
  State<AnimeSearch> createState() => _AnimeSearchState();
}

class _AnimeSearchState extends State<AnimeSearch> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  Future<void> _searchAnime(String query) async {
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    final response =
        await http.get(Uri.parse('https://api.jikan.moe/v4/anime?q=$query'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        _results = data['data'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load anime');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anime Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Search for an anime',
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: _searchAnime,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty && _hasSearched
                    ? const Center(child: Text('No results found'))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final anime = _results[index];
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(4.0),
                                child: SizedBox(
                                  width: 50,
                                  height: 100, // Set a custom height
                                  child: Hero(
                                    tag: anime['images']['jpg']['image_url'],
                                    child: Image.network(
                                      anime['images']['jpg']['image_url'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(anime['title']),
                              subtitle: Container(
                                constraints:
                                    const BoxConstraints(maxHeight: 50),
                                child: Text(
                                  anime['synopsis'] ?? 'No synopsis available',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AnimeDetail(anime: anime),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}

class AnimeDetail extends StatelessWidget {
  final dynamic anime;

  const AnimeDetail({super.key, required this.anime});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(anime['title']),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: anime['images']['jpg']['image_url'],
              child: Image.network(
                anime['images']['jpg']['image_url'],
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              anime['title'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(anime['synopsis'] ?? 'No synopsis available'),
          ],
        ),
      ),
    );
  }
}
