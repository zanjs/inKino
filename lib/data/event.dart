import 'package:meta/meta.dart';
import 'package:xml/xml.dart' as xml;
import 'package:inkino/utils.dart';

enum EventListType {
  nowInTheaters,
  comingSoon,
}

class Event {
  Event({
    @required this.id,
    @required this.title,
    @required this.originalTitle,
    @required this.genres,
    @required this.directors,
    @required this.actors,
    @required this.lengthInMinutes,
    @required this.shortSynopsis,
    @required this.synopsis,
    @required this.images,
    @required this.youtubeTrailers,
  });

  final String id;
  final String title;
  final String originalTitle;
  final String genres;
  final List<String> directors;
  final List<String> actors;
  final String lengthInMinutes;
  final String shortSynopsis;
  final String synopsis;
  final EventImageData images;
  final List<String> youtubeTrailers;

  bool get hasSynopsis => shortSynopsis.isNotEmpty && synopsis.isNotEmpty;

  static List<Event> parseAll(String xmlString) {
    var events = <Event>[];
    var alreadyPresentImageFileNames = <String>[];
    var document = xml.parse(xmlString);

    document.findAllElements('Event').forEach((node) {
      var images = EventImageData.parseAll(node.findElements('Images'));
      var imgFileName = images.anyAvailableImage?.split('/')?.last ?? null;

      if (imgFileName == null || !alreadyPresentImageFileNames.contains(imgFileName)) {
        events.add(new Event(
          id: tagContents(node, 'ID'),
          title: tagContents(node, 'Title'),
          originalTitle: tagContents(node, 'OriginalTitle'),
          genres: tagContents(node, 'Genres'),
          directors: _parseDirectors(node.findAllElements('Director')),
          actors: _parseActors(node.findAllElements('Actor')),
          lengthInMinutes: tagContents(node, 'LengthInMinutes'),
          shortSynopsis: tagContents(node, 'ShortSynopsis'),
          synopsis: tagContents(node, 'Synopsis'),
          images: images,
          youtubeTrailers: _parseTrailers(node.findAllElements('EventVideo')),
        ));

        alreadyPresentImageFileNames.add(imgFileName);
      }
    });

    return events;
  }

  static List<String> _parseDirectors(Iterable<xml.XmlElement> nodes) {
    var directors = <String>[];

    nodes.forEach((node) {
      var first = tagContents(node, 'FirstName');
      var last = tagContents(node, 'LastName');
      directors.add('$first $last');
    });

    return directors;
  }

  static List<String> _parseActors(Iterable<xml.XmlElement> nodes) {
    var actors = <String>[];

    nodes.forEach((node) {
      var first = tagContents(node, 'FirstName');
      var last = tagContents(node, 'LastName');
      actors.add('$first $last');
    });

    return actors;
  }

  static List<String> _parseTrailers(Iterable<xml.XmlElement> nodes) {
    var trailers = <String>[];

    nodes.forEach((node) {
      trailers.add(
        'https://youtube.com/watch?v=' + tagContents(node, 'Location'),
      );
    });

    return trailers;
  }
}

class EventImageData {
  EventImageData({
    @required this.portraitSmall,
    @required this.portraitMedium,
    @required this.portraitLarge,
    @required this.landscapeSmall,
    @required this.landscapeBig,
  });

  final String portraitSmall;
  final String portraitMedium;
  final String portraitLarge;
  final String landscapeSmall;
  final String landscapeBig;

  String get anyAvailableImage =>
      portraitSmall ??
      portraitMedium ??
      portraitLarge ??
      landscapeSmall ??
      landscapeBig;

  EventImageData.empty()
      : portraitSmall = null,
        portraitMedium = null,
        portraitLarge = null,
        landscapeSmall = null,
        landscapeBig = null;

  static EventImageData parseAll(Iterable<xml.XmlElement> roots) {
    if (roots == null || roots.isEmpty) {
      return new EventImageData.empty();
    }

    var root = roots.first;

    return new EventImageData(
      portraitSmall: tagContentsOrNull(root, 'EventSmallImagePortrait'),
      portraitMedium: tagContentsOrNull(root, 'EventMediumImagePortrait'),
      portraitLarge: tagContentsOrNull(root, 'EventLargeImagePortrait'),
      landscapeSmall: tagContentsOrNull(root, 'EventSmallImageLandscape'),
      landscapeBig: tagContentsOrNull(root, 'EventLargeImageLandscape'),
    );
  }
}
