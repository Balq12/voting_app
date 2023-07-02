import 'package:flutter/material.dart';
import 'package:voting_app/candidate.dart';
import 'package:voting_app/contract_link.dart';

void main() {
  runApp(
    const MaterialApp(
      title: 'Celo Voting',
      home: HomePage(),
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ContractLink _contractLink;

  @override
  void initState() {
    _contractLink = ContractLink();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Celo Voting'),
      ),
      body: FutureBuilder<List<Candidate>>(
        future: _contractLink.getCandidates(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var candidate = snapshot.data![index];

              return Card(
                child: ListTile(
                  title: Text(candidate.name),
                  trailing: Text('Votes: ${candidate.voteCount}'),
                  onTap: () {
                    _contractLink.vote(candidate.id);
                    setState(() {});
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
