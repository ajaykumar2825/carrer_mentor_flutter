import 'package:flutter/material.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  final List<Map<String, dynamic>> recommendations = const [
    {
      'title': 'Build a Portfolio Website',
      'steps': [
        'Learn semantic HTML and responsive CSS',
        'Use GitHub Pages or Netlify for hosting',
        'Add project cards with links and screenshots',
      ],
      'resources': ['freecodecamp.org', 'frontendmentor.io'],
      'validation': 'Live website + GitHub repo',
    },
    {
      'title': 'Create a Recommender System',
      'steps': [
        'Understand collaborative filtering',
        'Use pandas and scikit-learn',
        'Deploy with Streamlit',
      ],
      'resources': ['kaggle.com', 'streamlit.io'],
      'validation': 'Working app + README + demo video',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📌 Recommendations')),
      body: ListView.builder(
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          final rec = recommendations[index];
          return Card(
            margin: const EdgeInsets.all(12),
            child: ExpansionTile(
              title: Text(rec['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
              children: [
                ListTile(
                  title: const Text('Steps'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      rec['steps'].length,
                      (i) => Text('• ${rec['steps'][i]}'),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('Resources'),
                  subtitle: Text(rec['resources'].join(', ')),
                ),
                ListTile(
                  title: const Text('Validation Criteria'),
                  subtitle: Text(rec['validation']),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}