import 'package:flutter/material.dart';

void main() {
  runApp(const AccessPathApp());
}

const Color navy = Color(0xFF142B4A);
const Color teal = Color(0xFF0C9B8A);
const Color paleTeal = Color(0xFFE5F6F2);
const Color pageBg = Color(0xFFF5F7FB);

class AccessPathApp extends StatelessWidget {
  const AccessPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AccessPath',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: pageBg,
        colorScheme: ColorScheme.fromSeed(seedColor: teal),
        appBarTheme: const AppBarTheme(
          backgroundColor: pageBg,
          foregroundColor: navy,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const AccessHome(),
    );
  }
}

class Place {
  final String name;
  final String category;
  final String description;
  final List<String> facilities;
  final int score;
  final IconData icon;

  const Place({
    required this.name,
    required this.category,
    required this.description,
    required this.facilities,
    required this.score,
    required this.icon,
  });
}

class FeedbackEntry {
  final int rating;
  final String comment;

  const FeedbackEntry(this.rating, this.comment);
}

class AccessHome extends StatefulWidget {
  const AccessHome({super.key});

  @override
  State<AccessHome> createState() => _AccessHomeState();
}

class _AccessHomeState extends State<AccessHome> {
  int selectedTab = 0;
  String searchText = '';
  final Set<String> selectedFilters = {};
  final Set<String> savedPlaces = {};
  final Map<String, List<FeedbackEntry>> feedback = {};

  final List<Place> places = const [
    Place(
      name: 'City General Hospital',
      category: 'Healthcare',
      description:
      'A hospital demo listing with several accessibility features.',
      facilities: [
        'Step-free',
        'Lift',
        'Accessible toilet',
        'Seating'
      ],
      score: 92,
      icon: Icons.local_hospital_rounded,
    ),
    Place(
      name: 'Central Public Library',
      category: 'Education',
      description:
      'A public library demo listing for reading and learning.',
      facilities: ['Step-free', 'Seating', 'Wayfinding'],
      score: 84,
      icon: Icons.local_library_rounded,
    ),
    Place(
      name: 'Community Shopping Centre',
      category: 'Shopping',
      description:
      'A shopping centre demo listing with essential facilities.',
      facilities: ['Lift', 'Accessible toilet', 'Seating'],
      score: 76,
      icon: Icons.shopping_bag_rounded,
    ),
    Place(
      name: 'Riverside Public Park',
      category: 'Outdoor',
      description:
      'A park demo listing for outdoor recreation.',
      facilities: ['Step-free', 'Seating', 'Wayfinding'],
      score: 68,
      icon: Icons.park_rounded,
    ),
  ];

  final List<String> filterOptions = const [
    'Step-free',
    'Lift',
    'Accessible toilet',
    'Seating',
    'Wayfinding',
  ];

  List<Place> get visiblePlaces {
    Iterable<Place> result = places;

    if (selectedTab == 2) {
      result = result.where((p) => savedPlaces.contains(p.name));
    }

    if (selectedTab == 1) {
      // Explore starts with all places and offers extra filters.
      result = result;
    }

    if (searchText.trim().isNotEmpty) {
      final query = searchText.toLowerCase().trim();
      result = result.where((p) =>
      p.name.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query) ||
          p.facilities.any((f) => f.toLowerCase().contains(query)));
    }

    if (selectedFilters.isNotEmpty) {
      result = result.where((p) =>
          selectedFilters.every((filter) => p.facilities.contains(filter)));
    }

