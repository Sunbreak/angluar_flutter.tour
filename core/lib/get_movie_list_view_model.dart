import 'package:rxdart/rxdart.dart';
import 'package:core/model/movie.dart';
import 'package:core/service.dart';
import 'list_view_model.dart';

class GetMovieListViewModel<R>
    implements
        ListViewModel<R, List<Movie>>,
        ListViewModelInput<R>,
        ListViewModelOutput<List<Movie>> {

  @override
  ListViewModelInput<R> get inputs => this;

  @override
  ListViewModelOutput<List<Movie>> get outputs => this;

  @override
  Stream<bool> get loading => _loadingProperty.stream;

  @override
  Stream<Exception> get exception => _exceptionProperty.stream;

  @override
  Stream<List<Movie>> get result {
    final items = List<Movie>();
    bool clearItems = false;

    final initialRequest = _startProperty.stream
        .doOnData((_) => _loadingProperty.sink.add(true))
        .switchMap((request) => Stream.fromFuture(service.execute(request)))
        .doOnData((_) {
      _loadingProperty.sink.add(false);
      clearItems = true;
    });

    final nextRequest = _loadMoreProperty.stream
        .doOnData((_) => _loadingProperty.sink.add(true))
        .switchMap((request) => Stream.fromFuture(service.execute(request)))
        .doOnData((_) {
      _loadingProperty.sink.add(false);
      clearItems = false;
    });

    return Rx.merge([initialRequest, nextRequest]).map((response) {
      if (clearItems) {
        items.clear();
      }

      items.addAll(response);

      return items;
    });
  }

  final Service<R, List<Movie>> service;

  final _startProperty = BehaviorSubject<R>();
  final _loadMoreProperty = BehaviorSubject<R>();
  final _loadingProperty = BehaviorSubject<bool>();
  final _exceptionProperty = BehaviorSubject<Exception>();

  GetMovieListViewModel({this.service});

  @override
  void start(R request) {
    _startProperty.sink.add(request);
  }

  @override
  void loadMore(R request) {
    _loadMoreProperty.sink.add(request);
  }

  @override
  void dispose() {
    _loadMoreProperty.close();
    _loadingProperty.close();
    _startProperty.close();
    _exceptionProperty.close();
  }
}