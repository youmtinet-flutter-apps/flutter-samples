import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_samples/search_appbar/api/weather_api.dart';
import 'package:flutter_samples/search_appbar/model/weather.dart';

import '../main.dart';

class NetworkSearchAppBarPage extends StatelessWidget {
  const NetworkSearchAppBarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(MyApp.title),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () async {
                showSearch(context: context, delegate: CitySearch());

                // final results = await
                //     showSearch(context: context, delegate: CitySearch());

                // print('Result: $results');
              },
            )
          ],
          backgroundColor: Colors.purple,
        ),
        body: Container(
          color: Colors.black,
          child: const Center(
            child: Text(
              'Network Weather Search',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 64,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
}

class CitySearch extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (query.isEmpty) {
              close(context, 'null');
            } else {
              query = '';
              showSuggestions(context);
            }
          },
        )
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, 'null'),
      );

  @override
  Widget buildResults(BuildContext context) => FutureBuilder<Weather>(
        future: WeatherApi.getWeather(city: query),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            default:
              if (snapshot.hasError) {
                return Container(
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: const Text(
                    'Something went wrong!',
                    style: TextStyle(fontSize: 28, color: Colors.white),
                  ),
                );
              } else {
                var data = snapshot.data;
                if (data is Weather) {
                  return buildResultSuccess(data);
                } else {
                  return const CupertinoActivityIndicator();
                }
              }
          }
        },
      );

  @override
  Widget buildSuggestions(BuildContext context) => Container(
        color: Colors.black,
        child: FutureBuilder<List<String>>(
          future: WeatherApi.searchCities(query: query),
          builder: (context, snapshot) {
            if (query.isEmpty) return buildNoSuggestions();

            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Center(child: CircularProgressIndicator());
              default:
                if (snapshot.hasError || snapshot.data!.isEmpty) {
                  return buildNoSuggestions();
                } else {
                  var data = snapshot.data;
                  if (data is List<String>) {
                    return buildSuggestionsSuccess(data);
                  } else {
                    return const CupertinoActivityIndicator();
                  }
                }
            }
          },
        ),
      );

  Widget buildNoSuggestions() => const Center(
        child: Text(
          'No suggestions!',
          style: TextStyle(fontSize: 28, color: Colors.white),
        ),
      );

  Widget buildSuggestionsSuccess(List<String> suggestions) => ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          final queryText = suggestion.substring(0, query.length);
          final remainingText = suggestion.substring(query.length);

          return ListTile(
            onTap: () {
              query = suggestion;

              // 1. Show Results
              showResults(context);

              // 2. Close Search & Return Result
              // close(context, suggestion);

              // 3. Navigate to Result Page
              //  Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (BuildContext context) => ResultPage(suggestion),
              //   ),
              // );
            },
            leading: const Icon(Icons.location_city),
            // title: Text(suggestion),
            title: RichText(
              text: TextSpan(
                text: queryText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                children: [
                  TextSpan(
                    text: remainingText,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

  Widget buildResultSuccess(Weather weather) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3279e2), Colors.purple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(64),
          children: [
            Text(
              weather.city,
              style: const TextStyle(
                fontSize: 32,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            Icon(
              weather.icon,
              color: Colors.white,
              size: 140,
            ),
            const SizedBox(height: 72),
            Text(
              weather.description,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            buildDegrees(weather),
          ],
        ),
      );

  Widget buildDegrees(Weather weather) {
    const style = TextStyle(
      fontSize: 100,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Opacity(
          opacity: 0,
          child: Text('°', style: style),
        ),
        Text('${weather.degrees}°', style: style),
      ],
    );
  }
}
