import 'package:rxdart/rxdart.dart';

abstract class ListViewModelInput<R> {
  void start(R request);
  void loadMore(R request);
}

abstract class ListViewModelOutput<T> {
  Stream<bool> get loading;
  Stream<T> get result;
  Stream<Exception> get exception;
}

abstract class ListViewModel<R, T> {
  ListViewModelInput<R> get inputs;
  ListViewModelOutput<T> get outputs;

  void dispose();
}