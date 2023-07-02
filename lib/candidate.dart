class Candidate {
  final int id;
  final String name;
  final int voteCount;

  Candidate(this.id, this.name, this.voteCount);

  Candidate.fromArray(List<dynamic> array)
      : id = array[0].toInt(),
        name = array[1],
        voteCount = array[2].toInt();
}