    return result.toList();
  }

  void toggleSaved(Place place) {
    setState(() {
      if (savedPlaces.contains(place.name)) {
        savedPlaces.remove(place.name);
      } else {
        savedPlaces.add(place.name);
      }
    });
  }

  void openFeedback(Place place) {
    int rating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, refreshDialog) => AlertDialog(
          title: const Text('Share your experience'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(place.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('Your rating'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: List.generate(
                    5,
                        (index) => IconButton(
                      tooltip: '${index + 1} stars',
                      onPressed: () =>
                          refreshDialog(() => rating = index + 1),
                      icon: Icon(
                        index < rating ? Icons.star_rounded : Icons.star_border,
                        color: Colors.amber.shade700,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  maxLength: 250,
                  decoration: const InputDecoration(
                    hintText: 'What should other visitors know?',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  feedback.putIfAbsent(place.name, () => []);
                  feedback[place.name]!.add(
                    FeedbackEntry(rating, commentController.text.trim()),
                  );
                });
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text('Thank you for sharing your feedback!'),
                  ),
                );
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void openPlace(Place place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CircleAvatar(
                radius: 30,
                backgroundColor: paleTeal,
                child: Icon(place.icon, color: teal, size: 30),
              ),
              const SizedBox(height: 16),
              Text(place.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  )),
              const SizedBox(height: 5),
              Text(place.category,
                  style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 14),
              Text(place.description),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Icon(Icons.accessible_forward, color: teal),
                  const SizedBox(width: 8),
                  Text(
                    'Accessibility score: ${place.score}/100',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: place.score / 100,
                  minHeight: 9,
                  backgroundColor: paleTeal,
                  color: teal,
                ),
              ),
              const SizedBox(height: 22),
              const Text('Listed facilities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(height: 10),
              ...place.facilities.map(
                    (facility) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: teal, size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Text(facility)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Demo information — facilities have not been independently verified.',
                style: TextStyle(fontSize: 12, color: Colors.deepOrange),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        toggleSaved(place);
                      },
                      icon: Icon(savedPlaces.contains(place.name)
                          ? Icons.favorite
                          : Icons.favorite_border),
                      label: Text(savedPlaces.contains(place.name)
                          ? 'Saved'
                          : 'Save place'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        openFeedback(place);
                      },
                      icon: const Icon(Icons.rate_review_outlined),
                      label: const Text('Give feedback'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Community feedback (${feedback[place.name]?.length ?? 0})',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if ((feedback[place.name] ?? []).isEmpty)
                const Text('No feedback yet. Be the first to share.')
              else
                ...feedback[place.name]!.reversed.map(
                      (entry) => Card(
                    color: pageBg,
                    child: ListTile(
                      leading: const Icon(Icons.person_outline, color: teal),
                      title: Text('${entry.rating}/5 stars'),
                      subtitle: Text(entry.comment.isEmpty
                          ? 'No written comment'
                          : entry.comment),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Discover', 'Explore places', 'Saved places', 'Your profile'];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: teal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.accessible_forward,
                  color: Colors.white, size: 25),
            ),
            const SizedBox(width: 10),
            const Text(
              'AccessPath',
              style: TextStyle(fontWeight: FontWeight.w800, color: navy),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () => setState(() => selectedTab = 3),
            icon: const Icon(Icons.account_circle_outlined, size: 28),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: selectedTab == 3
          ? buildProfile()
          : selectedTab == 0 || selectedTab == 1
          ? buildPlacesPage(titles[selectedTab])
          : buildSavedPage(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (index) {
          setState(() {
            selectedTab = index;
            if (index == 0) {
              selectedFilters.clear();
              searchText = '';
            }
          });
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Explore'),
          NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'Saved'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
    );
  }

  Widget buildPlacesPage(String title) {
    final shown = visiblePlaces;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [navy, Color(0xFF245477)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'ACCESSIBILITY FOR EVERYONE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Explore places.\nMove with confidence.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  height: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Find accessibility details and share your experience.',
                style: TextStyle(color: Colors.white70, height: 1.4),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.place_outlined,
                      color: Color(0xFF83E5D5)),
                  const SizedBox(width: 7),
                  Text(
                    '${places.length} demo places to explore',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(title,
            style: const TextStyle(
                fontSize: 23, fontWeight: FontWeight.bold, color: navy)),
        const SizedBox(height: 12),
        TextField(
          onChanged: (value) => setState(() => searchText = value),
          decoration: InputDecoration(
            hintText: 'Search places or facilities...',
            prefixIcon: const Icon(Icons.search, color: teal),
            suffixIcon: searchText.isEmpty
                ? null
                : IconButton(
              onPressed: () => setState(() => searchText = ''),
              icon: const Icon(Icons.close),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Accessibility needs',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filterOptions.map((filter) {
            final selected = selectedFilters.contains(filter);
            return FilterChip(
              label: Text(filter),
              selected: selected,
              showCheckmark: true,
              selectedColor: paleTeal,
              checkmarkColor: teal,
              side: BorderSide(
                  color: selected ? teal : Colors.black12),
              onSelected: (value) {
                setState(() {
                  if (value) {
                    selectedFilters.add(filter);
                  } else {
                    selectedFilters.remove(filter);
                  }
                });
              },
            );
          }).toList(),
        ),
        if (selectedFilters.isNotEmpty) ...[
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => setState(() => selectedFilters.clear()),
              icon: const Icon(Icons.refresh),
              label: const Text('Clear filters'),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Places for you',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            Text('${shown.length} found',
                style: const TextStyle(color: Colors.black54)),
          ],
        ),
        const SizedBox(height: 12),
        if (shown.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              children: [
                Icon(Icons.search_off, size: 42, color: teal),
                SizedBox(height: 10),
                Text('No places found',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Try another search or remove a filter.'),
              ],
            ),
          )
        else
          ...shown.map(buildPlaceCard),
        const SizedBox(height: 12),
        const Text(
          'Important: These are sample listings for demonstration only. '
              'Do not rely on them for real-world accessibility decisions.',
          style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.5),
        ),
      ],
    );
  }

  Widget buildPlaceCard(Place place) {
    final isSaved = savedPlaces.contains(place.name);
    final reviewList = feedback[place.name] ?? [];
    final average = reviewList.isEmpty
        ? null
        : reviewList.map((entry) => entry.rating).reduce((a, b) => a + b) /
        reviewList.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE9EDF3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openPlace(place),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: paleTeal,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(place.icon, color: teal, size: 29),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(place.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: navy,
                            )),
                        const SizedBox(height: 4),
                        Text(place.category,
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 13)),
                        if (average != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: Colors.amber, size: 17),
                                Text(
                                  ' ${average.toStringAsFixed(1)} community rating',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: isSaved ? 'Remove saved place' : 'Save place',
                    onPressed: () => toggleSaved(place),
                    icon: Icon(
                      isSaved ? Icons.favorite : Icons.favorite_border,
                      color: isSaved ? Colors.pink : Colors.black45,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.accessible, color: teal, size: 19),
                  const SizedBox(width: 7),
                  const Expanded(
                    child: Text('Accessibility score',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  Text('${place.score}/100',
                      style: const TextStyle(
                          color: teal, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: place.score / 100,
                  minHeight: 7,
                  backgroundColor: paleTeal,
                  color: teal,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: place.facilities.take(3).map((facility) {
                  return Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                    decoration: BoxDecoration(
                      color: pageBg,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(facility,
                        style: const TextStyle(fontSize: 11)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('View details',
                      style: TextStyle(
                          color: teal, fontWeight: FontWeight.bold)),
                  SizedBox(width: 5),
                  Icon(Icons.arrow_forward, color: teal, size: 17),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSavedPage() {
    final saved = visiblePlaces;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text('Your saved places',
            style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.bold, color: navy)),
        const SizedBox(height: 8),
        const Text('Keep your favourite places close at hand.'),
        const SizedBox(height: 20),
        if (saved.isEmpty)
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              children: [
                Icon(Icons.favorite_border, size: 52, color: teal),
                SizedBox(height: 12),
                Text('No saved places yet',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text('Tap the heart on a place to save it here.',
                    textAlign: TextAlign.center),
              ],
            ),
          )
        else
          ...saved.map(buildPlaceCard),
      ],
    );
  }

  Widget buildProfile() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 14),
        const CircleAvatar(
          radius: 42,
          backgroundColor: paleTeal,
          child: Icon(Icons.person, color: teal, size: 48),
        ),
        const SizedBox(height: 14),
        const Text(
          'Your AccessPath',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: navy),
        ),
        const SizedBox(height: 6),
        const Text(
          'Accessibility starts with better information.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 28),
        profileTile(
          Icons.favorite_outline,
          'Saved places',
          '${savedPlaces.length} places saved',
              () => setState(() => selectedTab = 2),
        ),
        profileTile(
          Icons.rate_review_outlined,
          'Your feedback',
          '${feedback.values.fold<int>(0, (sum, entries) => sum + entries.length)} reviews submitted this session',
              () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Your feedback'),
                content: Text(
                  feedback.values.expand((entries) => entries).isEmpty
                      ? 'You have not submitted feedback yet.'
                      : feedback.entries
                      .expand((entry) => entry.value.map(
                        (review) =>
                    '${entry.key}\n${review.rating}/5 stars\n${review.comment.isEmpty ? "No comment" : review.comment}',
                  ))
                      .join('\n\n'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
        profileTile(
          Icons.tune,
          'Accessibility filters',
          'Choose facilities that matter to you',
              () => setState(() => selectedTab = 1),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Text(
            'AccessPath demo version\n\n'
                'Place details and scores are sample data. '
                'Reviews are stored only in memory and will reset when the app restarts.',
            style: TextStyle(height: 1.5, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget profileTile(
      IconData icon,
      String title,
      String subtitle,
      VoidCallback onTap,
      ) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: paleTeal,
          child: Icon(icon, color: teal),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}