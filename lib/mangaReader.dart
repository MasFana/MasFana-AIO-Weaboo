import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MangaHome {
  final String title;
  final String image;
  final String link;
  MangaHome({required this.title, required this.image, required this.link});

  factory MangaHome.fromJson(Map<String, dynamic> json) {
    return MangaHome(
      title: json['title'],
      image: json['image'],
      link: json['link'],
    );
  }
}

class MangaChapter {
  final String chapter;
  final String link;
  MangaChapter({required this.chapter, required this.link});

  factory MangaChapter.fromJson(Map<String, dynamic> json) {
    return MangaChapter(
      chapter: json['chapter'],
      link: json['link'],
    );
  }
}

class MangaReader {
  final String image;
  MangaReader({required this.image});
  factory MangaReader.fromJson(Map<String, dynamic> json) {
    return MangaReader(
      image: json['image'],
    );
  }
}

class MangaHomePage extends StatefulWidget {
  const MangaHomePage({super.key});

  @override
  State<MangaHomePage> createState() => _MangaHomePageState();
}

Future<List<MangaHome>> fetchMangaHome() async {
  final response =
      await http.get(Uri.parse('https://mangapi.masfana.my.id/api/home'));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((manga) => MangaHome.fromJson(manga)).toList();
  } else {
    throw Exception('Failed to load manga');
  }
}

class _MangaHomePageState extends State<MangaHomePage> {
  late Future<List<MangaHome>> futureMangaHome;

  @override
  void initState() {
    super.initState();
    futureMangaHome = fetchMangaHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manga Reader'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchMangaPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<MangaHome>>(
        future: futureMangaHome,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No manga found'));
          } else {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final manga = snapshot.data![index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MangaChapterPage(manga: manga),
                      ),
                    );
                  },
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Hero(
                                tag: manga.image,
                                child: Image.network(
                                  manga.image,
                                  height: double.infinity,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  color: Colors.black54,
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    manga.title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class SearchMangaPage extends StatefulWidget {
  const SearchMangaPage({super.key});

  Future<List<MangaHome>> fetchMangaSearch(name) async {
    if (name == null) {
      return [];
    }
    final response =
        await http.post(Uri.parse('https://mangapi.masfana.my.id/api/search'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({'name': name}));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((manga) => MangaHome.fromJson(manga)).toList();
    } else {
      throw Exception('Failed to load manga');
    }
  }

  @override
  State<SearchMangaPage> createState() => _MangaSearchPageState();
}

class _MangaSearchPageState extends State<SearchMangaPage> {
  late Future<List<MangaHome>> futureMangaHome;

  @override
  void initState() {
    super.initState();
    futureMangaHome = widget.fetchMangaSearch(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0, // Remove extra padding for better alignment
        title: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search Manga',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor:
                      Colors.white.withOpacity(0.1), // To match AppBar color
                  contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                ),
                onSubmitted: (query) {
                  setState(() {
                    // Call the search function and update the future
                    futureMangaHome = widget.fetchMangaSearch(query);
                  });
                },
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                futureMangaHome = widget.fetchMangaSearch(null);
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<MangaHome>>(
        future: futureMangaHome,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No manga found'));
          } else {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final manga = snapshot.data![index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MangaChapterPage(manga: manga),
                      ),
                    );
                  },
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Hero(
                                tag: manga.image,
                                child: Image.network(
                                  manga.image,
                                  height: double.infinity,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  color: Colors.black54,
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    manga.title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class MangaChapterPage extends StatefulWidget {
  final MangaHome manga;

  const MangaChapterPage({super.key, required this.manga});
  Future<List<MangaChapter>> fetchMangaChapter() async {
    final response =
        await http.post(Uri.parse("https://mangapi.masfana.my.id/api/chapters"),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({'linkManga': manga.link}));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((manga) => MangaChapter.fromJson(manga)).toList();
    } else {
      throw Exception('Failed to load chapters');
    }
  }

  @override
  State<MangaChapterPage> createState() => _MangaChapterPageState();
}

class _MangaChapterPageState extends State<MangaChapterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.manga.title),
      ),
      body: Center(
          child: Column(
        children: [
          Hero(
            tag: widget.manga.image,
            child: Image.network(
              widget.manga.image,
              height: 285,
              width: double.infinity,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          const SizedBox(height: 10),
          FutureBuilder<List<MangaChapter>>(
            future: widget.fetchMangaChapter(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No chapter found'));
              } else {
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final chapter = snapshot.data![index];
                      return ListTile(
                        title: Text(
                            chapter.chapter.split(" ").sublist(0, 2).join(" ")),
                        subtitle: Text(
                            chapter.chapter.split(" ").sublist(2).join(" ")),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MangaReaderPage(
                                manga: widget.manga,
                                chapter: chapter,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      )),
    );
  }
}

class MangaReaderPage extends StatefulWidget {
  final MangaChapter chapter;
  final MangaHome manga;
  const MangaReaderPage(
      {super.key, required this.manga, required this.chapter});
  Future<List<MangaReader>> fetchMangaReader() async {
    final response =
        await http.post(Uri.parse("https://mangapi.masfana.my.id/api/images"),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({'linkChapter': chapter.link}));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((manga) => MangaReader.fromJson(manga)).toList();
    } else {
      throw Exception('Failed to load images');
    }
  }

  @override
  State<MangaReaderPage> createState() => _MangaReaderPageState();
}

class _MangaReaderPageState extends State<MangaReaderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              floating: true,
              title: Text(
                "${widget.chapter.chapter.split(" ").sublist(0, 2).join(" ")} - ${widget.manga.title}",
              ),
            ),
          ];
        },
        body: Center(
          child: FutureBuilder(
            future: widget.fetchMangaReader(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No image found'));
              } else {
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final manga = snapshot.data![index];
                    return Image.network(
                      manga.image,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
